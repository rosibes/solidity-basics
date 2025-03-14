//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint256 _id
    ) external;
}

contract Escrow {
    address public nftAddress;
    address payable public seller;
    address public lender;
    address public inspector;

    mapping(uint256 => bool) public isListed;
    mapping(uint256 => uint256) public purchasePrice;
    mapping(uint256 => uint256) public escrowAmount;
    mapping(uint256 => address) public buyer;
    mapping(uint256 => bool) public inspectionPassed;
    //address e adresa celui a da aproba (trb sa aprobe buyerul, sellerul si lenderul)
    mapping(uint256 => mapping(address => bool)) public approval;
    mapping(address => uint256) public deposits;


    constructor(
        address _nftAddress,
        address payable _seller,
        address _lender,
        address _inspector
    ){
        nftAddress = _nftAddress;
        seller = _seller;
        lender = _lender;
        inspector = _inspector;
    }

    modifier onlySeller() {
        require(msg.sender == seller, "Only seller cand call this method");
        _;
    }

    modifier onlyBuyer(uint256 _nftID) {
        require(msg.sender == buyer[_nftID], "Only buyer can call this method(down payment)");
        _;
    }

    modifier onlyInspector() {
        require(msg.sender == inspector, "Only inspector can call this method");
        _;
    }

    function list(
        uint256 _nftID, 
        address _buyer,
        uint256 _purchasePrice,
        uint256 _escrowAmount
         ) public payable onlySeller(){
        //tranfera NFT de la seller(msg.sender - cel care apeleaza functia de sell) , la contractul curent-Escrow(address.this), tokenul
        IERC721(nftAddress).transferFrom(msg.sender, address(this), _nftID);

        isListed[_nftID] = true;
        purchasePrice[_nftID] = _purchasePrice;
        escrowAmount[_nftID] = _escrowAmount;
        buyer[_nftID] = _buyer;
    }


    function deposit() public payable {
    deposits[msg.sender] += msg.value;
    }


    //Put Under Contract (only buyer - payable escrow)  (ca un DownPayment)
    function depositEarnest(uint256 _nftID) public payable onlyBuyer(_nftID) {
        require(msg.value >= escrowAmount[_nftID], "Insufficient Funds");
    }

    //Update Inspection Status (only inspector)
    function updateInspectionStatus(uint256 _nftID, bool _passed) public onlyInspector{
        inspectionPassed[_nftID] = _passed;
    }

    //Aprove Sale
    function approveSale(uint256 _nftID) public {
        approval[_nftID][msg.sender] = true;
    }
    
    //Finalize Sale
    // -> Require inspection status 
    // -> Require sale to be authorized (approved)
    // -> Require Funds to be correct amount
    // -> Transfer NFT to Buyer
    // -> Transfer Funds to Seller
    function finalizeSale (uint256 _nftID) public {
        require(inspectionPassed[_nftID]);

        require(approval[_nftID][buyer[_nftID]]);
        require(approval[_nftID][seller]);
        require(approval[_nftID][lender]);

        isListed[_nftID] = false;

        // Verifică că escrow-ul are fondurile necesare pentru tranzacție
        require(address(this).balance >= purchasePrice[_nftID], "Insufficient funds - Escrow");

       (bool success, ) = payable(seller).call{value: address(this).balance}(" ");
       require(success);

        IERC721(nftAddress).transferFrom(address(this), buyer[_nftID], _nftID);
    }

    //Cancel Sale(handle earnest deposit)
    // -> if inspection status is not approved, then refund, otherwise send to seller
    function cancelSale(uint256 _nftID) public{
            if(inspectionPassed[_nftID] == false){
                uint256 refundAmount = deposits[buyer[_nftID]];
                deposits[buyer[_nftID]] = 0; // Resetează depozitul
                payable(buyer[_nftID]).transfer(refundAmount);
            } else {
                payable(seller).transfer(address(this).balance);
            }
        }

    receive() external payable{}

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

}
