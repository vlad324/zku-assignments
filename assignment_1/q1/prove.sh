#!/bin/bash

# example ./prove.sh output merkle_tree

# start a new "powers of tau" ceremony
snarkjs powersoftau new bn128 15 ./$1/pot12_0000.ptau -v

# contribute to the ceremony
openssl rand -hex 20 | snarkjs powersoftau contribute ./$1/pot12_0000.ptau ./$1/pot12_0001.ptau --name="First contribution" -v

# prepare to phase 2
snarkjs powersoftau prepare phase2 ./$1/pot12_0001.ptau ./$1/pot12_final.ptau -v

# generate verification keys
snarkjs groth16 setup ./$1/$2.r1cs ./$1/pot12_final.ptau ./$1/verification_key_0000.zkey

# contribute to the key
openssl rand -hex 20 | snarkjs zkey contribute ./$1/verification_key_0000.zkey ./$1/verification_key_0001.zkey --name="1st Contributor Name" -v

# export verification_key.json
snarkjs zkey export verificationkey ./$1/verification_key_0001.zkey ./$1/verification_key.json

# generate proof
snarkjs groth16 prove ./$1/verification_key_0001.zkey ./$1/witness.wtns ./$1/proof.json ./$1/public.json

# verify proof
snarkjs groth16 verify ./$1/verification_key.json ./$1/public.json ./$1/proof.json
