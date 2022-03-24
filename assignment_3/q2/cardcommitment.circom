pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/mimcsponge.circom";

/*
    Verifies the card (0 <= card < 52) and
    generates commitment for it (MiMCSponge(card, salt) = cardCommitment).
*/
template CardCommitment() {

    signal input card;
    signal input salt;

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

    // calculate card commitment
    component mimc = MiMCSponge(2, 220, 1);
    mimc.k <== 0;
    mimc.ins[0] <== card;
    mimc.ins[1] <== salt;

    cardCommitment <== mimc.outs[0];
}