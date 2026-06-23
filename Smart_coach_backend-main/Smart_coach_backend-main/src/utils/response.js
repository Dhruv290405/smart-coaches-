/**
 * Success response helper
 * @param {Object} res - Express response object
 * @param {string} message - Success message
 * @param {Object|Array} data - Response data
 * @param {number} statusCode - HTTP status code (default: 200)
 * @returns {Object} - JSON response
 */
const successResponse = (res, message, data = null, statusCode = 200) => {
  return res.status(statusCode).json({
    success: true,
    message,
    data
  });
};

/**
 * Error response helper
 * @param {Object} res - Express response object
 * @param {string} message - Error message
 * @param {number} statusCode - HTTP status code (default: 500)
 * @param {Object} error - Error object (optional)
 * @returns {Object} - JSON response
 */
const errorResponse = (res, message, statusCode = 500, error = null) => {
  const response = {
    success: false,
    message
  };

  // Only include error details in development
  if (process.env.NODE_ENV === 'development' && error) {
    response.error = {
      message: error.message,
      stack: error.stack,
    };
  }

  return res.status(statusCode).json(response);
};

module.exports = { successResponse, errorResponse };
