// SPDX-License-Identifier: MIT
pragma solidity >=0.6.5 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "./ManagementControl.sol";

contract Dyvvy is ManagementControl, ERC1155Burnable, ERC1155Supply, ERC1155URIStorage {
  
  constructor() ERC1155("Dyvvy") {
    _daoCount = 0;
    _mint(msg.sender, _daoCount*2, 100000, "");
  }

  // Obligatory Overrides

  mapping(uint256 => string) private _tokenURIs;
  mapping(uint256 => uint256) private _totalSupply;
  function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        if (from == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] += amounts[i];
            }
        }

        if (to == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                uint256 id = ids[i];
                uint256 amount = amounts[i];
                uint256 supply = _totalSupply[id];
                require(supply >= amount, "ERC1155: burn amount exceeds totalSupply");
                unchecked {
                    _totalSupply[id] = supply - amount;
                }
            }
        }
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlEnumerable, ERC1155) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }
    function uri(uint256 tokenId) public view virtual override(ERC1155, ERC1155URIStorage) returns (string memory) {
        string memory tokenURI = _tokenURIs[tokenId];

        // If token URI is set, concatenate base URI and tokenURI (via abi.encodePacked).
        return bytes(tokenURI).length > 0 ? string(abi.encodePacked(tokenURI)) : super.uri(tokenId);
    }



  uint128 _daoCount;
  mapping(string => uint256) private _daoNametoId;

  function createDao(string memory daoName, uint256 initialMint) public payable {
    _mint(msg.sender, _daoCount*2, initialMint, "");
    _daoCount++;
  }

  function mint(uint256 id, address account, uint256 amount, bytes memory data)
    public
    onlyRole(TECH_EXEC)
  {
    require(id < 128); "Id out of range";
    _mint(account, id, amount, data);
  }
}
