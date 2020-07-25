pragma solidity >=0.4.24 <0.7.0;

import { ERC20 } from "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/upgrades/contracts/Initializable.sol";

contract CustomERC20 is ERC20, Initializable{
    string public version;
    string private name_;
    string private symbol_;
    uint256 public MOCK_SUPPLY;

  function initialize(string memory name, string memory symbol, address payable owner) public initializer {
    version = "0.0.1";
    name_ = name;
    symbol_ = symbol;
    MOCK_SUPPLY = 100e5;
    _mint(owner, MOCK_SUPPLY);
  }

}