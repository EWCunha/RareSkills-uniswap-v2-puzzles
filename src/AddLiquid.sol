// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IERC20.sol";

contract AddLiquid {
    /**
     *  ADD LIQUIDITY WITHOUT ROUTER EXERCISE
     *
     *  The contract has an initial balance of 1000 USDC and 1 WETH.
     *  Mint a position (deposit liquidity) in the pool USDC/WETH to msg.sender.
     *  The challenge is to provide the same ratio as the pool then call the mint function in the pool contract.
     *
     */
    function addLiquidity(
        address usdc,
        address weth,
        address pool,
        uint256 usdcReserve,
        uint256 wethReserve
    ) public {
        IUniswapV2Pair pair = IUniswapV2Pair(pool);

        // your code start here
        uint256 usdcBalance = IERC20(usdc).balanceOf(address(this));
        uint256 wethBalance = IERC20(weth).balanceOf(address(this));

        uint256 amountWETH = (wethReserve * usdcBalance) / usdcReserve;
        if (amountWETH > wethBalance) {
            amountWETH = wethBalance;
        }
        uint256 amountUSDC = (amountWETH * usdcReserve) / wethReserve;
        IERC20(weth).transfer(pool, amountWETH);
        IERC20(usdc).transfer(pool, amountUSDC);
        pair.mint(msg.sender);
    }
}
