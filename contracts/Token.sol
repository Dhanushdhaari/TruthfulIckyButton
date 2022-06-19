//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Token {
    string private _name;
    string private _symbol;
    uint private _decimals;
    uint private _totalSupply;
    address private _owner;
    address private _admin;
    address private _burnAddress;
    address private _transferAddress;
    address private _mintAddress;
}

constructor() public {
    _name = "FiBerry"; 
    _symbol = "FIB";
    _decimals = 18;
    _totalSupply = 1000000000 * 10 ** _decimals;
    _owner = msg.sender;
    _admin = msg.sender;
    _burnAddress = msg.sender;
    _transferAddress = msg.sender;
    _mintAddress = msg.sender;
}

