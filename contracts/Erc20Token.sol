// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract Erc20Token {
    string private name;
    string private symbol;
    uint8 constant private decimals = 18;
    uint256 private totalSupply;
    address private owner;
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowed;

    event  Transfer(address indexed _from, address indexed _to, uint256 _value);
    event  Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor() {
        name = "Erc20Token";
        symbol = "ERC";
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "You are not the owner"
        );
        _;
    }
    function getName() public view returns (string memory) {
        return name;
    }
    function getSymbol() public view returns (string memory) {
        return symbol;
    }
    function getDecimals() public pure returns (uint8) {
        return decimals;
    }
    function getTotalSupply() public view returns (uint256) {
        return totalSupply;
    }
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(
            balances[msg.sender] >= _value,
            "Insufficient balance"
        );
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(
            balances[_from] >= _value && allowance >= _value,
            "Insufficient balance or allowance"
        );
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < 2**256 - 1) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value);
        return true;
    }
    function Approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    function Allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
    function mint(address _spender, uint256 _addedValue) public onlyOwner  {
        balances[_spender] += _addedValue;
        totalSupply += _addedValue;
       
    }
    function burn(address _spender, uint256 _subtractedValue) public onlyOwner  {
        require(
            balances[_spender] >= _subtractedValue,
            "Insufficient balance"
        );
        balances[_spender] -= _subtractedValue;
        totalSupply -= _subtractedValue;
    }
}