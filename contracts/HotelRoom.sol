pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT

contract HotelRoom{
    //Ether payments
    //Modifiers
    //Visibility
    //Events
    //Enums

    enum Statuses { 
        Vacant, 
        Ocupied
    }
    Statuses public currentStatus;

    event Occupy(address _occupant, uint _value);

    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
        currentStatus = Statuses.Vacant;
    }

    modifier onlyWhileVacant {
        require(currentStatus == Statuses.Vacant, "Currently occupied.");
        _;
    }

    modifier costs(uint _amount){
        require(msg.value >= _amount, "Not enough ether provided");
        _;
    }

    function book() public payable onlyWhileVacant costs(2 ether){
        currentStatus = Statuses.Ocupied;
         
         //incearca sa trimita suma msg.value catre adresa owner
         //verifica daca tranzactia a avut succes
        (bool sent, bytes memory data) = owner.call{value: msg.value}("");
        require(sent, "Failed to send Ether.");

        emit Occupy(msg.sender, msg.value);
    } 

    //functie pt a elibera camera
    function vacate() public {
    require(msg.sender == owner, "Only owner can vacate.");
    currentStatus = Statuses.Vacant;
}


}