// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Verifier.sol";

contract Game is Verifier {

    mapping(address => uint256[]) visitedPlanets;
    uint256 public energyLimit = 10;

    function triangleMove(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[4] memory input
    ) public {
        uint256 B = input[1];
        uint256 C = input[2];
        uint256 energy = input[3];

        require(energy <= energyLimit, "Used energy above the limit");
        require(verifyProof(a, b, c, input), "Triangle move is not valid");

        visitedPlanets[msg.sender].push(B);
        visitedPlanets[msg.sender].push(C);
    }
}