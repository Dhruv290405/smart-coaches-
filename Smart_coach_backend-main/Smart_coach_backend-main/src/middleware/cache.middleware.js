const { parsePagination, paginate } = require('../utils/responseCache');

function applyPaginationToBody(body, req) {
  if (!body || typeof body !== 'object' || Array.isArray(body)) return body;
  if (!Array.isArray(body.data)) return body;

  const pagination = parsePagination(req);
  if (!pagination) return body;

  const result = paginate(body.data, pagination);
  body.data = result.items;
  if (result.pagination) {
    body.pagination = result.pagination;
  }
  return body;
}

function cacheAndPaginationMiddleware(req, res, next) {
  if (req.method !== 'GET') return next();

  const originalJson = res.json.bind(res);
  res.json = (body) => {
    const paginatedBody = applyPaginationToBody(body, req);

    const serialized = JSON.stringify(paginatedBody ?? null);
    const etag = `"${require('crypto').createHash('sha1').update(serialized).digest('hex')}"`;

    res.set('ETag', etag);
    res.set('Vary', 'Authorization, Accept-Encoding');

    if (res.statusCode >= 400) {
      res.set('Cache-Control', 'no-store');
    } else {
      res.set('Cache-Control', 'private, max-age=5, stale-while-revalidate=10');
    }

    if (req.headers['if-none-match'] === etag) {
      res.status(304);
      return res.end();
    }

    return originalJson(paginatedBody);
  };

  next();
}

module.exports = cacheAndPaginationMiddleware;
