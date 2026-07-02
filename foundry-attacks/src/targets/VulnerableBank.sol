// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @title VulnerableBank
/// @author Charissa
/// @notice A simple deposit/withdraw bank contract used to demonstrate a classic reentrancy vulnerability
/// @dev Educational use only, for local Anvil testing

// Defining the contract
contract VulnerableBank {
    /// @notice Creating a lookup table called balances, takes an address and get back a number. Tracks how much ETH is owed from bank to each address
    /// @dev This is an internal ledger only, does not reflect real wallet balance
    mapping(address => uint256) public balances;

    /// @notice Deposit ETH into your account with this bank
    /// @dev Increase tthe caller's entry in the balances ledger by msg.value
    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    /// @notice Withdraw your full balance from the bank
    /// @dev VULNERABLE: sends ETH (external call) BEFORE updating the balances ledger, violating the checks-effects-interactions pattern
    ///      This ordering allows a malicious contractt's receive() function to re-enter withdraw() before the ledger is corrected, draining
    ///      the bank of all funds, far beyond what was deposited
    // Withdraw your full balances - THE BUG!!
    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        // Step 1: send ETH first
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        // Step 2: update balance AFTER 
        balances[msg.sender] = 0;
    }

    /// @notice Returns the contract's total ETH holdings
    /// @return The current ETH balance held by this contract
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}