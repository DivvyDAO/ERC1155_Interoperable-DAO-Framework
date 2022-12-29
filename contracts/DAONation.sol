// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "./DAOManagement.sol";

contract DAONation is DAOManagers, ERC1155Burnable {
  
  uint128 public _daoCount = 0;
  mapping(string => uint256) private _daoNametoId;
  mapping(uint256 => string) public _tokenURIs;
  mapping(uint256 => uint256) private _totalSupply;

    constructor() ERC1155("DAONation.com") payable {
      createDao("DAO Nation", 100000, "http://DAONation.com/metadata/DAONation.json");
      
    }

    // Obligatory Overrides
  
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, DAOManagers) returns (bool) {
      return ERC1155.supportsInterface(interfaceId);
    }

    function uri(uint256 tokenId) public view virtual override(ERC1155) returns (string memory) {
      return _tokenURIs[tokenId];
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

  function createDao(string memory daoName, uint256 initialSupplyMint, string memory _uri) public payable returns (uint256) {
    super._mint(msg.sender, _daoCount, initialSupplyMint, "0x0");
    return _afterCreateDAO(daoName, _uri);
  }

  function createDaowithExtradata(string memory daoName, uint256 initialSupplyMint, string memory _uri, bytes memory data) public payable returns (uint256) {
    super._mint(msg.sender, _daoCount, initialSupplyMint, data);
    return _afterCreateDAO(daoName, _uri);
  }

  function _beforeCreateDAO(string memory daoName) internal returns (bool) {
    require (exists(_daoNametoId[daoName]) == false, "DAONation: Name already exists. Contact us if there is a branding issue.");
    require (msg.value == 0.21 ether, "DAONation: Requires a payment of 0.21 ether aka. 210 finney");
    return true;
  }

  function _afterCreateDAO(string memory daoName, string memory _uri) internal returns (uint256) {
    _daoNametoId[daoName] = _daoCount;
    _tokenURIs[_daoCount] = _uri;
    _grantManager(_daoCount, msg.sender);
    return _daoCount++;
  }

  function mintDAOtokens(uint256 id, address account, uint256 amount, bytes memory data)
    public
    onlyManager(id)
  {
    super._mint(account, id, amount, data);
  }

  function mintDAOtokens(string memory id, address account, uint256 amount, bytes memory data)
    public
    onlyManager(_daoNametoId[id])
  {
    super._mint(account, _daoNametoId[id], amount, data);
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
