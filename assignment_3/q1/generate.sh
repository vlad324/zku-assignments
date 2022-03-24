#!/bin/bash

# ./generate.sh <output_dir> <ptau_file>

output_dir=$1
ptau_file=$2

public_json_file="$output_dir"/public.json
proof_json_file="$output_dir"/proof.json
zkey_file="$output_dir"/verification_key_final.zkey

# cleanup
rm "$output_dir"/*.zkey
rm "$proof_json_file"
rm "$public_json_file"

# locate required files
r1cs_file=$(find "$1" -name "*.r1cs")
wasm_file=$(find "$1" -name "*.wasm")

# generate verification keys
snarkjs groth16 setup "$r1cs_file" "$ptau_file" "$output_dir"/verification_key_0000.zkey

# contribute to the key
openssl rand -hex 20 | snarkjs zkey contribute \
  "$output_dir"/verification_key_0000.zkey "$zkey_file" --name="1st Contributor Name" -v

# generate proof
snarkjs groth16 fullprove input.json "$wasm_file" "$zkey_file" "$proof_json_file" "$public_json_file"

# generate smart contract verifier
snarkjs zkey export solidityverifier "$zkey_file" Verifier.template.sol

# generate call data
snarkjs zkey export soliditycalldata "$public_json_file" "$proof_json_file" >> call_data.txt
