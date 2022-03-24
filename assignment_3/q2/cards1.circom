pragma circom 2.0.0;

/*
    Prove: I know (card, salt, publicSalt) such that:
    - card >= 0 && card < 52
    - MiMCSponge(publicSalt, salt) = saltNullifier
    - MiMCSponge(card, salt) = cardCommitment
*/

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/mimcsponge.circom";

template Main() {

    signal input card;
    signal input salt;
    signal input publicSalt;

    signal output saltNullifier;
    signal output cardCommitment;

    // check card is valid
    component greaterThanOrEqualTo0 = LessThan(6);
    greaterThanOrEqualTo0.in[0] <== 0;
    greaterThanOrEqualTo0.in[1] <== card + 1;
    greaterThanOrEqualTo0.out === 1;

    component lessThan52 = LessThan(6);
    lessThan52.in[0] <== card;
    lessThan52.in[1] <== 52;
    lessThan52.out === 1;

    // calculate saltNullifier to prevent user from manipulation with salt
    component mimcSalt = MiMCSponge(2, 220, 1);
    mimcSalt.k <== 0;
    mimcSalt.ins[0] <== publicSalt;
    mimcSalt.ins[1] <== salt;

    saltNullifier <== mimcSalt.outs[0];

    // calculate card commitment
    component mimcCard = MiMCSponge(2, 220, 1);
    mimcCard.k <== 0;
    mimcCard.ins[0] <== card;
    mimcCard.ins[1] <== salt;

    cardCommitment <== mimcCard.outs[0];
}

component main {public [publicSalt]} = Main();