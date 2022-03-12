#!/bin/bash

# example ./build.sh merkle_tree input.json

# compile circuit
## --json       outputs the constraints in json format
## --r1cs       outputs the constraints in r1cs format
## --wasm       compiles the circuit to wasm
## --sym        outputs witness in sym format
## --c          Compiles the circuit to c

circom $1.circom --r1cs --wasm

# computing the witness
node ./$1_js/generate_witness.js ./$1_js/$1.wasm $2 witness.wtns