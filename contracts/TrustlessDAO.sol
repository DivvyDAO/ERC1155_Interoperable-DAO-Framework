// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "./DAOManagement.sol";

contract Trustless_DAO is DAOManagers, ERC1155Burnable {
  
  uint128 public _daoCount = 0;
  mapping(string => uint256) public _daoNametoId;
  mapping(uint256 => string) public _tokenURIs;
  mapping(uint256 => uint256) private _totalSupply;

    constructor() ERC1155("TrustlessDAO.net") {
      createDao("Trustless DAO", 100000, "TrustlessDAO.net/metadata");
      createDaowithExtradata("Twofold", 42, "http://127.0.0.1/nft/{-}.json", "0x34");
      createDao("Third Heaven", 144000, "0x00");
      
    }

    // Obligatory Overrides
  
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, DAOManagers) returns (bool) {
      return ERC1155.supportsInterface(interfaceId);
    }

    function uri(uint256 tokenId) public view virtual override(ERC1155) returns (string memory) {
      return _tokenURIs[tokenId];
      // if calling managerId fall back to dao uri, management details will be found in that metadata
    }

    /**
     * @dev See {ERC1155-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
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

  /************************************************
  *
  *   DAO Interface Functions
  *
  ************************************************/

  function createDao(string memory daoName, uint256 initialSupplyMint, string memory _uri) public returns (uint256 daoCount) {
    super._mint(msg.sender, _daoCount, initialSupplyMint, "0x0");
    _daoNametoId[daoName] = _daoCount;
    _tokenURIs[_daoCount] = _uri;
    _grantRole(_daoCount, keccak256("DAO_MANAGER_ROLE"), msg.sender);
    _daoCount++;
    return daoCount;
  }

  function createDaowithExtradata(string memory daoName, uint256 initialSupplyMint, string memory _uri, bytes memory data) public returns (uint256 daoCount) {
    super._mint(msg.sender, _daoCount, initialSupplyMint, data);
    _daoNametoId[daoName] = _daoCount;
    _tokenURIs[_daoCount] = _uri;
    _grantRole(_daoCount, keccak256("DAO_MANAGER_ROLE"), msg.sender);
    _daoCount++;
    return daoCount;
  }

  function mintDAOtokens(uint256 id, address account, uint256 amount, bytes memory data)
    public
    onlyRole(id, DAO_MANAGER_ROLE)
  {
    if(id > 2^128) revert("Id out of range, these are Manager Tokens");
    super._mint(account, id, amount, data);
  }

  function mintDAOManagerTokens(uint256 id, address account, uint256 amount, bytes memory data) //thinking about removing the managertokens and making a simpleManagerVote without them
    public
    onlyRole(id, DAO_MANAGER_ROLE)
  {
    if(id < 2^128) revert("Id out of range, these are Member Tokens");
    super._mint(account, id, amount, data);
  }


  /**
    * @dev Total amount of tokens in with a given id.
    */
  function totalSupply(uint256 id) public view virtual returns (uint256) {
      return _totalSupply[id];
  }

  /**
    * @dev Indicates whether any token exist with a given id, or not.
    */
  function exists(uint256 id) public view virtual returns (bool) {
      return totalSupply(id) > 0;
  }
}
