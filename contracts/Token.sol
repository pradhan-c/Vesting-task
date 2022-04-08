// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

//Create Total supply of 100 million in counstructor.
//The name of the token is  PillowToken and the symbol is PILW

contract Token is ERC20 {
    constructor(
        string memory name,
        string memory symbol,
        uint256 intialsupply
    ) ERC20(name, symbol) {
        // 1 dollar = 100 cents i.e 1 token = 1 * (10 ** decimals)
        // _mint(msg.sender, 100 * 10**uint(decimals()));
        _mint(msg.sender, intialsupply);
    }
}
