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
}