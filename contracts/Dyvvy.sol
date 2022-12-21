// SPDX-License-Identifier: MIT
pragma solidity >=0.6.5 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/URIStorage.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "./ManagementControl.sol";

contract Dyvvy is ERC1155, ManagementControl {
  constructor() public {

  }

  uint128 daoCount;

  function createDao(string memory daoName, uint256 initialMint) public payable {
    _mint
  }

  function mint(uint256 id, address account, uint256 amount, bytes memory data)
        public
        onlyRole(TECH_EXEC)
    {
        require(id < 128), "Id out of range";
        _mint(account, id, amount, data);
    }
}
