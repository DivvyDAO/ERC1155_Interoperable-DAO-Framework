// SPDX-License-Identifier: MIT
pragma solidity >=0.6.5 <0.9.0;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

enum Role {
  LEAD_LINK,
  TECH_EXEC,
  GOVERNANCE_CIRCLE,
  SECRETARY,
  DEPUTY
}
contract ManagementControl is AccessControlEnumerable {
    bytes32 public constant LEAD_LINK = keccak256("LEAD_LINK");
    bytes32 public constant TECH_EXEC = keccak256("TECH_EXEC");
    bytes32 public constant GOVERNANCE_CIRCLE = keccak256("GOVERNANCE_CIRCLE");
    bytes32 public constant SECRETARY = keccak256("SECRETARY");
    bytes32 public constant DEPUTY = keccak256("DEPUTY");
  constructor() public {
    _grantRole(LEAD_LINK, msg.sender);
    _grantRole(TECH_EXEC, msg.sender);
    _grantRole(GOVERNANCE_CIRCLE, msg.sender);
    _grantRole(SECRETARY, msg.sender);
    _grantRole(DEPUTY, msg.sender);
  }
}
