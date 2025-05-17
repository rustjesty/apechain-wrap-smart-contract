// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import { ERC20 } from "@solady/src/tokens/ERC20.sol";
import { Test, console } from "forge-std/Test.sol";
import { WnAPE } from "../src/WnAPE.sol";
import { ArbInfoMock } from "../src/mocks/ArbInfoMock.sol";

contract WnAPETest is Test {
    // WnAPE contract instance
    WnAPE public wnAPE;

    // Addresses for test users
    address ape1 = makeAddr("ape1");
    address ape2 = makeAddr("ape2");

    function setUp() public {
        // Set up the ApeChain fork
        vm.createSelectFork("https://virtual.apechain.rpc.tenderly.co/0939bfcd-8e4f-47aa-be09-1450f49d8744");

        // Deploy mock of the ArbInfo precompile
        ArbInfoMock arbInfoMock = new ArbInfoMock();

        // Set mock bytecode to the expected precompile address
        vm.etch(0x0000000000000000000000000000000000000065, address(arbInfoMock).code);

        // Deploy the WnAPE contract
        wnAPE = new WnAPE{ value: 1 ether }();

        // Set up the test users with some APE
        vm.deal(ape1, 100 ether);
        vm.deal(ape2, 100 ether);
    }

    function test_name_returnsCorrectName() public view {
        // Assert the name of the token is correct
        assertEq(wnAPE.name(), "Wrapped Native ApeCoin");
    }

    function test_receive_successfullyWrapsAPE() public {
        // Wrap 10 APE by directly sending it to the contract
        vm.prank(ape1);
        (bool success,) = address(wnAPE).call{ value: 10 ether }("");
        require(success);

        // Assert 10 wnAPE tokens are minted to ape1
        assertEq(wnAPE.balanceOf(ape1), 10 ether);
    }

    function test_symbol_returnsCorrectSymbol() public view {
        // Assert the symbol of the token is correct
        assertEq(wnAPE.symbol(), "wnAPE");
    }

    function test_wrap_successfullyWrapFirstTime() public {
        // Wrap 10 APE by calling the wrap function
        vm.prank(ape1);
        uint256 wrappedAmount = wnAPE.wrap{ value: 10 ether }(10 ether);

        // Assert 10 wnAPE tokens are minted to ape1
        assertEq(wnAPE.balanceOf(ape1), wrappedAmount);
    }

    function test_wrap_revertsIfInvalidAmount() public {
        // Expect revert for invalid amount, trying to wrap 0 APE
        vm.expectRevert(WnAPE.InvalidAmount.selector);

        // Try to wrap 0 APE
        vm.prank(ape1);
        wnAPE.wrap{ value: 0 ether }(0 ether);
    }

    function test_wrap_revertsIfAmountDoesNotMatchValue() public {
        // Expect revert for invalid amount, trying to wrap 10 APE but sending 5 APE
        vm.expectRevert(WnAPE.InvalidAmount.selector);

        // Try to wrap 10 APE but send only 5 APE
        vm.prank(ape1);
        wnAPE.wrap{ value: 5 ether }(10 ether);
    }

    function test_unwrap_successfullyUnwraps() public {
        // Wrap 10 APE by calling the wrap function by ape1
        vm.prank(ape1);
        uint256 wnAPEamount = wnAPE.wrap{ value: 10 ether }(10 ether);

        // Simulate native yield accumulation by incresing the contract balance with 1 APE
        vm.deal(address(wnAPE), address(wnAPE).balance + 1 ether);

        // Get the expected unwrapped amount
        vm.prank(ape1);
        uint256 expectedUnwrappedAmount = wnAPE.getApeCoinByWnApeCoin(wnAPEamount);

        // Unwrap the wnAPE tokens by calling the unwrap function
        vm.prank(ape1);
        uint256 unwrappedAmount = wnAPE.unwrap(wnAPEamount);

        // Assert the unwrapped amount is correct by comparing it to the expected amount
        assertEq(unwrappedAmount, expectedUnwrappedAmount);
    }

    function test_unwrap_revertsIfInvalidAmount() public {
        // Expect revert for invalid amount, trying to unwrap 0 wnAPE
        vm.expectRevert(WnAPE.InvalidAmount.selector);

        // Try to unwrap 0 wnAPE
        vm.prank(ape1);
        wnAPE.unwrap(0 ether);
    }

    function test_unwrap_revertsIfUserHasNoWnApe() public {
        // Wrap 10 APE by calling the wrap function by ape1
        vm.prank(ape1);
        wnAPE.wrap{ value: 10 ether }(10 ether);

        // Expect revert for InsufficientBalance, trying to unwrap 10 wnAPE by ape2
        vm.expectRevert(ERC20.InsufficientBalance.selector);

        // Try to unwrap 10 wnAPE tokens by ape2
        vm.prank(ape2);
        wnAPE.unwrap(10 ether);
    }

    function test_getWnApeCoinByApeCoin_successfullyReturnsCorrectValue() public {
        // Wrap 10 APE by calling the wrap function by ape1
        vm.prank(ape1);
        wnAPE.wrap{ value: 10 ether }(10 ether);

        // Wrap 20 APE by calling the wrap function by ape2
        vm.prank(ape2);
        wnAPE.wrap{ value: 20 ether }(20 ether);

        // Simulate native yield accumulation by increasing the contract balance with 1 APE
        vm.deal(address(wnAPE), address(wnAPE).balance + 1 ether);

        // Get the current APE balance of the contract
        uint256 apeCoinBalance = address(wnAPE).balance;

        // Calculate the wnAPE amount for the given APE balance
        uint256 wnApeCoinAmount = wnAPE.getWnApeCoinByApeCoin(apeCoinBalance);

        // Assert the wnAPE amount is correct by comparing it to the sum of wrapped amounts
        assertEq(wnApeCoinAmount, (wnAPE.totalSupply()));
    }

    function test_getApeCoinByWnApeCoin_successfullyReturnsCorrectValue() public {
        // Wrap 10 APE by calling the wrap function by ape1
        vm.prank(ape1);
        wnAPE.wrap{ value: 10 ether }(10 ether);

        // Wrap 20 APE by calling the wrap function by ape2
        vm.prank(ape2);
        wnAPE.wrap{ value: 20 ether }(20 ether);

        // Simulate native yield accumulation by increasing the contract balance with 1 APE
        vm.deal(address(wnAPE), address(wnAPE).balance + 1 ether);

        // Get the current APE balance of the contract
        uint256 apeCoinBalance = address(wnAPE).balance;

        // Calculate the APE amount for the given wnAPE balance
        uint256 apeCoinAmount = wnAPE.getApeCoinByWnApeCoin(wnAPE.totalSupply());

        // Assert the APE amount is correct by comparing it to the contract balance
        assertEq(apeCoinAmount, apeCoinBalance);
    }

    function test_apeCoinPerToken_successfullyReturnsCorrectValue() public {
        // Wrap 10 APE by calling the wrap function by ape1
        vm.prank(ape1);
        wnAPE.wrap{ value: 10 ether }(10 ether);

        // Wrap 20 APE by calling the wrap function by ape2
        vm.prank(ape2);
        wnAPE.wrap{ value: 20 ether }(20 ether);

        // Simulate native yield accumulation by increasing the contract balance with 1 APE
        vm.deal(address(wnAPE), address(wnAPE).balance + 1 ether);

        // Get the current APE balance of the contract
        uint256 apeCoinBalance = address(wnAPE).balance;

        // Calculate the APE amount for 1 wnAPE
        uint256 apeCoinPerToken = wnAPE.apeCoinPerToken();

        // Assert the APE amount is correct by calculating it based on the contract balance and total supply
        assertEq(apeCoinPerToken, (apeCoinBalance * 1e18) / (wnAPE.totalSupply()));
    }

    function test_tokensPerApeCoin_successfullyReturnsCorrectValue() public {
        // Wrap 10 APE by calling the wrap function by ape1
        vm.prank(ape1);
        wnAPE.wrap{ value: 10 ether }(10 ether);

        // Wrap 20 APE by calling the wrap function by ape2
        vm.prank(ape2);
        wnAPE.wrap{ value: 20 ether }(20 ether);

        // Simulate native yield accumulation by increasing the contract balance with 1 APE
        vm.deal(address(wnAPE), address(wnAPE).balance + 1 ether);

        // Get the current APE balance of the contract
        uint256 apeCoinBalance = address(wnAPE).balance;

        // Calculate the wnAPE amount for 1 APE
        uint256 tokensPerApeCoin = wnAPE.tokensPerApeCoin();

        // Assert the wnAPE amount is correct by calculating it based on the contract balance and total supply
        assertEq(tokensPerApeCoin, (wnAPE.totalSupply()) * 1e18 / apeCoinBalance);
    }
}
