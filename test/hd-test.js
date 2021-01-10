/* eslint-env mocha */
/* eslint prefer-arrow-callback: "off" */

'use strict';

const base58 = require('bcrypto/lib/encoding/base58');
const pbkdf2 = require('bcrypto/lib/pbkdf2');
const sha512 = require('bcrypto/lib/sha512');
const assert = require('bsert');
const PrivateKey = require('../vendor/private')
const vectors = require('./data/hd.json');
const vector1 = vectors.vector1;
const vector2 = vectors.vector2;

let master = null;
let child = null;

describe('HD', function() {
  it('should create a pbkdf2 seed', () => {
    const seed = pbkdf2.derive(sha512,
      Buffer.from(vectors.phrase),
      Buffer.from('mnemonicfoo'),
      2048,
      64);
    assert.strictEqual(seed.toString('hex'), vectors.seed);
  });
});
