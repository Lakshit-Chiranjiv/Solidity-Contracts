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
        bool onSale;
    }

    Blog[] blogList;

    mapping(uint => address) blogOwners;

    function readBlog(uint blogId) public {
        payable(blogOwners[blogId]).transfer(blogReadEarning);
    }

    function createBlog(string memory _blogTitle,string memory _blogBody,uint _salePrice,bool _onSale) public{
        blogList.push(Blog(blogCount,_blogTitle,_blogBody,0,_salePrice,_onSale));
        blogOwners[blogCount] = msg.sender;
        blogCount++;
    }

    function putBlogOnSale(uint blogId) public{
        blogList[blogId].onSale = true;
    }

    function getAllBlogs() public view returns(Blog[] memory){
        return blogList;
    }

    receive () external payable{} 

}