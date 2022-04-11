// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


//The name of the token is  PillowToken and the symbol is PILW

contract Token is ERC20 {
    constructor(
        string memory name,
        string memory symbol,
        uint256 intialsupply
    ) ERC20(name, symbol) {
        
        _mint(msg.sender, intialsupply);
    }
}
