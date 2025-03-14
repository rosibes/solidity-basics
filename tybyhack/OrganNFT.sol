// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; // Importăm ERC721URIStorage
import "@openzeppelin/contracts/utils/Counters.sol"; // Importăm Counters pentru a gestiona ID-ul NFT-urilor

contract OrganNFT is ERC721URIStorage {
    using Counters for Counters.Counter; // Folosim Counters pentru a incrementa ID-ul token-ului
    Counters.Counter private _tokenIds; // Declarați un counter pentru ID-urile NFT-urilor

    constructor() ERC721("OrganNFT", "ORG") {
        // Constructorul ERC721 este apelat corect
    }

    // Funcția pentru a crea un NFT pentru organ
    function mintOrganNFT(string memory tokenURI) public returns (uint256) {
        _tokenIds.increment(); // Incrementăm ID-ul token-ului
        uint256 newItemId = _tokenIds.current(); // Obținem ID-ul curent
        _mint(msg.sender, newItemId); // Mințăm token-ul către adresa care a apelat funcția
        _setTokenURI(newItemId, tokenURI); // Setăm URI-ul token-ului
        return newItemId; // Returnăm ID-ul token-ului
    }

    // Funcția pentru a obține totalul NFT-urilor create
    function totalSupply() public view returns (uint256) {
        return _tokenIds.current();
    }
}