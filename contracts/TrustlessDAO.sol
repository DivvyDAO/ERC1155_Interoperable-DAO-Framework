// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "./ManagementControl.sol";

contract DAO is ManagementControl, ERC1155Burnable, ERC1155Supply, ERC1155URIStorage {
  
  uint128 public _daoCount = 0;
  mapping(string => uint256) public _daoNametoId;
  mapping(uint256 => string) public _tokenURIs;
  mapping(uint256 => uint256) public _totalSupply;

  constructor() ERC1155("TrustlessDAO.net") {
    createDao("Trustless DAO", 100000, "TrustlessDAO.net/metadata");
    createDaowithExtradata("Twofold", 42, "http://127.0.0.1/nft/{-}.json", "0x34");
    createDao("Third Heaven", 144000, "");
    
  }

  // Obligatory Overrides
 
  function _beforeTokenTransfer(
        address,
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) override(ERC1155, ERC1155Supply) internal virtual view  {
        ERC1155Supply._beforeTokenTransfer;
    }

  function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlEnumerable, ERC1155) returns (bool) {
        return ERC1155.supportsInterface(interfaceId);
    }

  function uri(uint256 tokenId) public view virtual override(ERC1155, ERC1155URIStorage) returns (string memory) {
        return ERC1155URIStorage.uri(tokenId);
    }

  function createDao(string memory daoName, uint256 initialSupplyMint, string memory _uri) public returns (uint256 daoCount) {
    _mint(msg.sender, _daoCount*2, initialSupplyMint, "0x0");
    _daoNametoId[daoName] = _daoCount;
    _tokenURIs[_daoCount*2] = _uri;
    _daoCount++;
    return daoCount;
  }


  function createDaowithExtradata(string memory daoName, uint256 initialSupplyMint, string memory _uri, bytes memory data) public returns (uint256 daoCount) {
    _mint(msg.sender, _daoCount*2, initialSupplyMint, data);
    _daoNametoId[daoName] = _daoCount;
    _tokenURIs[_daoCount*2] = _uri;
    _daoCount++;
    return daoCount;
  }

  function mintDAOtokens(uint256 id, address account, uint256 amount, bytes memory data)
    public
    onlyRole(TECH_EXEC)
  {
    if(id < 128) revert("Id out of range");
    _mint(account, id, amount, data);
  }

  function mintDAOManagerTokens(uint256 id, address account, uint256 amount, bytes memory data)
    public
    onlyRole(TECH_EXEC)
  {
    if(id < 128) revert("Id out of range");
    _mint(account, id, amount, data);
  }
}
