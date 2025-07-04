// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Sync, Skim} from "../src/SyncAndSkim.sol";
import "../src/interfaces/IUniswapV2Pair.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";

contract SyncAndSkimTest is Test {
    Sync public sync;
    Skim public skim;
    address public pool = 0xc5be99A02C6857f9Eac67BbCE58DF5572498F40c;
    address public ampl = 0xD46bA6D942050d489DBd938a2C909A5d5039A161;
    address public weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    uint256 r0;
    uint256 r1;

    function setUp() public {
        vm.rollFork(20055371);
        (r0, r1, ) = IUniswapV2Pair(pool).getReserves();
    }

    function test_PerformSync() public {
        sync = new Sync();

        // simulate negative rebase
        vm.startPrank(pool);
        IUniswapV2Pair(ampl).transfer(address(0xdead), 1000 * 1e9);
        IUniswapV2Pair(weth).transfer(address(0xdead), 50 ether);
        vm.stopPrank();

        sync.performSync(pool);

        uint256 wethBal = IUniswapV2Pair(weth).balanceOf(pool);
        uint256 amplBal = IUniswapV2Pair(ampl).balanceOf(pool);

        (uint256 r00, uint256 r11, ) = IUniswapV2Pair(pool).getReserves();

        require(wethBal == r00 && amplBal == r11, "Sync Failed.");
    }

    function test_PerformSkim() public {
        skim = new Skim();

        address holder = 0xCb2286d9471cc185281c4f763d34A962ED212962; // SushiSwap (has a lot of AMPL)

        // Deal holder with some tokens
        deal(weth, holder, 100 ether);

        // simulate positive rebase
        vm.startPrank(holder);
        IUniswapV2Pair(weth).transfer(pool, 100 ether);
        IUniswapV2Pair(ampl).transfer(pool, 2500e9);
        vm.stopPrank();

        skim.performSkim(pool);

        uint256 wethBal = IUniswapV2Pair(weth).balanceOf(pool);
        uint256 amplBal = IUniswapV2Pair(ampl).balanceOf(pool);

        require(wethBal == r0 && amplBal == r1, "Skim Failed.");

        uint256 wethPuzzleBal = IUniswapV2Pair(weth).balanceOf(address(skim));
        uint256 amplPuzzleBal = IUniswapV2Pair(ampl).balanceOf(address(skim));

        require(
            wethPuzzleBal > 0 && amplPuzzleBal > 0,
            "Pool Differences Not Sent To Skim Contract."
        );
    }
}
