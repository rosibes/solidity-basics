// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import  {SimpleStorage} from "./SimpleStorage.sol";

contract StorageFactory{
    SimpleStorage[] public listOfSimpleStorageContracts;

    function createSimpleStorageContract() public {
        SimpleStorage newSimpleStorageContract = new SimpleStorage();
        listOfSimpleStorageContracts.push(newSimpleStorageContract);
    }

    function sfStore(uint256 _simpleStoreIndex, uint256 _newSimpleStoreNumber) public {
      listOfSimpleStorageContracts[_simpleStoreIndex].store(_newSimpleStoreNumber);
    }

    function sfGet(uint256 _simpleStoreIndex)public view returns (uint256){
        return listOfSimpleStorageContracts[_simpleStoreIndex].retrieve();
    }
}