#!/bin/bash

# TODO: configurable
### make this configurable
OUTDIR=/run/media/tynes/B0E2-E6FB
OUTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"

USAGE="
$ ./download.sh

Download and prepare files for offline key generation.
Outputs the files in the output directory.

CLI Arguments
  -o|--out   - output directory of generated files
  -h|--help  - print help
"

while (( "$#" )); do
  case "$1" in
    -o|--out)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        OUTDIR="$2"
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -h|--help)
      echo "$USAGE"
      exit 0
      ;;
    *)
      echo "Unknown argument $1" >&2
      shift
      ;;
  esac
done

MAIN=https://packages.ubuntu.com/bionic/amd64
MIRROR=https://mirrors.kernel.org/ubuntu/pool/main/b
OUTFILE=dependencies.tar.gz

BCRYPTO_TAG=v5.3.0
BSERT_TAG=v0.0.10
BUFIO_TAG=v1.0.7
LOADY_TAG=v0.0.5
NODE_GYP_TAG=v7.1.2
BMOCHA_TAG=v2.1.5

function download () {
    docker run \
        --rm \
        -v $PWD:/home \
        --entrypoint /bin/bash \
        ubuntu:bionic \
        /home/deps.sh
}

function tar_deb () {
    tar -cvf $OUTFILE --remove-files $(ls | grep '.deb$') \
        >/dev/null
}

function move () {
    mv $1 $OUTDIR/$1
}

function get_release () {
    wget -O $1 $2
}

function remove_v () {
    echo $(echo $1 | tr -d v)
}

download
tar_deb

get_release bcrypto_$BCRYPTO_TAG.tar.gz \
    https://github.com/bcoin-org/bcrypto/archive/$BCRYPTO_TAG.tar.gz
move bcrypto_$BCRYPTO_TAG.tar.gz
get_release bsert_$BSERT_TAG.tar.gz \
    https://github.com/chjj/bsert/archive/$BSERT_TAG.tar.gz
move bsert_$BSERT_TAG.tar.gz
get_release bufio_$BUFIO_TAG.tar.gz \
    https://github.com/bcoin-org/bufio/archive/$BUFIO_TAG.tar.gz
move bufio_$BUFIO_TAG.tar.gz
get_release loady_$LOADY_TAG.tar.gz \
    https://github.com/chjj/loady/archive/$LOADY_TAG.tar.gz
move loady_$LOADY_TAG.tar.gz
get_release bmocha_$BMOCHA_TAG.tar.gz \
    https://github.com/bcoin-org/bmocha/archive/$BMOCHA_TAG.tar.gz
move bmocha_$BMOCHA_TAG.tar.gz

# node gyp has js deps that need to be installed first
get_release node-gyp_$NODE_GYP_TAG.tar.gz \
    https://github.com/nodejs/node-gyp/archive/$NODE_GYP_TAG.tar.gz

tar -xvf node-gyp_$NODE_GYP_TAG.tar.gz --remove-files >/dev/null
(
    cd node-gyp-$(remove_v $NODE_GYP_TAG)
    npm install
)
tar -cvf node-gyp_$NODE_GYP_TAG.tar.gz \
    --remove-files node-gyp-$(remove_v $NODE_GYP_TAG) >/dev/null
move node-gyp_$NODE_GYP_TAG.tar.gz

cp -rf vendor $OUTDIR/
cp -rf test $OUTDIR/
cp generate.js $OUTDIR/
mv $OUTFILE $OUTDIR/

cat <<EOF >$OUTDIR/install.sh
#!/bin/bash

tar -xvf $OUTFILE

# a bit of a hack, but works
sudo apt install -y -f ./\$(ls | grep build-essential)
sudo apt install -y -f ./\$(ls | grep nodejs)
rm *.deb

tar -xvf bcrypto_$BCRYPTO_TAG.tar.gz
tar -xvf bsert_$BSERT_TAG.tar.gz
tar -xvf bufio_$BUFIO_TAG.tar.gz
tar -xvf loady_$LOADY_TAG.tar.gz
tar -xvf bmocha_$BMOCHA_TAG.tar.gz
tar -xvf node-gyp_$NODE_GYP_TAG.tar.gz

mkdir -p \$HOME/.node_modules

cp -rf bcrypto-$(remove_v $BCRYPTO_TAG) \$HOME/.node_modules/bcrypto
cp -rf bsert-$(remove_v $BSERT_TAG) \$HOME/.node_modules/bsert
cp -rf bufio-$(remove_v $BUFIO_TAG) \$HOME/.node_modules/bufio
cp -rf loady-$(remove_v $LOADY_TAG) \$HOME/.node_modules/loady
cp -rf bmocha-$(remove_v $BMOCHA_TAG) \$HOME/.node_modules/bmocha
cp -rf node-gyp-$(remove_v $NODE_GYP_TAG) \$HOME/.node_modules/node-gyp

(
    cd \$HOME/.node_modules/bcrypto
    \$HOME/.node_modules/node-gyp/bin/node-gyp.js rebuild
)

\$HOME/.node_modules/bmocha/bin/bmocha ./test/*.js
EOF

