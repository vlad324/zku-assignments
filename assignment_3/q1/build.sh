#!/bin/bash

# example ./build.sh triangle_move input.json

# cleanup
rm -rf ./output

# create output directory
mkdir output
chmod 755 output

# compile circuit
circom $1.circom --output ./output --r1cs --wasm

# computing the witness
node ./output/$1_js/generate_witness.js ./output/$1_js/$1.wasm $2 ./output/witness.wtns