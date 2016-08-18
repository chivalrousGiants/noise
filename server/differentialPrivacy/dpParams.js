// 'k'
const BLOOM_FILTER_SIZE = 32;
// 'h'
const NUM_HASH_FUNCTIONS = 4;
// 'm'
const NUM_COHORTS = 64;
// Longitudinal privacy parameter
const F_PARAM = 0.5;
// IRR parameters
const P_PARAM = 0.75;
const Q_PARAM = 0.5;

// Misc params
// 2 ^ MAX_SUM_BITS is the maximum value for a sum of report bit places.
const MAX_SUM_BITS = 16;

module.exports = {
  BLOOM_FILTER_SIZE,
  NUM_HASH_FUNCTIONS,
  NUM_COHORTS,
  F_PARAM,
  P_PARAM,
  Q_PARAM,
  MAX_SUM_BITS,
};
