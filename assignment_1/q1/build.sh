#!/bin/bash

# example ./build.sh merkle_tree input.json

# cleanup
rm -rf ./output

# create output directory
mkdir output
chmod 755 output

# compile circuit
## --json       outputs the constraints in json format
## --r1cs       outputs the constraints in r1cs format
## --wasm       compiles the circuit to wasm
## --sym        outputs witness in sym format
## --c          Compiles the circuit to c
circom $1.circom --output ./output --r1cs --wasm

# computing the witness
node ./output/$1_js/generate_witness.js ./output/$1_js/$1.wasm $2 ./output/witness.wtns