const crypto = require('crypto');

function parsePagination(req, { defaultLimit = 50, maxLimit = 500 } = {}) {
  const pageRaw = req.query.pg ?? req.query.pageNo ?? req.query.pageNumber ?? req.query.p;
  const limitRaw = req.query.pgSize ?? req.query.pageSize ?? req.query.perPage ?? req.query.page_size ?? req.query.limitSize;
  if (pageRaw == null && limitRaw == null) return null;

  const page = Math.max(1, parseInt(pageRaw || '1', 10) || 1);
  const requestedLimit = parseInt(limitRaw || String(defaultLimit), 10) || defaultLimit;
  const limit = Math.min(Math.max(1, requestedLimit), maxLimit);
  return { page, limit, offset: (page - 1) * limit };
}

function paginate(items, pagination) {
  if (!pagination || !Array.isArray(items)) {
    return { items: items || [], pagination: null };
  }

  const total = items.length;
  const totalPages = Math.max(1, Math.ceil(total / pagination.limit));
  const page = Math.min(Math.max(1, pagination.page), totalPages);
  const offset = (page - 1) * pagination.limit;
  const sliced = items.slice(offset, offset + pagination.limit);

  return {
    items: sliced,
    pagination: {
      page,
      pageSize: pagination.limit,
      total,
      totalPages,
      hasNext: offset + pagination.limit < total,
      hasPrev: page > 1,
    },
  };
}

function sendCachedJson(res, req, body, { maxAge = 5, skipCache = false } = {}) {
  const serialized = JSON.stringify(body ?? null);
  const etag = `"${crypto.createHash('sha1').update(serialized).digest('hex')}"`;

  res.set('ETag', etag);
  res.set('Vary', 'Authorization, Accept-Encoding');

  if (!skipCache && res.statusCode < 400) {
    res.set('Cache-Control', `private, max-age=${maxAge}, stale-while-revalidate=${maxAge * 2}`);
  } else {
    res.set('Cache-Control', 'no-store');
  }

  if (req.headers['if-none-match'] === etag) {
    res.status(304);
    return res.end();
  }

  return res.json(body);
}

module.exports = {
  parsePagination,
  paginate,
  sendCachedJson,
};
