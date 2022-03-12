pragma circom 2.0.0;

include "mimcsponge.circom";

template HashValues(n) {
    signal input values[n];
    signal output out;

    component mimc = MiMCSponge(n, 220, 1);
    mimc.k <== 0;
    for (var i = 0; i < n; i++) {
        mimc.ins[i] <== values[i];
    }

    out <== mimc.outs[0];
}

template MerkleTree(n) {  

    signal input leaves[n];
    signal output root;

    0 === n & (n - 1); // verify that provided n is power of 2

    var hashesLength = 2 * n - 1; // `n` for inital hashes of leaves, plus `n - 1` for a tree
    component hashes[hashesLength]; 
    for (var i = 0; i < hashesLength; i++) {
        if (i < n) {
            hashes[i] = HashValues(1);

            hashes[i].values[0] <== leaves[i];
        } else {
            hashes[i] = HashValues(2);

            var k = i - n;
            hashes[i].values[0] <== hashes[k].out;
            hashes[i].values[1] <== hashes[k + 1].out;
        }
    }

    root <== hashes[hashesLength - 1].out;
}

component main {public [leaves]} = MerkleTree(8);