// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract IDO is ERC20, Ownable {
    uint256 public rate;
    uint256 public startTime;
    uint256 public endTime;

    event TokensPurchased(address indexed purchaser, uint256 amount);

    constructor(string memory name, string memory symbol, uint256 _rate, uint256 _startTime, uint256 _endTime, address _owner)
        ERC20(name, symbol)
        Ownable(_owner)
    {
        rate = _rate;
        startTime = _startTime;
        endTime = _endTime;
    }

    function buyTokens() public payable {
        require(block.timestamp >= startTime && block.timestamp <= endTime, "IDO is not active");
        uint256 tokenAmount = msg.value * rate;
        require(balanceOf(address(this)) >= tokenAmount, "Insufficient token balance");
        _transfer(address(this), msg.sender, tokenAmount);
        emit TokensPurchased(msg.sender, tokenAmount);
    }

    function withdrawFunds() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function withdrawUnsoldTokens() public onlyOwner {
        uint256 unsoldTokens = balanceOf(address(this));
        _transfer(address(this), owner(), unsoldTokens);
    }
}