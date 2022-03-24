pragma circom 2.0.0;

/*
    Prove: I know (A, B, C, e) such that:
    - they make triangle
    - (A[0] - B[0])^2 + (A[1] - B[1])^2 <= e^2 | can go from A to B with provided engergy
    - (B[0] - C[0])^2 + (B[1] - C[1])^2 <= e^2 | can go from B to C with provided engergy
    - MiMCSponge(A[0],A[1]) = pub1
    - MiMCSponge(B[0],B[1]) = pub2
    - MiMCSponge(C[0],C[1]) = pub3
*/

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/mimcsponge.circom";

/*
    Checks that square of triangle S is not 0
    2 * S = | (B[0] - A[0]) * (C[1] - A[1]) - (C[0] - A[0]) * (B[1] - A[1]) |
*/
template CheckTriangle() {
    signal input A[2];
    signal input B[2];
    signal input C[2];

    signal i;
    i <== (B[0] - A[0]) * (C[1] - A[1]);
    signal j;
    j <== (C[0] - A[0]) * (B[1] - A[1]);

    // todo: is it safe to work with negative numbers?

    component isz = IsZero();
    isz.in <== i - j;
    isz.out === 0; // is not zero 
}

template DistanceLessThenOrEqual() {
    signal input start[2];
    signal input end[2];
    signal input d;

    signal dx;
    signal dy; 
    dx <== end[0] - start[0];
    dy <== end[1] - start[1];

    signal dxSq;
    signal dySq;
    signal dSq;
    dxSq <== dx * dx;
    dySq <== dy * dy;
    dSq <== d * d;

    component lessThan = LessThan(32); // why 32?
    lessThan.in[0] <== dxSq + dySq;
    lessThan.in[1] <== dSq + 1;
    lessThan.out === 1;
}

template Main() {

    signal input A[2];
    signal input B[2];
    signal input C[2];

    signal input e;

    signal output pub[3];

    // todo: validate bounds for A, B, C

    // check triangle
    component checkTriangle = CheckTriangle();
    checkTriangle.A[0] <== A[0];
    checkTriangle.A[1] <== A[1];
    checkTriangle.B[0] <== B[0];
    checkTriangle.B[1] <== B[1];
    checkTriangle.C[0] <== C[0];
    checkTriangle.C[1] <== C[1];

    // check energy A -> B
    component checkAB = DistanceLessThenOrEqual();
    checkAB.start[0] <== A[0];
    checkAB.start[1] <== A[1];
    checkAB.end[0] <== B[0];
    checkAB.end[1] <== B[1];
    checkAB.d <== e;

    // check energy B -> C
    component checkBC = DistanceLessThenOrEqual();
    checkBC.start[0] <== B[0];
    checkBC.start[1] <== B[1];
    checkBC.end[0] <== C[0];
    checkBC.end[1] <== C[1];
    checkBC.d <== e;

    // hashes
    component mimc1 = MiMCSponge(2, 220, 1);
    mimc1.ins[0] <== A[0];
    mimc1.ins[1] <== A[1];
    mimc1.k <== 0;
    pub[0] <== mimc1.outs[0];

    component mimc2 = MiMCSponge(2, 220, 1);
    mimc2.ins[0] <== B[0];
    mimc2.ins[1] <== B[1];
    mimc2.k <== 0;
    pub[1] <== mimc2.outs[0];

    component mimc3 = MiMCSponge(2, 220, 1);
    mimc3.ins[0] <== C[0];
    mimc3.ins[1] <== C[1];
    mimc3.k <== 0;
    pub[2] <== mimc3.outs[0];
}

component main {public [e]} = Main();