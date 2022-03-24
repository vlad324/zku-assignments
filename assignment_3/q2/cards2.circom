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

template Card() {

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
    component mimcCard = MiMCSponge(2, 220, 1);
    mimcCard.k <== 0;
    mimcCard.ins[0] <== card;
    mimcCard.ins[1] <== salt;

    cardCommitment <== mimcCard.outs[0];
}

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
    component card1 = Card();
    card1.card <== prevCard;
    card1.salt <== salt;
    prevCardCommitment <== card1.cardCommitment;

    // calculate new card commitment
    component card2 = Card();
    card2.card <== newCard;
    card2.salt <== salt;
    newCardCommitment <== card2.cardCommitment;
}

component main {public [publicSalt]} = Main();