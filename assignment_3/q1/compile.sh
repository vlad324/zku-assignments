#!/bin/bash

# example ./compile.sh triangle_move.circom

# cleanup
rm -rf ./output

# create output directory
mkdir output
chmod 755 output

# compile circuit
circom "$1" --output ./output --r1cs --wasm