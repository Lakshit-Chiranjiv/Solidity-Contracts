// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Decentralized_Blog_App{

    address payable contractOwner;
    uint blogReadEarning;
    uint blogCount;

    constructor() payable{
        contractOwner = payable(msg.sender);
        blogReadEarning = 1 ether;
    }

    struct Blog{
        uint blogId;
        string blogTitle;
        string blogBody;
        uint numOfReads;
        uint salePrice;
    }

    mapping(uint => address) blogOwners;

}