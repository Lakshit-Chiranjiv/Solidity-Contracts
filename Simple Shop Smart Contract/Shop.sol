// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Shop{
    address payable public owner;
    uint public itemCount;
    uint public salesAmount;

    struct Item{
        uint id;
        string name;
        uint price;
        address itemOwner;
        bool sold;
    }

    mapping(uint => Item) public itemList;

    constructor(){
        owner = payable(msg.sender);
        itemCount = 0;//optional
    }

    modifier onlyOwner() {
        require(msg.sender == owner,"Only owner can call this function");
        _;
    }

    function addItem(string memory _name,uint _price) onlyOwner public{
        itemCount++;
        itemList[itemCount] = Item(itemCount,_name,(_price * 1 ether),owner,false);
    }
}