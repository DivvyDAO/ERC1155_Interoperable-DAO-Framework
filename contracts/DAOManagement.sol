// SPDX-License-Identifier: MIT
// version 0.2 Tech Enterprises Contracts
// based on a clone of OpenZeppelin Contracts (last updated v4.8.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./interfaces/IDAOManagement.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Managers are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Managers can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasManager}:
 *
 * ```
 * function foo() public {
 *     require(hasManager(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Managers can be granted and revoked dynamically via the {grantManager} and
 * {revokeManager} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantManager} and {revokeManager}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setManagerAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract DAOManagement is Context, IDAOManagement, ERC165 {

    mapping(address => string) personaUri;
    mapping(uint256 => address) owners;
    mapping(uint256 => mapping(address => bool)) private managers;

    /**
     * @dev Modifier that checks that an account is a Manager of the DAO. Reverts
     * with a standardized message including the required Manager role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^DAOManagement: account (0x[0-9a-f]{40}) is missing Manager role (0x[0-9a-f]{64})$/
     */
    modifier onlyManager(uint256 dao) {
        _checkManager(dao);
        _;
    }

    modifier onlyOwner(uint256 dao) {
        _checkOwner(dao);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IDAOManagement).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `Manager role`.
     */
    function hasManager(uint256 dao, address account) public view virtual returns (bool) {
        return managers[dao][account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `Manager role`.
     * Overriding this function changes the behavior of the {onlyManager} modifier.
     *
     * Format of the revert message is described in {_checkManager}.
     *
     * _Available since v4.6._
     */
    function _checkManager(uint256 dao) internal view virtual {
        _checkManager(dao, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `Manager role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^DAOManagement: account (0x[0-9a-f]{40}) is missing Manager role (0x[0-9a-f]{64})$/
     */
    function _checkManager(uint256 dao, address account) internal view virtual {
        if (!hasManager(dao, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "DAOManagement: account ",
                        Strings.toHexString(account),
                        " is missing Manager role. "
                        )
                    )
                );
        }
    }

    function _checkOwner(uint256 dao) internal view virtual {
        _checkOwner(dao, msg.sender);
    }


    function _checkOwner(uint256 dao, address account) internal view virtual {
        if (owners[dao] != account) {
            revert(
                string(
                    abi.encodePacked(
                        "DAOManagement: account ",
                        Strings.toHexString(account),
                        " is missing Owner role. "
                        )
                    )
                );
        }
    }

    /**
     * @dev Returns the owner role that controls `Manager role`. See {grantManager} and
     * {revokeManager}.
     *
     * To change a Manager role's owner, use {_setManagerAdmin}.
     */
    function _getManagerAdmin(uint256 dao) external view returns (address) {
        return owners[dao];
    }

    /**
     * @dev Grants `Manager role` to `account`.
     *
     * If `account` had not been already granted `Manager role`, emits a {ManagerGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``Manager role``'s owner role.
     *
     * May emit a {ManagerGranted} event.
     */
    function grantManager(uint256 dao, address account) public virtual onlyManager(dao) {
        _grantManager(dao, account);
    }

    /**
     * @dev Revokes `Manager role` from `account`.
     *
     * If `account` had been granted `Manager role`, emits a {ManagerRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``Manager role``'s owner role.
     *
     * May emit a {ManagerRevoked} event.
     */
    function revokeManager(uint256 dao, address account) public virtual onlyManager(dao) {
        _revokeManager(dao, account);
    }

    /**
     * @dev Revokes `Manager role` from the calling account.
     *
     * Managers are often managed via {grantManager} and {revokeManager}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `Manager role`, emits a {ManagerRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {ManagerRevoked} event.
     */
    function renounceManager(uint256 dao, address account) public virtual {
        require(account == _msgSender(), "DAOManagement: can only renounce roles for self");

        _revokeManager(dao, account);
    }

    /**
     * @dev Grants `Manager role` to `account`.
     *
     * If `account` had not been already granted `Manager role`, emits a {ManagerGranted}
     * event. Note that unlike {grantManager}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {ManagerGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantManager}.
     */
    function _setupManager(uint256 dao, address account) internal virtual {
        _grantManager(dao, account);
    }

    /**
     * @dev Sets `adminManager` as ``Manager role``'s admin role.
     *
     * Emits a {ManagerAdminChanged} event.
     */
    function _setManagerAdmin(uint256 dao, address adminManager) internal virtual {
        address previousAdminManager = owners[dao];
        owners[dao] = adminManager;
        emit ManagerAdminChanged(dao, previousAdminManager, adminManager);
    }

    /**
     * @dev Grants `Manager role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {ManagerGranted} event.
     */
    function _grantManager(uint256 dao, address account) internal virtual {
        if (!hasManager(dao, account)) {
            managers[dao][account] = true;
            emit ManagerGranted(dao, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `Manager role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {ManagerRevoked} event.
     */
    function _revokeManager(uint256 dao, address account) internal virtual {
        if (hasManager(dao, account)) {
            managers[dao][account] = false;
            emit ManagerRevoked(dao, account, _msgSender());
        }
    }
}
