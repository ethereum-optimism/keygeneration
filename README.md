# keygeneration

Offline key generation. Generates a [bip 39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki)
compliant mnemonic. Useful for generating keys on an airgapped computer.

## Local Dependencies

- docker
- tar
- wget
- shasum

## Downloads

The `download.sh` script will download all of the necessary dependencies
for generating keys on an airgapped computer. These dependencies
are listed below.

### Debian Packages

- build-essential
- nodejs v14.x

### Git Repos

- [node-gyp](https://github.com/nodejs/node-gyp)
- [bcrypto](https://github.com/bcoin-org/bcrypto)
- [bsert](https://github.com/chjj/bsert)
- [bufio](https://github.com/bcoin-org/bufio)
- [loady](https://github.com/chjj/loady)
- [bmocha](https://github.com/bcoin-org/bmocha)

### Vendor Directory

Files taken from [hsd](https://github.com/handshake-org/hsd).
See the [hd package](https://github.com/handshake-org/hsd/tree/master/lib/hd).
Tests are taken as well and run automatically after installation.

## Usage

First the dependencies for offline key generation must be bundled
together. Run the command:

```bash
$ ./download.sh -o <output directory>
```

Use the `-o` flag to specify an output directory for the
files. This could be set to the directory that represents
a USB stick. The `-h` flag will print its usage.

This will generate an `install.sh` script as well as a bunch
of tarballs containing various dependencies for the keygen.

On the airgapped computer, copy the files off of the USB stick.
Navigate to the directory full of the files and run the commands:

```bash
$ chmod +x install.sh
$ ./install.sh
```

This will install the dependencies and run tests.

Now to generate the mnemonic, run the command:

```bash
$ node generate.js
```

This will print off a mnemonic.

## RNG

[bcrypto](https://github.com/bcoin-org/bcrypto) is used to
create the mnemonic. The RNG is from
[libtorsion](https://github.com/bcoin-org/libtorsion). At time of writing,
this package uses `bcrypto` at `v5.3.0`. The RNG implementation can be
found [here](https://github.com/bcoin-org/bcrypto/blob/v5.3.0/deps/torsion/src/rand.c).

