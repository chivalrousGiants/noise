const {
  BLOOM_FILTER_SIZE,
  NUM_HASH_FUNCTIONS,
  NUM_COHORTS,
  P_PARAM,
  Q_PARAM,
  F_PARAM,
  MAX_SUM_BITS,
} = require('./dpParams');

// Encodes an input integer to a 4-byte big-endian string.
function bigEndianEncode(value) {
  let result = '';

  // Value must be an integer (cohort number)
  value = parseInt(value);

  for (let i = 24; i >= 0; i -= 8) {
    const byte = (value & (0xFF << i)) >> i;
    result = result.concat(String.fromCharCode(byte));
  }

  return result;
}

function getBloomFilterBit(inputString, cohortNum, hashNum) {
  const toEncode = bigEndianEncode(cohortNum) + inputString;
  const hash = md5(toEncode);

  return parseInt(hash.slice(hashNum * 2, hashNum * 2 + 2), 16) % BLOOM_FILTER_SIZE;
}

// Exports
module.exports = {
  bigEndianEncode,
  getBloomFilterBit,
};
