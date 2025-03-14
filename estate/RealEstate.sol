//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

//ca sa pot pune link cu URI(detalii despre nft - imag,text etc)
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
//stadardul de baza pt tokeni NFT
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
//un utilitar pentru a ține evidența unui număr care crește automat.
import "@openzeppelin/contracts/utils/Counters.sol";

contract RealEstate is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("Real Estate", "REAL") {} //numele colectiei de nft si simbolul

    function mint(string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current(); //cumva tine si numarul de nfturi din colectie
        _mint(msg.sender, newItemId); //functie din ERC721
        _setTokenURI(newItemId, tokenURI); //la fel

        return newItemId; //id ul tokenului creat
    }

    function totalSupply() public view returns (uint256) {
        return _tokenIds.current();
    }
}
