// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract EcommerceStore{
    
    struct Product{
        string name;
        string desc;
        address payable seller;
        uint256 product_id;
        uint256 price;
        address buyer;
        bool delivered;
    }
    address payable public contract_manager;
    bool isContractDestroyed = false;
    constructor(){
        contract_manager = payable(msg.sender);
    }

    modifier isNotDestroyed{
        require(!isContractDestroyed,"contract destroyed");
        _;
    }

    uint256 id_var = 1;
    Product[] public registered_products;

    event product_registered(string name,uint256 id,address seller);
    event product_sold(uint256 id,address buyer);
    event product_delivered(uint256 id);

    function registerProduct(string memory pname,string memory pdesc,uint256 pprice) public isNotDestroyed{
        require(pprice>0,"price cannot be 0 or less");
        Product memory temp;
        temp.name = pname;
        temp.desc = pdesc;
        temp.price = pprice * 10**18;
        temp.seller = payable(msg.sender);
        temp.product_id = id_var;
        registered_products.push(temp);
        id_var++;
        emit product_registered(pname,id_var-1,msg.sender);
    } 

    function buyProduct(uint256 p_id) payable public isNotDestroyed{
        require(registered_products.length >= p_id,"no such product id exists");
        require(registered_products[p_id-1].price == msg.value,"please pay the exact price");
        require(msg.sender != registered_products[p_id-1].seller,"seller cannot buy this product");
        registered_products[p_id-1].buyer = msg.sender;
        emit product_sold(p_id,msg.sender);
    }

    function deliveryConfirmation(uint256 p_id) public isNotDestroyed{
        require(registered_products.length >= p_id,"no such product id exists");
        require(registered_products[p_id-1].buyer != address(0),"product not yet sold");
        require(registered_products[p_id-1].buyer == msg.sender,"none other than buyer can confirm delivery");
        registered_products[p_id-1].delivered = true;
        registered_products[p_id-1].seller.transfer(registered_products[p_id-1].price);
        emit product_delivered(p_id);
    }

    function destroyContract() public isNotDestroyed{
        require(msg.sender == contract_manager,"only manager can destroy contract");
        selfdestruct(contract_manager);
    }

    function destroyContract_betterWay() public isNotDestroyed{
        require(msg.sender == contract_manager,"only manager can destroy contract");
        contract_manager.transfer(address(this).balance);
        isContractDestroyed = true;
    }

    fallback() payable external{
        payable(msg.sender).transfer(msg.value);
    }

}