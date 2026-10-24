/**
 * pneumaticPdfGenerator.js
 *
 * Server-side PDF generation for pneumatic (brake binding) log history.
 * Uses pdfkit to render the report directly on the Node.js process, which is
 * orders-of-magnitude faster than rendering in the Flutter Dart VM on a mobile
 * device — especially for large datasets (10k – 50k rows).
 *
 * API contract:
 *   generatePneumaticHistoryPdf(res, { rows, meta }) → pipes PDF to res
 *   generatePneumaticFaultsPdf(res, { faults, meta })  → pipes PDF to res
 *
 * Both functions set the correct Content-Type / Content-Disposition headers
 * and pipe the pdfkit document stream directly to the HTTP response, so the
 * client starts receiving bytes immediately (no buffer-everything-then-send
 * overhead).
 */

const PDFDocument = require('pdfkit');

// ─── Layout constants (portrait → landscape A4 in pdfkit: swap w/h) ──────────
const PAGE_W = 841.89; // A4 landscape width  (pts)
const PAGE_H = 595.28; // A4 landscape height (pts)
const MARGIN = 20;
const CONTENT_W = PAGE_W - MARGIN * 2;

// Row / font sizes
const HEADER_FONT_SIZE = 7;
const ROW_FONT_SIZE = 6.5;
const ROW_H = 11;        // height of each data row (pts)
const HEADER_ROW_H = 13; // height of the blue column-header band

// Coulumn definitions  [label, relativeWidth (sum must equal 1)]
const COLUMNS = [
    { label: 'SR',            w: 0.036, align: 'right'  },
    { label: 'TIMESTAMP',     w: 0.135, align: 'left'   },
    { label: 'DEVICE ID',     w: 0.12,  align: 'left'   },
    { label: 'TRAIN',         w: 0.06,  align: 'left'   },
    { label: 'LOCATION',      w: 0.08,  align: 'left'   },
    { label: 'BP',            w: 0.048, align: 'right'  },
    { label: 'FP',            w: 0.048, align: 'right'  },
    { label: 'CR',            w: 0.048, align: 'right'  },
    { label: 'BC',            w: 0.048, align: 'right'  },
    { label: 'BRAKE STATUS',  w: 0.1,   align: 'left'   },
    { label: 'APPLIED',       w: 0.055, align: 'right'  },
    { label: 'RELEASED',      w: 0.055, align: 'right'  },
    { label: 'DURATION',      w: 0.055, align: 'right'  },
    { label: 'BRAKE FAULT',   w: 0.054, align: 'left'   },
];

// Pre-compute absolute column x-coordinates and widths (pixels/pts)
const COL_META = (() => {
    let x = MARGIN;
    return COLUMNS.map(col => {
        const colW = col.w * CONTENT_W;
        const meta = { label: col.label, x, w: colW, align: col.align };
        x += colW;
        return meta;
    });
})();

// ─── Helpers ─────────────────────────────────────────────────────────────────

function formatTimestamp(raw) {
    if (!raw) return '';
    try {
        const d = new Date(raw);
        if (isNaN(d.getTime())) return String(raw);
        const pad = n => String(n).padStart(2, '0');
        return `${pad(d.getDate())}/${pad(d.getMonth() + 1)}/${d.getFullYear()} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;
    } catch (_) {
        return String(raw);
    }
}

function safeStr(v) {
    if (v === null || v === undefined) return '';
    return String(v);
}

/** Clip a string so it fits within the column width at the given font size */
function clipText(doc, text, maxWidth, fontSize) {
    // pdfkit widthOfString is fast; clip char-by-char only when needed
    if (doc.widthOfString(text, { size: fontSize }) <= maxWidth) return text;
    // Binary-ish shrink: remove chars from the right until it fits
    let t = text;
    while (t.length > 0 && doc.widthOfString(t + '…', { size: fontSize }) > maxWidth) {
        t = t.slice(0, -1);
    }
    return t + '…';
}

// ─── Fast monospace clipping (Courier glyph width = 0.6 em) ──────────────────
// Avoids calling doc.widthOfString for every cell (the main CPU hot-spot).
const COURIER_CHAR_W = 0.6 * ROW_FONT_SIZE;

function maxCharsFor(width) {
    return Math.max(1, Math.floor(width / COURIER_CHAR_W));
}

function clipMono(text, maxChars) {
    if (text.length <= maxChars) return text;
    return maxChars > 1 ? text.slice(0, maxChars - 1) + '…' : text.slice(0, 1);
}

COL_META.forEach(col => { col.maxChars = maxCharsFor(col.w - 2); });

// ─── Column-header band ───────────────────────────────────────────────────────

function drawColumnHeaders(doc, y) {
    // Blue background rectangle
    doc.save()
       .rect(MARGIN, y, CONTENT_W, HEADER_ROW_H)
       .fill('#1e3a5f')
       .restore();

    doc.font('Helvetica-Bold').fontSize(HEADER_FONT_SIZE).fillColor('#FFFFFF');
    COL_META.forEach(col => {
        if (col.headerText === undefined) {
            col.headerText = clipText(doc, col.label, col.w - 2, HEADER_FONT_SIZE);
        }
        doc.text(col.headerText, col.x + 1, y + 3, { width: col.w - 2, align: col.align, lineBreak: false });
    });
    // Restore row font once per page (not once per row)
    doc.font('Courier').fontSize(ROW_FONT_SIZE).fillColor('#1a1a2e');
}

// ─── Single data row ──────────────────────────────────────────────────────────
// Caller guarantees Courier / ROW_FONT_SIZE / row colour are already set.

function drawDataRow(doc, cells, y, isEven) {
    if (isEven) {
        doc.save()
           .rect(MARGIN, y, CONTENT_W, ROW_H)
           .fill('#F5F7FA')
           .restore();
        doc.fillColor('#1a1a2e');
    }
    for (let idx = 0; idx < COL_META.length; idx++) {
        const col = COL_META[idx];
        const raw = idx < cells.length ? safeStr(cells[idx]) : '';
        if (raw === '') continue;
        doc.text(clipMono(raw, col.maxChars), col.x + 1, y + 2, { width: col.w - 2, align: col.align, lineBreak: false });
    }
}

// ─── Page header / metadata block (first page only) ──────────────────────────

function drawPageTitle(doc, { title, period, metadata, generated }) {
    const TOP = PAGE_H - MARGIN - 10; // pdfkit origin is bottom-left when using raw coords
    // pdfkit default is top-left, y increases downward
    let y = MARGIN;

    doc.font('Helvetica-Bold').fontSize(14).fillColor('#1e3a5f');
    doc.text(title, MARGIN, y);
    y += 18;

    doc.font('Helvetica').fontSize(8.5).fillColor('#475569');
    doc.text(period, MARGIN, y);
    y += 12;
    doc.text(metadata, MARGIN, y);
    y += 12;

    doc.font('Helvetica').fontSize(7.5).fillColor('#64748b');
    doc.text(generated, MARGIN, y);
    y += 14;

    return y; // next drawing y after title block
}

// ─── Page footer ──────────────────────────────────────────────────────────────

function addPageFooter(doc, pageNum, totalPages) {
    const footerY = PAGE_H - MARGIN - 6;
    doc.font('Courier').fontSize(6.5).fillColor('#94a3b8');
    doc.text(
        `Page ${pageNum} of ${totalPages}`,
        PAGE_W - MARGIN - 100,
        footerY,
        { width: 100, align: 'right', lineBreak: false }
    );
}

// ─── PUBLIC: History PDF ──────────────────────────────────────────────────────

/**
 * Generates a history log PDF and pipes it directly to `res`.
 *
 * @param {import('express').Response} res
 * @param {object} opts
 * @param {Array}  opts.rows    - Array of PneumaticHistoryData objects (from backend model)
 * @param {object} opts.meta    - { title, period, metadata, generated, filename }
 */
function generatePneumaticHistoryPdf(res, { rows, meta }) {
    const filename = meta.filename || `brake_binding_history_${Date.now()}.pdf`;

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
    res.setHeader('Cache-Control', 'no-store');

    const doc = new PDFDocument({
        size: [PAGE_W, PAGE_H],  // landscape A4
        margin: 0,               // we manage margins manually
        compress: true,
        bufferPages: false,      // stream pages as produced — key for large docs
        autoFirstPage: false,
    });

    // Pipe directly to response — client starts downloading immediately
    doc.pipe(res);

    const BOTTOM_LIMIT = PAGE_H - MARGIN - ROW_H;  // don't draw below this

    // Stop work if the client disconnects (prevents wasted CPU / memory)
    let aborted = false;
    res.on('close', () => { if (!res.writableEnded) aborted = true; });

    // ── First page ──────────────────────────────────────────────────────────
    doc.addPage();
    let y = drawPageTitle(doc, meta);
    drawColumnHeaders(doc, y);
    y += HEADER_ROW_H;

    let pageNum = 1;

    // Render in chunks and yield to the event loop between chunks so a huge
    // report never freezes the server, and respect stream backpressure so
    // memory stays flat.
    const CHUNK_ROWS = 1500;
    let i = 0;

    const renderChunk = () => {
        if (aborted) { try { doc.end(); } catch (_) {} return; }
        const stop = Math.min(i + CHUNK_ROWS, rows.length);
        for (; i < stop; i++) {
            const row = rows[i];

            // ── Page break ────────────────────────────────────────────────────
            if (y + ROW_H > BOTTOM_LIMIT) {
                addPageFooter(doc, pageNum, '?');
                doc.addPage();
                pageNum++;
                y = MARGIN;
                drawColumnHeaders(doc, y);
                y += HEADER_ROW_H;
            }

            const cells = [
                String(i + 1),
                formatTimestamp(row.timestamp),
                safeStr(row.device_id),
                safeStr(row.train_no),
                safeStr(row.location),
                safeStr(row.bp),
                safeStr(row.fp),
                safeStr(row.cr),
                safeStr(row.bc),
                safeStr(row.brake_status),
                `${safeStr(row.brake_applied_time)}s`,
                `${safeStr(row.brake_released_time)}s`,
                `${safeStr(row.brake_duration)}s`,
                row.brake_fault ? safeStr(row.brake_fault) : 'OK',
            ];

            drawDataRow(doc, cells, y, i % 2 === 0);
            y += ROW_H;
        }

        if (i < rows.length) {
            // Yield to the event loop; if the response buffer is full wait for drain.
            if (res.writableNeedDrain) res.once('drain', () => setImmediate(renderChunk));
            else setImmediate(renderChunk);
            return;
        }

        addPageFooter(doc, pageNum, pageNum);
        doc.end();
    };

    renderChunk();
}

// ─── PUBLIC: Faults PDF ────────────────────────────────────────────────────────

const FAULT_COLS = [
    { label: 'SR',          w: 0.04,  align: 'right' },
    { label: 'DEVICE ID',   w: 0.15,  align: 'left'  },
    { label: 'FAULT TYPE',  w: 0.18,  align: 'left'  },
    { label: 'SEVERITY',    w: 0.10,  align: 'left'  },
    { label: 'DESCRIPTION', w: 0.37,  align: 'left'  },
    { label: 'TIMESTAMP',   w: 0.15,  align: 'left'  },
];

const FAULT_COL_META = (() => {
    let x = MARGIN;
    return FAULT_COLS.map(col => {
        // Use portrait A4 for faults (fewer columns, fits well)
        const colW = col.w * (595.28 - MARGIN * 2);
        const meta = { label: col.label, x, w: colW, align: col.align };
        x += colW;
        return meta;
    });
})();

/**
 * Generates a fault report PDF and pipes it directly to `res`.
 */
function generatePneumaticFaultsPdf(res, { faults, meta }) {
    const P_W = 595.28; // A4 portrait width
    const P_H = 841.89; // A4 portrait height
    const P_CONTENT_W = P_W - MARGIN * 2;
    const FAULT_BOTTOM = P_H - MARGIN - ROW_H;

    const filename = meta.filename || `active_faults_${Date.now()}.pdf`;

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
    res.setHeader('Cache-Control', 'no-store');

    const doc = new PDFDocument({
        size: [P_W, P_H],
        margin: 0,
        compress: true,
        bufferPages: false,
        autoFirstPage: false,
    });

    doc.pipe(res);

    function drawFaultColHeaders(y) {
        doc.save()
           .rect(MARGIN, y, P_CONTENT_W, HEADER_ROW_H)
           .fill('#7f1d1d')
           .restore();
        doc.font('Helvetica-Bold').fontSize(HEADER_FONT_SIZE).fillColor('#FFFFFF');
        FAULT_COL_META.forEach(col => {
            const text = clipText(doc, col.label, col.w - 2, HEADER_FONT_SIZE);
            doc.text(text, col.x + 1, y + 3, { width: col.w - 2, align: col.align, lineBreak: false });
        });
    }

    function drawFaultRow(cells, y, isEven) {
        if (isEven) {
            doc.save().rect(MARGIN, y, P_CONTENT_W, ROW_H).fill('#FFF5F5').restore();
        }
        doc.font('Courier').fontSize(ROW_FONT_SIZE).fillColor('#1a1a2e');
        FAULT_COL_META.forEach((col, idx) => {
            const raw = idx < cells.length ? safeStr(cells[idx]) : '';
            const text = clipText(doc, raw, col.w - 2, ROW_FONT_SIZE);
            doc.text(text, col.x + 1, y + 2, { width: col.w - 2, align: col.align, lineBreak: false });
        });
    }

    doc.addPage();
    let y = drawPageTitle(doc, { ...meta, title: meta.title || 'Active Faults Report' });
    drawFaultColHeaders(y);
    y += HEADER_ROW_H;
    let pageNum = 1;

    for (let i = 0; i < faults.length; i++) {
        const f = faults[i];
        if (y + ROW_H > FAULT_BOTTOM) {
            doc.font('Courier').fontSize(6.5).fillColor('#94a3b8');
            doc.text(`Page ${pageNum}`, P_W - MARGIN - 60, P_H - MARGIN - 6, { width: 60, align: 'right', lineBreak: false });
            doc.addPage();
            pageNum++;
            y = MARGIN;
            drawFaultColHeaders(y);
            y += HEADER_ROW_H;
        }
        const cells = [
            String(i + 1),
            safeStr(f.deviceId || f.device_id),
            safeStr(f.type || f.fault_name),
            safeStr(f.severity) || 'High',
            safeStr(f.description || f.event_message),
            formatTimestamp(f.timestamp),
        ];
        drawFaultRow(cells, y, i % 2 === 0);
        y += ROW_H;
    }

    doc.font('Courier').fontSize(6.5).fillColor('#94a3b8');
    doc.text(`Page ${pageNum} of ${pageNum}`, P_W - MARGIN - 80, P_H - MARGIN - 6, { width: 80, align: 'right', lineBreak: false });

    doc.end();
}

module.exports = {
    generatePneumaticHistoryPdf,
    generatePneumaticFaultsPdf,
};
