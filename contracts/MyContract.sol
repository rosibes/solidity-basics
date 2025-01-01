pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT

contract MyContract {
//     //-------- Variables, Data Types ------
//     //State Variables
//     int256 public myInt = 1;
//     uint public myUint= 1;
//     uint256 public myUint256 = 1;
//     uint8 public myUint8 = 1;

//     string public myString = "Hello, World!";
    
//     //tot un string, doar ca un fel de array dinamic
//     bytes32 public myBites32 = "Hello, world!";


//     address public myAddress = 0x617F2E2fD72FD9D5503197092aC168c91465E7f2;

//     struct MyStruct {
//         uint256 myUint256;
//         string myString;
//     }

//     MyStruct public myStruct = MyStruct(1, "Hello");

//     //Local Variables
//     // Pure - it doesn't modify the blockchain,doesnt' mutate anything, just fetches infos
//     function getValue() public pure returns(uint){
//         uint value = 1;
//         return value;
//     }

// //----------- Arrays ---------
//     uint[] public uintArray = [1,2,3];
//     string[] public stringArray = ["apple", "banana", "carrot"];
//     string[] public values;
//     uint256[][] public array2D = [[1,2,3], [4,5,6]]; 

//     function addValue(string memory _value) public{
//         values.push(_value);
//     }

//     function valueCount() public view returns(uint){
//         return values.length;
//     }

//------------Mappins---------
    mapping(uint => string) public names;
    mapping(uint => Book) public books;
    mapping(address => mapping(uint => Book)) public myBooks;

    struct Book {
        string title;
        string author;
    }



    constructor() {
        names[1] = "Adam";
        names[2] = "Bruce";
        names[3] = "Carl";
    }

  function addBook(
        uint _id, 
        string memory _title,
         string memory _author
         ) public {
        books[_id] = Book(_title, _author);
    }
    function addMyBook(
        uint _id, 
        string memory _title,
         string memory _author
         ) public {
        myBooks[msg.sender][_id] = Book(_title, _author);
    }
}