#!/bin/bash

# example ./prove.sh merkle_tree.r1cs

# start a new "powers of tau" ceremony
snarkjs powersoftau new bn128 15 pot12_0000.ptau -v

# contribute to the ceremony
openssl rand -hex 20 | snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v

# prepare to phase 2
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v

# generate verification keys
snarkjs groth16 setup $1 pot12_final.ptau verification_key_0000.zkey

# contribute to the key
openssl rand -hex 20 | snarkjs zkey contribute verification_key_0000.zkey verification_key_0001.zkey --name="1st Contributor Name" -v

# export verification_key.json
snarkjs zkey export verificationkey verification_key_0001.zkey verification_key.json

# generate proof
snarkjs groth16 prove verification_key_0001.zkey witness.wtns proof.json public.json

# verify proof
snarkjs groth16 verify verification_key.json public.json proof.json
