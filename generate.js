#!/usr/bin/env node

const Mnemonic = require('./vendor/mnemonic');
const HDPrivateKey = require('./vendor/private');
const secp256k1 = require('bcrypto/lib/secp256k1');
const keccak256 = require('bcrypto/lib/keccak256');
const bcrypto = require('bcrypto');

if (!bcrypto)
  throw new Error('Be sure to unpack and install bcrypto first');

if (bcrypto.native !== 2)
  throw new Error('Compile bcrypto first');

const mnemonic = new Mnemonic();
const phrase = mnemonic.getPhrase();

console.log('Mnemonic:');
console.log(phrase);
console.log();

const privkey = HDPrivateKey.fromMnemonic(mnemonic)

const paths = [
  `m/44'/60'/0'/0`,
  `m/44'/60'/0'/1`,
  `m/44'/60'/0'/2`,
  `m/44'/60'/0'/0/0`,
  `m/44'/60'/0'/0/1`,
  `m/44'/60'/0'/0/2`,
];

for (const path of paths) {
  console.log(`Path: ${path}`);
  const key = privkey.derivePath(path);
  console.log('Private Key:');
  console.log('0x' + key.privateKey.toString('hex'));
  console.log('Public Key:')
  const uncompressed = secp256k1.publicKeyConvert(privkey.publicKey, false)
  console.log('0x' + uncompressed.toString('hex'));
  const unprefixed = uncompressed.slice(1);
  const address = keccak256.digest(unprefixed).slice(0, 20);
  console.log('Address:')
  console.log('0x' + address.toString('hex'));
  console.log();
}

mnemonic.destroy();
privkey.destroy();
