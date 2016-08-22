const redis = require('../redis');

const {
  BLOOM_FILTER_SIZE,
  NUM_HASH_FUNCTIONS,
  NUM_COHORTS,
  F_PARAM,
  P_PARAM,
  Q_PARAM,
  MAX_SUM_BITS,
} = require('./dpParams');

// Dummy data
const SampleIRRReports = {
  cohortNum: 63,
  IRRs: [
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
  ],
};

// Returns a Promise that is resolved with an Array of all query replies from Redis.
// For the specified cohort, tell Redis to add each bit to its corresponding sum.
function IngestIRRReports(IRRReports) {
  const commands = [];

  IRRReports.IRRs.forEach((IRR) => {
    // For each report, add its bits to the bitsums
    IRR.forEach((bit, index) => {
      commands.push(['BITFIELD', `bitCounts:${IRRReports.cohortNum}`, 'INCRBY', `u${MAX_SUM_BITS}`, `${MAX_SUM_BITS * index}`, bit]);
    });
  });

  // Add to the total number of received reports for this cohort
  commands.push(['HINCRBY', 'repTotals', `coh${IRRReports.cohortNum}`, IRRReports.IRRs.length]);

  return redis.client.multi(commands).execAsync();
}

// Exports
module.exports = {
  IngestIRRReports,
};


// for (let i = 0; i < 1000; i++) {
//   IngestIRRReports(SampleIRRReports);
// }
