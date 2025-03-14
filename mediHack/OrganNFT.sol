// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract OrganNFT is ERC721URIStorage {
    uint256 public nextTokenId;
    address public admin;

    struct Organ {
        string organType;
        string bloodCompatibility;
    }

    mapping(uint256 => Organ) public organDetails;

    constructor() ERC721("OrganNFT", "ORG") {
        admin = msg.sender;
    }

    function mintOrgan(string memory _organType, string memory _bloodCompatibility) public {
        uint256 tokenId = nextTokenId;
        _safeMint(msg.sender, tokenId);
        organDetails[tokenId] = Organ(_organType, _bloodCompatibility);
        nextTokenId++;
    }

    function getOrganDetails(uint256 tokenId) public view returns (Organ memory) {
        return organDetails[tokenId];
    }
}
