const client = require('../redis').client;

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
const SampleBitCounts = {

};

const sampleCandidateStrings = [

];

// Given an Object of bit counts and an Array of candidate strings, 
// returns a Promise that is resolved with an Array of detected strings.
function performDPAnalysis(bitCounts, candidateStrings) {
  
}

// Exports
module.exports = {
  performDPAnalysis,
};
