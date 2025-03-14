// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TransplantRegistry {

    // Structura pentru un pacient
    struct Patient {
        uint id;
        string name;
        string gender;
        string bloodType;
        uint urgencyLevel; // Nivelul de urgență calculat automat
        uint waitingSince; // Timpul când pacientul a fost adăugat pe listă
    }

    address public owner; // Adresa owner-ului

    // Mappare pentru pacienți: id-ul pacientului => pacient
    mapping(uint => Patient) public patients;

    // Contor pentru numărul total de pacienți
    uint public patientCount = 0;

    // Eveniment pentru înregistrarea unui pacient
    event PatientRegistered(uint id, string name, string gender, string bloodType, uint urgencyLevel, uint waitingSince);

    // Eveniment pentru calculul nivelului de urgență
    event UrgencyLevelCalculated(uint id, uint newUrgencyLevel);

    // Modifier pentru a limita accesul la funcțiile sensibile (doar owner-ul poate modifica)
    modifier onlyOwner() {
        require(msg.sender == owner, "Numai owner-ul poate face aceasta operatiune");
        _;
    }

    // Constructor pentru a seta owner-ul
    constructor() {
        owner = msg.sender; // Owner este contractul sau administratorul
    }

    // Funcție pentru înregistrarea unui pacient pe lista de așteptare
    function registerPatient(string memory _name, string memory _gender, string memory _bloodType) public {
        patientCount++;
        uint urgency = _calculateUrgency(patientCount); // Calculăm automat nivelul de urgență
        patients[patientCount] = Patient(patientCount, _name, _gender, _bloodType, urgency, block.timestamp);

        // Emiterea evenimentului de înregistrare
        emit PatientRegistered(patientCount, _name, _gender, _bloodType, urgency, block.timestamp);

        // Emiterea evenimentului de calcul a nivelului de urgență
        emit UrgencyLevelCalculated(patientCount, urgency);
    }

    // Funcție pentru obținerea detaliilor unui pacient
    function getPatient(uint _id) public view returns (string memory, string memory, uint, uint) {
        // Verificăm dacă pacientul există
        require(_id > 0 && _id <= patientCount, "Pacientul nu exista!");

        // Returnăm datele pacientului
        Patient memory p = patients[_id];
        return (p.name, p.bloodType, p.urgencyLevel, p.waitingSince);
    }

    // Funcția de calcul al nivelului de urgență
    function _calculateUrgency(uint patientId) private view returns (uint) {
        // Calcul automat bazat pe datele pacientului (exemplu generic)
        return uint(keccak256(abi.encodePacked(block.timestamp, patients[patientId].name))) % 100;
    }

    // Funcție pentru a obține toți pacienții înregistrați
    function getAllPatients() public view returns (Patient[] memory) {
        Patient[] memory allPatients = new Patient[](patientCount);

        for (uint i = 0; i < patientCount; i++) {
            allPatients[i] = patients[i + 1]; // Adăugăm pacientul cu ID-ul corespunzător în array
        }

        return allPatients;
    }

    function getAllPatientIds() public view returns (uint[] memory) {
    uint[] memory ids = new uint[](patientCount);
    for (uint i = 0; i < patientCount; i++) {
        ids[i] = i + 1;
    }
    return ids;
}


}
