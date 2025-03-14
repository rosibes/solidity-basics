// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract OrganDonation {
    struct Patient {
        string name;
        string gender;
        string bloodType;
        string neededOrgan;
        address patientAddress;
    }

    mapping(address => Patient) public patients;
    address[] public patientList;

    event PatientRegistered(address patient, string organNeeded);

    function registerPatient(
        string memory _name,
        string memory _gender,
        string memory _bloodType,
        string memory _neededOrgan
    ) public {
        require(patients[msg.sender].patientAddress == address(0), "Patient already registered");

        patients[msg.sender] = Patient(_name, _gender, _bloodType, _neededOrgan, msg.sender);
        patientList.push(msg.sender);

        emit PatientRegistered(msg.sender, _neededOrgan);
    }

    function getPatient(address patient) public view returns (string memory, string memory, string memory, string memory, address) {
        Patient memory p = patients[patient];
        return (p.name, p.gender, p.bloodType, p.neededOrgan, p.patientAddress);
    }

    function getAllPatients() public view returns (address[] memory) {
        return patientList;
    }
}
