// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IERC20.sol";

contract SimpleSwap {
    /**
     *  PERFORM A SIMPLE SWAP WITHOUT ROUTER EXERCISE
     *
     *  The contract has an initial balance of 1 WETH.
     *  The challenge is to swap any amount of WETH for USDC token using the `swap` function
     *  from USDC/WETH pool.
     *
     */
    function performSwap(
        address pool,
        address weth,
        address /* usdc */
    ) public {
        /**
         *     swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data);
         *
         *     amount0Out: the amount of USDC to receive from swap.
         *     amount1Out: the amount of WETH to receive from swap.
         *     to: recipient address to receive the USDC tokens.
         *     data: leave it empty.
         */

        // your code start here
        uint256 uniswap_v2_fee = 3_000;
        uint256 precision = 1_000_000;

        IUniswapV2Pair pair = IUniswapV2Pair(pool);
        uint256 wethBalance = IERC20(weth).balanceOf(address(this));
        IERC20(weth).transfer(pool, wethBalance);

        (uint112 reserve0, uint112 reserve1, ) = pair.getReserves();
        address token0 = pair.token0();
        (uint112 reserveIn, uint112 reserveOut) = token0 == weth
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
        uint256 feeTerm = precision - uniswap_v2_fee;

        uint256 amountOut = ((wethBalance * feeTerm * reserveOut)) /
            (reserveIn * precision + (wethBalance * feeTerm));

        (uint256 amount0Out, uint256 amount1Out) = token0 == weth
            ? (uint256(0), amountOut)
            : (amountOut, uint256(0));

        pair.swap(amount0Out, amount1Out, address(this), "");
    }
}
