const ExcelJS = require('exceljs');
const PDFDocument = require('pdfkit');
const supabaseOld = require('../config/supabaseOld');
const supabaseAdmin = require('../config/supabaseAdmin');
const Pneumatic = require('../models/pneumatic.model');

const MAX_EXPORT_ROWS = 50000;
const IST_OFFSET_MS = 5.5 * 60 * 60 * 1000;

const EXCEL_COLUMNS = [
    { header: 'SR. NO', key: 'sr', width: 8 },
    { header: 'TIMESTAMP', key: 'timestamp', width: 20 },
    { header: 'DEVICE ID', key: 'device', width: 18 },
    { header: 'TRAIN NO', key: 'train', width: 10 },
    { header: 'LOCATION', key: 'location', width: 14 },
    { header: 'BP', key: 'bp', width: 8 },
    { header: 'FP', key: 'fp', width: 8 },
    { header: 'CR', key: 'cr', width: 8 },
    { header: 'BC', key: 'bc', width: 8 },
    { header: 'BRAKE STATUS', key: 'status', width: 22 },
    { header: 'BRAKE APPLIED TIME', key: 'applied', width: 14 },
    { header: 'BRAKE RELEASED TIME', key: 'released', width: 14 },
    { header: 'BRAKE DURATION', key: 'duration', width: 14 },
    { header: 'BRAKE FAULT', key: 'fault', width: 26 },
];

const PDF_COLUMNS = [
    { key: 'sr', width: 5, align: 'right' },
    { key: 'timestamp', width: 19, align: 'left' },
    { key: 'device', width: 17, align: 'left' },
    { key: 'train', width: 7, align: 'left' },
    { key: 'location', width: 12, align: 'left' },
    { key: 'bp', width: 6, align: 'right' },
    { key: 'fp', width: 6, align: 'right' },
    { key: 'cr', width: 6, align: 'right' },
    { key: 'bc', width: 6, align: 'right' },
    { key: 'status', width: 18, align: 'left' },
    { key: 'applied', width: 8, align: 'right' },
    { key: 'released', width: 8, align: 'right' },
    { key: 'duration', width: 8, align: 'right' },
    { key: 'fault', width: 22, align: 'left' },
];

function formatIST(value) {
    if (value == null || value === '') return '';
    const date = new Date(value);
    if (Number.isNaN(date.getTime())) return String(value);
    const shifted = new Date(date.getTime() + IST_OFFSET_MS);
    const dd = String(shifted.getUTCDate()).padStart(2, '0');
    const mm = String(shifted.getUTCMonth() + 1).padStart(2, '0');
    const yyyy = shifted.getUTCFullYear();
    const hh = String(shifted.getUTCHours()).padStart(2, '0');
    const mi = String(shifted.getUTCMinutes()).padStart(2, '0');
    const ss = String(shifted.getUTCSeconds()).padStart(2, '0');
    return `${dd}/${mm}/${yyyy} ${hh}:${mi}:${ss}`;
}

function safeFilePart(value, fallback = 'all_devices') {
    const text = String(value == null ? '' : value).trim();
    if (!text) return fallback;
    return text.replace(/[^A-Za-z0-9._-]+/g, '_').slice(0, 60);
}

function numberOrZero(value) {
    const number = Number(value);
    return Number.isFinite(number) ? number : 0;
}

function textOrEmpty(value) {
    return value == null ? '' : String(value);
}

async function loadDeviceMetadata(rows) {
    const deviceIds = [...new Set(rows.map((row) => row.device_id).filter(Boolean))];
    const metadata = new Map();
    if (deviceIds.length === 0) return metadata;

    for (const client of [supabaseOld, supabaseAdmin]) {
        if (!client) continue;
        try {
            const { data, error } = await client
                .from('coaches_railway')
                .select('device_id,Actual_id,coach_no,Train_no,Location')
                .in('device_id', deviceIds);
            if (error) throw error;
            for (const coach of data || []) {
                if (!coach?.device_id || metadata.has(coach.device_id)) continue;
                metadata.set(coach.device_id, coach);
            }
        } catch (_) {}
    }

    return metadata;
}

function buildExportRows(rows, metadata) {
    return rows.map((row, index) => {
        const coach = metadata.get(row.device_id) || {};
        return {
            sr: index + 1,
            timestamp: formatIST(row.timestamp),
            device: coach.Actual_id || row.device_id || '',
            train: coach.Train_no || '',
            location: coach.Location || '',
            bp: numberOrZero(row.bp),
            fp: numberOrZero(row.fp),
            cr: numberOrZero(row.cr),
            bc: numberOrZero(row.bc),
            status: textOrEmpty(row.brake_status),
            applied: `${numberOrZero(row.brake_applied_time)}s`,
            released: `${numberOrZero(row.brake_released_time)}s`,
            duration: `${numberOrZero(row.brake_duration)}s`,
            fault: row.brake_fault == null || row.brake_fault === ''
                ? 'All parameters OK'
                : textOrEmpty(row.brake_fault),
        };
    });
}

function buildFileName({ deviceId, fromDate, toDate, format }) {
    return `brake_binding_history_${safeFilePart(deviceId)}_${safeFilePart(fromDate)}_${safeFilePart(toDate)}.${format === 'excel' ? 'xlsx' : 'pdf'}`;
}

async function streamExcel(res, exportRows, details) {
    const fileName = buildFileName({ ...details, format: 'excel' });
    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', `attachment; filename="${fileName}"`);
    res.setHeader('Cache-Control', 'no-store');
    res.setHeader('X-Export-Rows', String(exportRows.length));

    const workbook = new ExcelJS.stream.xlsx.WorkbookWriter({
        stream: res,
        useStyles: true,
        useSharedStrings: false,
    });
    const sheet = workbook.addWorksheet('Brake Binding', {
        views: [{ state: 'frozen', ySplit: 4 }],
    });

    sheet.columns = EXCEL_COLUMNS.map((column) => ({ key: column.key, width: column.width }));

    const title = sheet.addRow([`Brake Binding History - ${details.deviceLabel} - ${details.fromDate} to ${details.toDate}`]);
    title.font = { bold: true, size: 14, color: { argb: 'FF1E3A8A' } };
    title.commit();

    const info = sheet.addRow([`Total Records: ${exportRows.length}`, `Generated: ${formatIST(new Date())} IST`]);
    info.font = { italic: true, size: 9, color: { argb: 'FF4B5563' } };
    info.commit();

    sheet.addRow([]).commit();

    const header = sheet.addRow(EXCEL_COLUMNS.map((column) => column.header));
    header.font = { bold: true, color: { argb: 'FFFFFFFF' } };
    header.height = 22;
    header.eachCell((cell) => {
        cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF1E3A8A' } };
        cell.alignment = { vertical: 'middle', horizontal: 'center', wrapText: true };
    });
    header.commit();

    for (const row of exportRows) {
        sheet.addRow(row).commit();
    }

    sheet.commit();
    await workbook.commit();
}

function padCell(value, column) {
    const text = String(value == null ? '' : value).slice(0, column.width);
    return column.align === 'right' ? text.padStart(column.width) : text.padEnd(column.width);
}

function pdfHeaderLine() {
    return PDF_COLUMNS.map((column) => {
        const header = EXCEL_COLUMNS.find((excelColumn) => excelColumn.key === column.key)?.header || '';
        return padCell(header, column);
    }).join(' ');
}

function pdfRowLine(row) {
    return PDF_COLUMNS.map((column) => padCell(row[column.key], column)).join(' ');
}

async function streamPdf(res, exportRows, details) {
    const fileName = buildFileName({ ...details, format: 'pdf' });
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="${fileName}"`);
    res.setHeader('Cache-Control', 'no-store');
    res.setHeader('X-Export-Rows', String(exportRows.length));

    const doc = new PDFDocument({
        size: 'A4',
        layout: 'landscape',
        margins: { top: 26, left: 20, right: 20, bottom: 24 },
        compress: true,
        info: {
            Title: `Brake Binding History - ${details.deviceLabel}`,
            Author: 'Smart Coach',
        },
    });

    doc.pipe(res);

    const left = doc.page.margins.left;
    const pageWidth = doc.page.width - doc.page.margins.left - doc.page.margins.right;
    const bottom = doc.page.height - doc.page.margins.bottom;
    const rowHeight = 9;
    const headerLine = pdfHeaderLine();

    const drawTableHeader = () => {
        const y = doc.y;
        doc.font('Courier-Bold').fontSize(7).fillColor('#1E3A8A');
        doc.text(headerLine, left, y, { lineBreak: false });
        doc.moveTo(left, y + rowHeight - 1).lineTo(left + pageWidth, y + rowHeight - 1)
            .strokeColor('#CBD5E1').lineWidth(0.5).stroke();
        doc.y = y + rowHeight + 2;
    };

    doc.font('Helvetica-Bold').fontSize(15).fillColor('#0F172A')
        .text(`Brake Binding History - ${details.deviceLabel}`, left, doc.y);
    doc.font('Helvetica').fontSize(8).fillColor('#4B5563');
    doc.text(`Period: ${details.fromDate} to ${details.toDate}   |   Total Records: ${exportRows.length}   |   Generated: ${formatIST(new Date())} IST`);
    doc.moveDown(0.5);

    drawTableHeader();

    for (const row of exportRows) {
        if (doc.y + rowHeight > bottom) {
            doc.addPage();
            doc.y = doc.page.margins.top;
            drawTableHeader();
        }
        const y = doc.y;
        doc.font('Courier').fontSize(7).fillColor('#111827');
        doc.text(pdfRowLine(row), left, y, { lineBreak: false });
        doc.y = y + rowHeight;
    }

    doc.end();
}

async function streamHistoryExport({ response, format, deviceId, user, fromDate, toDate }) {
    const rows = await Pneumatic.getLatestReading(
        deviceId || null,
        user,
        MAX_EXPORT_ROWS,
        0,
        fromDate,
        toDate
    );

    if (!rows || rows.length === 0) {
        return { empty: true, rowCount: 0 };
    }

    const metadata = await loadDeviceMetadata(rows);
    const exportRows = buildExportRows(rows, metadata);
    const details = {
        deviceId,
        deviceLabel: deviceId || 'All Devices',
        fromDate,
        toDate,
    };

    if (format === 'pdf') {
        await streamPdf(response, exportRows, details);
    } else {
        await streamExcel(response, exportRows, details);
    }

    return { empty: false, rowCount: exportRows.length };
}

module.exports = {
    streamHistoryExport,
    MAX_EXPORT_ROWS,
};
