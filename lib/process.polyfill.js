process = {}
process.nextTick = setImmediate
process.env = {}

module.exports = process