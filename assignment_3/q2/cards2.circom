pragma circom 2.0.0;

/*
    Prove: I know (prevCard, newCard, salt, publicSalt) such that:
    - MiMCSponge(publicSalt, salt) = saltNullifier
    - prevCard != newCard
    - prevCard / 13 === newCard / 13, the cards are from the same suit
    - prevCard >= 0 && prevCard < 52
    - MiMCSponge(prevCard, salt) = prevCardCommitment
    - newCard >= 0 && newCard < 52
    - MiMCSponge(newCard, salt) = newCardCommitment
*/

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/mimcsponge.circom";
include "./cardcommitment.circom";

template Main() {

    signal input prevCard;
    signal input newCard;
    signal input salt;
    signal input publicSalt;

    signal output saltNullifier;
    signal output prevCardCommitment;
    signal output newCardCommitment;

    // calculate saltNullifier to prevent user from manipulation with salt
    component mimcSalt = MiMCSponge(2, 220, 1);
    mimcSalt.k <== 0;
    mimcSalt.ins[0] <== publicSalt;
    mimcSalt.ins[1] <== salt;

    saltNullifier <== mimcSalt.outs[0];

    // cards are not equal
    component isZero = IsZero();
    isZero.in <== newCard - prevCard;
    isZero.out === 0;

    // validate that card from the same suit:
    // 0 - 12 = 0,
    // 13 - 25 = 1,
    // 26 - 38 = 2,
    // 39 - 51 = 3
    signal prevSuit;
    prevSuit <== prevCard \ 13;
    signal newSuit;
    newSuit <== newCard \ 13;

    prevSuit === newSuit;

    // calculate previous card commitment
    component cc1 = CardCommitment();
    cc1.card <== prevCard;
    cc1.salt <== salt;
    prevCardCommitment <== cc1.cardCommitment;

    // calculate new card commitment
    component cc2 = CardCommitment();
    cc2.card <== newCard;
    cc2.salt <== salt;
    newCardCommitment <== cc2.cardCommitment;
}

component main {public [publicSalt]} = Main();