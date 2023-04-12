// SPDX-License-Identifier: MIT
pragma solidity ~0.8.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract AllowListVerify {
    using ECDSA for bytes32;

    bytes32 private root;
    address private _signAddress;

    function setMerkleRoot(bytes32 _root) external {
        root = _root;
    }

    function setSignAddress(address _address) external {
        _signAddress = _address;
    }

    function verify(bytes32[] calldata proof, uint256 amount, uint256 price) external view returns (bool) {
        return MerkleProof.verify(proof, root, keccak256(abi.encodePacked(msg.sender, amount, price)));
    }

    function verify(bytes memory signature, uint256 amount, uint256 price) external view returns (bool) {
       return keccak256(abi.encodePacked(msg.sender, amount, price)).toEthSignedMessageHash().recover(signature) == _signAddress;
    }
}
