pragma solidity ^0.6.9;

contract Controller {

  address public value;

  function increase(uint256 amount) public {
    value += amount;
  }
}