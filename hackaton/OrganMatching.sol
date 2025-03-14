// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TransplantRegistry.sol";

contract OrganMatching {

    struct Donor {
        uint id;
        string name;
        string bloodType;
        bool available;
    }

    address public owner;
    uint public donorCount = 0;

    mapping(uint => Donor) public donors;
    mapping(uint => uint) public transplants; // pacientId -> donorId

    TransplantRegistry public transplantRegistry;

    event DonorRegistered(uint id, string name, string bloodType);
    event MatchFound(uint patientId, string patientName, uint donorId, string donorName);
    event TransplantConfirmed(uint patientId, uint donorId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Doar owner-ul poate modifica datele!");
        _;
    }

    constructor(address _transplantRegistryAddress) {
        transplantRegistry = TransplantRegistry(_transplantRegistryAddress);
        owner = msg.sender;
    }

    // Înregistrează un donator
    function registerDonor(string memory _name, string memory _bloodType) public onlyOwner {
        donorCount++;
        donors[donorCount] = Donor(donorCount, _name, _bloodType, true);
        emit DonorRegistered(donorCount, _name, _bloodType);
    }

    // Găsește un pacient compatibil și asociază donatorul
    function findMatch(uint donorId) public onlyOwner returns (uint) {
        require(donorId > 0 && donorId <= donorCount, "Donator inexistent!");
        require(donors[donorId].available, "Donator nu este disponibil!");

        for (uint i = 1; i <= transplantRegistry.patientCount(); i++) {
            (string memory patientName, string memory patientBlood, uint urgency, ) = transplantRegistry.getPatient(i);
            
            if (keccak256(abi.encodePacked(patientBlood)) == keccak256(abi.encodePacked(donors[donorId].bloodType))) {
                donors[donorId].available = false; // Marcare donator ca utilizat
                transplants[i] = donorId; // Salvăm potrivirea
                emit MatchFound(i, patientName, donorId, donors[donorId].name);
                return i; // Returnează ID-ul pacientului compatibil
            }
        }

        revert("Nicio potrivire gasita!");
    }
    
    

       function getTransplantInfo(uint patientId) public view returns (uint donorId, string memory donorName, string memory donorBlood) {
        require(transplants[patientId] != 0, "Pacientul nu a primit un transplant!");
        
        donorId = transplants[patientId];
        Donor memory donor = donors[donorId];

        return (donor.id, donor.name, donor.bloodType);
    }

    
}
