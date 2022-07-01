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
        address blogOwner;
        address blogCreator;
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
        blogList.push(Blog(blogCount,msg.sender,msg.sender,_blogTitle,_blogBody,0,_salePrice,_onSale));
        blogOwners[blogCount] = msg.sender;
        blogCount++;
    }

    function putBlogOnSale(uint blogId) public{
        blogList[blogId].onSale = true;
    }

    function removeBlogFromSale(uint blogId) public{
        blogList[blogId].onSale = false;
    }

    function buyBlog(uint blogId) public payable{
        //require msg.value for blog amount
        payable(blogList[blogId].blogOwner).transfer(blogList[blogId].salePrice - (1 ether));
        payable(contractOwner).transfer(1 ether);
        blogList[blogId].blogOwner = msg.sender;
    }

    function getABlog(uint blogId) public view returns(Blog memory){
        return blogList[blogId];
    }

    function getAllBlogs() public view returns(Blog[] memory){
        return blogList;
    }

    receive () external payable{} 

}