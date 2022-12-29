// SPDX-License-Identifier: Proprietary
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "./DAOManagement.sol";

contract DAONation is DAOManagement, ERC1155Burnable {
  
  uint256 public costToDeployDAO = 0;
  uint128 public _daoCount = 0;
  mapping(string => uint256) public _daoNametoId;
  struct DAOinfo {
    string name;
    string abbr;
    string uri;
    uint256 _totalSupply;
  }
  mapping(uint256 => DAOinfo) internal DAOmap;
  struct qtyAddress {
    uint quantity;
    address client;
  }
  mapping(uint256 => mapping(uint256 => qtyAddress)) public tokenPuts; // m(dao => m($ => address))
  mapping(uint256 => mapping(uint256 => qtyAddress)) public tokenCalls;
  mapping(address => mapping(uint256 => uint256)) internal _lockedTokens;

  constructor() ERC1155("DAONation.com") {

    createDao("DAO Nation", 100000, "http://DAONation.com/metadata/DAONation.json");
    costToDeployDAO = uint256(210000000000000000);
      
  }
/*********************************************
*
*   DAONation Owner Functions
*
*********************************************/
    function sendWeiToOwner(uint256 _amount) onlyOwner(0) public {
      address payable owner = payable(owners[0]);
      owner.transfer(_amount);
    }

    function changeCostToDeployDAO(uint256 newCostInWei) public onlyOwner(0) {
      costToDeployDAO = newCostInWei;
    }
    // Obligatory Overrides
  
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, DAOManagement) returns (bool) {
      return ERC1155.supportsInterface(interfaceId);
    }

    function uri(uint256 tokenId) public view virtual override(ERC1155) returns (string memory) {
      return DAOmap[tokenId].uri;
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
                DAOmap[ids[i]]._totalSupply += amounts[i];
            }
        }

        if (to == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                uint256 id = ids[i];
                uint256 amount = amounts[i];
                uint256 supply = DAOmap[id]._totalSupply;
                require(supply >= amount, "ERC1155: burn amount exceeds totalSupply");
                require((supply - _lockedTokens[msg.sender][id]) >= amount, "DAONation: burn amount would burn locked tokens");
                unchecked {
                    DAOmap[id]._totalSupply = supply - amount;
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
    _beforeCreateDAO(daoName);
    super._mint(msg.sender, _daoCount, initialSupplyMint, "0x0");
    return _afterCreateDAO(daoName, _uri);
  }

  function createDaowithExtradata(string memory daoName, uint256 initialSupplyMint, string memory _uri, bytes memory data) public payable returns (uint256) {
    _beforeCreateDAO(daoName);
    super._mint(msg.sender, _daoCount, initialSupplyMint, data);
    return _afterCreateDAO(daoName, _uri);
  }

  function _beforeCreateDAO(string memory daoName) internal returns (bool) {
    require(_daoNametoId[daoName] == 0, "DAONation: DAO Tokens already exist under this name. Contact us if there is a branding issue.");
    require (msg.value >= costToDeployDAO, string(
                    abi.encodePacked(
                      "DAONation: Requires a payment of ", 
                      Strings.toString(costToDeployDAO),
                      " wei"
                    )));
    return true;
  }

  function _afterCreateDAO(string memory daoName, string memory _uri) internal returns (uint256) {
    _daoNametoId[daoName] = _daoCount;
    DAOmap[_daoCount].uri = _uri;
    _grantManager(_daoCount, msg.sender);
    owners[_daoCount] = msg.sender;
    _daoCount++;
    return _daoCount - 1;
  }

// DAO Token Minting MUST be by a manager or owner of the DAO

  function mintDAOtokens(uint256 id, address account, uint256 amount, bytes memory data)
    public
    payable
    onlyManager(id)
  {
    super._mint(account, id, amount, data);
  }

  function mintDAOtokens(string memory id, address account, uint256 amount, bytes memory data)
    public
    payable
    onlyManager(_daoNametoId[id])
  {
    super._mint(account, _daoNametoId[id], amount, data);
  }

  /**
    * @dev Total amount of tokens in a DAO with a given id.
    */
  function totalSupply(uint256 id) public view virtual returns (uint256) {
      return DAOmap[id]._totalSupply;
  }

  /**
    * @dev Indicates whether any token exist with a given id, or not.
    */
  function exists(uint256 id) public view virtual returns (bool) {
      return DAOmap[id]._totalSupply > 0;
  }

  function sellTokens(uint256 id, uint256 quantity, uint256 value) public {
    _lockTokens(id, quantity);
    // _checkCalls
    tokenPuts[id][value].quantity = quantity;
    tokenPuts[id][value].client = msg.sender;

  }

  function buyTokens(uint256 id, uint256 quantity, uint256 value) public payable {
    _lockTokens(id, quantity);
    //checkPuts
    tokenCalls[id][value].quantity = quantity;
    tokenCalls[id][value].client = msg.sender;
  }

  function _lockTokens(uint256 id, uint256 quantity) internal {
    require(balanceOf(msg.sender, id) >= quantity, "ERC1155Tradable: Sender does not own enough tokens.");
    _lockedTokens[msg.sender][id] = quantity;
  }
}
