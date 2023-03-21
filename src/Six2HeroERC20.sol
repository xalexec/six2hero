// SPDX-License-Identifier: MIT
pragma solidity ~0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Six2Hero is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("Six2Hero", "s2h") {}

    mapping(address => bool) public blocked;

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
        require(!blocked[from] && !blocked[to]);
    }
}
