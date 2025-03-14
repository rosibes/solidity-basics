// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract OrganDonation is ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _donorIds;   // Contor pentru Donatori
    Counters.Counter private _patientIds; // Contor pentru Pacienți

    struct Patient {
        string name;
        uint256 age;
        string organNeeded;
    }

    struct Donor {
        string name;
        uint256 age;
        string organDonated;
    }

    mapping(uint256 => Patient) private patients;
    mapping(uint256 => Donor) private donors;
    
    // Mapping pentru a lega ID-urile NFT-urilor de ID-ul pacientului/donatorului
    mapping(uint256 => uint256) private nftToPatientId;
    mapping(uint256 => uint256) private nftToDonorId;

    event DonationApproved(uint256 donorId, uint256 patientId);

    constructor() ERC721("OrganDonationNFT", "ODNFT") {}

    // Mint pentru Donator
    function mintDonorNFT(string memory _name, uint256 _age, string memory _organ) public returns (uint256) {
        _donorIds.increment();
        uint256 donorId = _donorIds.current();

        uint256 nftId = donorId; // Același ID pentru NFT și donator
        _mint(msg.sender, nftId);
        _setTokenURI(nftId, _organ);

        donors[donorId] = Donor(_name, _age, _organ);
        nftToDonorId[nftId] = donorId; // Legăm NFT-ul de ID-ul donatorului

        return nftId;
    }

    // Mint pentru Pacient
    function mintPatientNFT(string memory _name, uint256 _age, string memory _organNeeded) public returns (uint256) {
        _patientIds.increment();
        uint256 patientId = _patientIds.current();

        uint256 nftId = patientId + 10_000; // Ca să evităm coliziunea cu donatorii
        _mint(msg.sender, nftId);
        _setTokenURI(nftId, _organNeeded);

        patients[patientId] = Patient(_name, _age, _organNeeded);
        nftToPatientId[nftId] = patientId; // Legăm NFT-ul de ID-ul pacientului

        return nftId;
    }

    function getPatientInfo(uint256 nftId) public view returns (string memory, uint256, string memory) {
        uint256 patientId = nftToPatientId[nftId]; // Găsim ID-ul pacientului
        require(patientId > 0, "Pacient inexistent!"); // Dacă nu există, dăm eroare

        Patient memory patient = patients[patientId];
        return (patient.name, patient.age, patient.organNeeded);
    }

    function getDonorInfo(uint256 nftId) public view returns (string memory, uint256, string memory) {
        uint256 donorId = nftToDonorId[nftId]; // Găsim ID-ul donatorului
        require(donorId > 0, "Donator inexistent!"); // Dacă nu există, dăm eroare

        Donor memory donor = donors[donorId];
        return (donor.name, donor.age, donor.organDonated);
    }
}
