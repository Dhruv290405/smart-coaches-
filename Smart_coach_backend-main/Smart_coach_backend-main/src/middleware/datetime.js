function toMySQLDatetime(date = new Date()) {
  // Convert to Indian Standard Time (UTC+5:30)
  const istOffset = 5.5 * 60 * 60 * 1000;
  const istDate = new Date(date.getTime() + istOffset);
  return istDate.toISOString().slice(0, 19).replace('T', ' ');
}


module.exports = {
  toMySQLDatetime
};
