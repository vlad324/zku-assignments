#!/bin/bash

# example ./compile.sh cards1.circom

# cleanup
rm -rf ./output

# create output directory
mkdir output
chmod 744 output

# compile circuit
circom "$1" --output ./output --r1cs --wasm