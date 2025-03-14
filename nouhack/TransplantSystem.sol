// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TransplantNFT.sol";

contract TransplantSystem {
    TransplantNFT private nftContract;

  struct Patient {
    string name;
    string bloodGroup;
    string gender;
    string organNeeded;
    bool isApproved;
    address doctor;
    address patientAddress; // Adresa pacientului
}

struct Donor {
    string name;
    string bloodGroup;
    string gender;
    string organDonated;
    bool isApproved;
    address doctor;
    address donorAddress; // Adresa donatorului
}


    struct Doctor {
        string name;
        address doctorAddress;
    }

    struct Transplant {
        uint patientId;
        uint donorId;
        address doctor;
        bool isCompleted;
    }

    Patient[] public patients;
    Donor[] public donors;
    Doctor[] public doctors;
    Transplant[] public transplants;

    mapping(address => bool) public isDoctor;
    mapping(uint => bool) public isPatientApproved;
    mapping(uint => bool) public isDonorApproved;

    address public owner;

    constructor(address _nftContractAddress) {
        owner = msg.sender;
        nftContract = TransplantNFT(_nftContractAddress);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

   function addPatient(
    string memory _name,
    string memory _bloodGroup,
    string memory _gender,
    string memory _organNeeded
) public {
    patients.push(Patient({
        name: _name,
        bloodGroup: _bloodGroup,
        gender: _gender,
        organNeeded: _organNeeded,
        isApproved: false,
        doctor: address(0),
        patientAddress: msg.sender // Pacientul este cel care apelează funcția
    }));
}

function addDonor(
    string memory _name,
    string memory _bloodGroup,
    string memory _gender,
    string memory _organDonated
) public {
    donors.push(Donor({
        name: _name,
        bloodGroup: _bloodGroup,
        gender: _gender,
        organDonated: _organDonated,
        isApproved: false,
        doctor: address(0),
        donorAddress: msg.sender // Donatorul este cel care apelează funcția
    }));
}


    function addDoctor(string memory _name, address _doctorAddress) public onlyOwner {
        doctors.push(Doctor({
            name: _name,
            doctorAddress: _doctorAddress
        }));
        isDoctor[_doctorAddress] = true;
    }

    function approvePatient(uint _patientId, address _doctor) public {
        require(isDoctor[msg.sender], "Only doctors can approve patients.");
        patients[_patientId].isApproved = true;
        patients[_patientId].doctor = _doctor;

            isPatientApproved[_patientId] = true;

    }

    function approveDonor(uint _donorId, address _doctor) public {
        require(isDoctor[msg.sender], "Only doctors can approve donors.");
        donors[_donorId].isApproved = true;
        donors[_donorId].doctor = _doctor;

            isDonorApproved[_donorId] = true;

    }

function transferNFT(uint _patientId, uint _donorId) public {
    require(patients[_patientId].isApproved && donors[_donorId].isApproved, "Both patient and donor must be approved.");
    require(isDoctor[msg.sender], "Only doctors can approve transplant.");

    // Donatorul trebuie să aprobe transferul înainte
    require(nftContract.getApproved(_donorId) == patients[_patientId].patientAddress, "Donor must approve transfer.");

    // Transferă NFT-ul de la donator la pacient
    nftContract.safeTransferFrom(donors[_donorId].donorAddress, patients[_patientId].patientAddress, _donorId);
}

}