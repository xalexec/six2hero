// SPDX-License-Identifier: MIT
pragma solidity ~0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Six2Hero is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, Ownable2StepUpgradeable {
    uint256 constant ACTIVE_BLOCK = 28722445;
    mapping(address => bool) public blocked;

    function initialize(string calldata _name, string calldata _symbol) public initializer {
        __ERC20_init(_name, _symbol);
        __Ownable_init();
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function blacklist(address[] calldata users) external onlyOwner {
        for (uint i = 0; i < users.length; i++) {
            blocked[users[i]] = true;
        }
    }

    function unblacklist(address[] calldata users) external onlyOwner {
        for (uint i = 0; i < users.length; i++) {
            delete blocked[users[i]];
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        require(block.number > ACTIVE_BLOCK);
        require(!blocked[from] && !blocked[to]);
    }
}
