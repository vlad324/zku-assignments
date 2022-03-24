pragma circom 2.0.0;

/*
    Prove: I know (card, salt, publicSalt) such that:
    - MiMCSponge(publicSalt, salt) = saltNullifier
    - card >= 0 && card < 52
    - MiMCSponge(card, salt) = cardCommitment
    - card / 13 = cardRank
*/

include "../../node_modules/circomlib/circuits/mimcsponge.circom";
include "./cardcommitment.circom";

template Main() {

    signal input card;
    signal input salt;
    signal input publicSalt;

    signal output saltNullifier;
    signal output cardCommitment;
    signal output cardRank;

    // calculate saltNullifier to prevent user from manipulation with salt
    component mimcSalt = MiMCSponge(2, 220, 1);
    mimcSalt.k <== 0;
    mimcSalt.ins[0] <== publicSalt;
    mimcSalt.ins[1] <== salt;

    saltNullifier <== mimcSalt.outs[0];

    // calculate card commitment
    component cc = CardCommitment();
    cc.card <== card;
    cc.salt <== salt;
    cardCommitment <== cc.cardCommitment;

    // reveal card rank, but not suit
    cardRank <== card \ 13;
}

component main {public [publicSalt]} = Main();