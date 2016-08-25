const bluebird = require('bluebird');
const client = require('../redis').client;
const request = require('request');
const fs = bluebird.promisifyAll(require('fs'));

const { bigEndianEncode, getBloomFilterBit } = require('./dpUtility');

const {
  BLOOM_FILTER_SIZE,
  NUM_HASH_FUNCTIONS,
  NUM_COHORTS,
  P_PARAM,
  Q_PARAM,
  F_PARAM,
  MAX_SUM_BITS,
  CANDIDATE_STRINGS,
} = require('./dpParams');

// Config
const ANALYSIS_SERVER = 'http://localhost:8004';

// Generate the counts file containing the total number of reports and bit sums
// for each cohort.
// Returns a Promise that is resolved with the string contents of the counts file.
function generateCountsString() {
  // Perform one batch query for each cohort
  const queries = [...Array(NUM_COHORTS).keys()].map(cohortNum => {
    const commands = [];

    // Get this cohort's total number of reports
    commands.push(['HMGET', 'repTotals', `coh${cohortNum}`]);

    // Get this cohort's sums for each bit position
    [...Array(BLOOM_FILTER_SIZE).keys()].forEach(bitPos => {
      commands.push(['BITFIELD', `bitCounts:${cohortNum}`, 'GET', `u${MAX_SUM_BITS}`, `#${bitPos}`]);
    });

    return client.batch(commands).execAsync();
  });

  return Promise.all(queries)
    .then(rows => {
      return rows.map(row => row.join(',')).join('\n')
    });
}

// Given an Array of candidate strings, generate the map file containing
// each candidate string and the bits that they map to in each cohort.
// Each line starts with the candidate string, followed by the bit positions
// that each string maps to in each cohort. In order to distinguish bit positions
// in different cohorts, we multiply the cohort number by the bloom filter size
// and then add the bit position.
// Returns a string representing the contents of the map file.
function generateMapString(candidateStrings) {
  const lines = candidateStrings.map(string => {
    const positions = [string];

    [...Array(NUM_COHORTS).keys()].forEach(cohortNum => {
      [...Array(NUM_HASH_FUNCTIONS).keys()].forEach(hashNum => {
        const bitPos = getBloomFilterBit(string, cohortNum, hashNum) + 1;
        positions.push(cohortNum * BLOOM_FILTER_SIZE + bitPos);
      });
    });

    return positions.join(',');
  });

  return lines.join('\n');
}

// Returns a string representing the contents of the RAPPOR params file,
// using the parameters set in dpParams.js.
function generateParamsString() {
  const params = [
    BLOOM_FILTER_SIZE,
    NUM_HASH_FUNCTIONS,
    NUM_COHORTS,
    P_PARAM,
    Q_PARAM,
    F_PARAM,
  ];

  return `k,h,m,p,q,f\n${params.join(',')}\n`
}

// Given an Array of candidate strings, using aggregated data in Redis,
// returns a Promise that is resolved with an object describing the results
// of the analysis.
function performDPAnalysis(candidateStrings) {
  // Generate file bodies
  return Promise.all([
      generateCountsString(),
      generateMapString(candidateStrings),
      generateParamsString(),
    ])
    .then(([countsString, mapString, paramsString]) => {
      // Write files
      return Promise.all([
        fs.writeFileAsync('./analysis-server/tmp/counts.csv', countsString),
        fs.writeFileAsync('./analysis-server/tmp/map.csv', mapString),
        fs.writeFileAsync('./analysis-server/tmp/params.csv', paramsString),
      ]);
    })
    .then(() => {
      // Submit POST request
      const formData = {};

      ['counts', 'map', 'params'].forEach(fileName => {
        formData[fileName] = {
          value: fs.createReadStream(`./analysis-server/tmp/case_${fileName}.csv`),
          options: {
            filename: `case_${fileName}.csv`,
            contentType: 'text/csv',
          },
        };
      });

      return new Promise((resolve, reject) => {
        request.post({ url: `${ANALYSIS_SERVER}/ocpu/library/rappor/R/Decode`, formData }, (err, res, body) => {
          if (err) reject(err);
          resolve(body);
        });
      });
    })
    .then(body => {
      // Retrieve JSON results
      const bodyLines = body.split('\n');
      const resultsJSONPath = bodyLines.find(line => line.includes('results.json'));

      return new Promise((resolve, reject) => {
        request(`${ANALYSIS_SERVER}${resultsJSONPath}`, (err, res, body) => {
          if (err) reject(err);
          resolve(body);
        });
      });
    })
    .then(json => {
      // Return parsed JSON
      return JSON.parse(json);
    })
    .catch(console.error.bind.console);
}

// Exports
module.exports = {
  performDPAnalysis,
};

// performDPAnalysis(CANDIDATE_STRINGS)
//   .then(results => console.log(results.fit.string));
