// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPatientRegistry {
    function getPatient(address _patient) external view returns (
        address wallet,
        string memory name,
        string memory bloodGroup,
        string memory neededOrgan
    );
}

interface IOrganNFT {
    function transferFrom(address from, address to, uint256 tokenId) external;
    function getOrganDetails(uint256 tokenId) external view returns (
        string memory organType,
        string memory bloodCompatibility
    );
    function ownerOf(uint256 tokenId) external view returns (address);
    function approve(address to, uint256 tokenId) external; // ✅ Adăugat approve()
    function getApproved(uint256 tokenId) external view returns (address); // ✅ Verificare aprobare
}

contract OrganEscrow {
    address public doctor;
    IPatientRegistry public patientRegistry;
    IOrganNFT public organNFT;

    struct Escrow {
        address donor;
        address patient;
        uint256 tokenId;
        bool approvedByDoctor;
    }

    mapping(uint256 => bool) public donorApproved;
    Escrow[] public escrows;

    event OrganEscrowCreated(uint256 indexed escrowId, address indexed donor, address indexed patient, uint256 tokenId);
    event OrganApprovedByDoctor(uint256 indexed escrowId);
    event OrganTransferred(uint256 indexed escrowId, address indexed recipient);

    modifier onlyDoctor() {
        require(msg.sender == doctor, "Only the doctor can approve transfers");
        _;
    }

    constructor(address _patientRegistry, address _organNFT) {
        doctor = msg.sender;
        patientRegistry = IPatientRegistry(_patientRegistry);
        organNFT = IOrganNFT(_organNFT);
    }

    function approveDonation(uint256 _tokenId) public {
        require(organNFT.ownerOf(_tokenId) == msg.sender, "Only the donor can approve");
        donorApproved[_tokenId] = true;
    }

    function createEscrow(address _patient, uint256 _tokenId) public {
        require(donorApproved[_tokenId], "Donor has not approved this organ");

        // 🔍 Verificăm datele pacientului
        (
            , // wallet
            ,
            string memory patientBloodGroup,
            string memory neededOrgan
        ) = patientRegistry.getPatient(_patient);

        require(bytes(neededOrgan).length > 0, "Patient does not exist");

        // 🔍 Verificăm datele organului
        (string memory organType, string memory organBloodGroup) = organNFT.getOrganDetails(_tokenId);

        // ⚠️ Asigurăm compatibilitatea între pacient și organ
        require(
            keccak256(abi.encodePacked(cleanString(neededOrgan))) == keccak256(abi.encodePacked(cleanString(organType))),
            "Organ type mismatch"
        );
        require(
            keccak256(abi.encodePacked(cleanString(patientBloodGroup))) == keccak256(abi.encodePacked(cleanString(organBloodGroup))),
            "Blood group mismatch"
        );

        // ✅ Verificăm dacă donatorul a aprobat contractul OrganEscrow pentru transfer
        require(organNFT.getApproved(_tokenId) == address(this), "Contract not approved for transfer");

        // 📌 Transferăm NFT-ul în contractul `OrganEscrow`
        organNFT.transferFrom(msg.sender, address(this), _tokenId);

        // 📌 Adăugăm escrow-ul în listă
        escrows.push(Escrow(msg.sender, _patient, _tokenId, false));
        emit OrganEscrowCreated(escrows.length - 1, msg.sender, _patient, _tokenId);
    }

    function approveTransfer(uint256 escrowId) public onlyDoctor {
        Escrow storage escrow = escrows[escrowId];
        require(!escrow.approvedByDoctor, "Transfer already approved");

        escrow.approvedByDoctor = true;
        emit OrganApprovedByDoctor(escrowId);

        organNFT.transferFrom(address(this), escrow.patient, escrow.tokenId);
        emit OrganTransferred(escrowId, escrow.patient);
    }

    function getEscrows() public view returns (Escrow[] memory) {
        return escrows;
    }

    function cleanString(string memory str) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(strBytes.length);
        uint256 j = 0;
        for (uint256 i = 0; i < strBytes.length; i++) {
            if (strBytes[i] != 0x20) { // Eliminăm spațiile (0x20 = ASCII pentru „ ”)
                result[j] = strBytes[i];
                j++;
            }
        }
        return string(result);
    }
}
