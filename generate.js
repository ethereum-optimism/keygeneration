#!/usr/bin/env node

const Mnemonic = require('./vendor/mnemonic.js')
const bcrypto = require('bcrypto')

if (!bcrypto)
  throw new Error('Be sure to unpack and install bcrypto first')

if (bcrypto.native !== 2)
  throw new Error('Compile bcrypto first')

const mnemonic = new Mnemonic()
const phrase = mnemonic.getPhrase()
console.log(phrase)
mnemonic .destroy()
