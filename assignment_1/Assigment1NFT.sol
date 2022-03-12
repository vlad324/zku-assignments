// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MyNFT is ERC721URIStorage {
    uint256 private _maxCount;
    uint256 private _tokenCounter = 0;
    bytes32[] private _merkleTree;
    uint256 _levels;

    constructor(uint256 maxCount) ERC721("MyNFT", "MNFT") {
        require(maxCount > 0, "maxCount should be greater than 0");
        require(maxCount & (maxCount - 1) == 0, "maxCount is not power of 2");
        _maxCount = maxCount;
        _merkleTree = new bytes32[](2 * maxCount - 1);
    }

    function mint(address receiver, string memory tokenURI) public returns (uint256) {
        uint256 tokenId = _tokenCounter++;

        require(tokenId < _maxCount, "All supply is minted");

        _safeMint(receiver, tokenId);
        _setTokenURI(tokenId, tokenURI);

        updateMerkleTree(msg.sender, receiver, tokenId, tokenURI);

        return tokenId;
    }

    function updateMerkleTree(address msgSender, address receiver, uint256 tokenId, string memory tokenURI) private {
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, receiver, tokenId, tokenURI));

        uint256 i = tokenId;
        while (i < _merkleTree.length) {
            // write current hash
            _merkleTree[i] = hash;
            if (i == _merkleTree.length - 1) {
                return;
            }

            // calculate next hash
            if (i % 2 == 0) {
                hash = keccak256(abi.encodePacked(hash, _merkleTree[i + 1]));
            } else {
                hash = keccak256(abi.encodePacked(_merkleTree[i - 1], hash));
            }

            // calculate next index
            i = _maxCount + i / 2;
        }
    }
}
