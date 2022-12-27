// SPDX-License-Identifier: MIT
// Tech Enterprises Contracts v0.1 (DAOManagement.sol)
// based on a clone of OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of DAOManagement declared to support ERC165 detection.
 */
interface IDAOManagement {
    /**
     * @dev Emitted when `newAdminManager` is set as ``role``'s admin role, replacing `previousAdminManager`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {ManagerAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event ManagerAdminChanged(uint256 dao, address indexed previousAdminManager, address indexed newAdminManager);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {DAOManagement-_setupManager}.
     */
    event ManagerGranted(uint256 dao, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeManager`, it is the admin role bearer
     *   - if using `renounceManager`, it is the role bearer (i.e. `account`)
     */
    event ManagerRevoked(uint256 dao, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasManager(uint256 dao, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantManager} and
     * {revokeManager}.
     *
     * To change a role's admin, use {DAOManagement-_setManagerAdmin}.
     */
    function getManagerAdmin(uint256 dao) external view returns (address);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {ManagerGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantManager(uint256 dao, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {ManagerRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeManager(uint256 dao, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Managers are often managed via {grantManager} and {revokeManager}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {ManagerRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceManager(uint256 dao, address account) external;
}
