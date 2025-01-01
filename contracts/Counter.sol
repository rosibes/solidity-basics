pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT
contract Counter{
    uint public count = 0;

    
    function incrementCount() public{
        count++;
    }
}

