// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PatientRegistry {
    struct Patient {
        address wallet;
        string name;
        string bloodGroup;
        string neededOrgan;
    }

    mapping(address => Patient) public patients;

    function registerPatient(string memory _name, string memory _bloodGroup, string memory _neededOrgan) public {
        patients[msg.sender] = Patient(msg.sender, _name, _bloodGroup, _neededOrgan);
    }

    function getPatient(address _patient) public view returns (Patient memory) {
        return patients[_patient];
    }
}
