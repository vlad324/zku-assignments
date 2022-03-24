#!/bin/bash

# ./generate_witness.sh <output_dir> <input_json_file>
# ./generate_witness.sh output cards1.json

output_dir=$1
input_json_file=$2
witness_file="$output_dir"/witness.wtns

rm -f "$witness_file"

generate_witness_file=$(find "$1" -name "generate_witness.js")
wasm_file=$(find "$1" -name "*.wasm")

# generate witness
node "$generate_witness_file" "$wasm_file" "$input_json_file" "$witness_file"
