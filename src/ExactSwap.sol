// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IERC20.sol";

contract ExactSwap {
    /**
     *  PERFORM AN SIMPLE SWAP WITHOUT ROUTER EXERCISE
     *
     *  The contract has an initial balance of 1 WETH.
     *  The challenge is to swap an exact amount of WETH for 1337 USDC token using the `swap` function
     *  from USDC/WETH pool.
     *
     */
    function performExactSwap(
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
        uint256 usdcWantedAmount = 1337e6;

        uint256 uniswap_v2_fee = 3_000;
        uint256 precision = 1_000_000;

        IUniswapV2Pair pair = IUniswapV2Pair(pool);

        (uint112 reserve0, uint112 reserve1, ) = pair.getReserves();
        uint256 amount0Out;
        uint256 amount1Out;
        uint256 amountIn;
        {
            uint112 reserveIn;
            uint112 reserveOut;
            if (pair.token0() == weth) {
                reserveIn = reserve0;
                reserveOut = reserve1;
                amount0Out = 0;
                amount1Out = usdcWantedAmount;
            } else {
                reserveIn = reserve1;
                reserveOut = reserve0;
                amount0Out = usdcWantedAmount;
                amount1Out = 0;
            }

            uint256 numerator = reserveIn * usdcWantedAmount * precision;
            uint256 denominator = (reserveOut - usdcWantedAmount) *
                (precision - uniswap_v2_fee);
            amountIn = numerator / denominator;
            if (amountIn * denominator != numerator) {
                amountIn = amountIn + 1;
            }
        }

        IERC20(weth).transfer(pool, amountIn);
        pair.swap(amount0Out, amount1Out, address(this), "");
    }
}
