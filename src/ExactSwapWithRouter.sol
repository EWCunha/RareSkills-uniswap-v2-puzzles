// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IERC20.sol";

contract ExactSwapWithRouter {
    /**
     *  PERFORM AN EXACT SWAP WITH ROUTER EXERCISE
     *
     *  The contract has an initial balance of 1 WETH.
     *  The challenge is to swap an exact amount of WETH for 1337 USDC token using UniswapV2 router.
     *
     */
    address public immutable router;

    constructor(address _router) {
        router = _router;
    }

    function performExactSwapWithRouter(
        address weth,
        address usdc,
        uint256 deadline
    ) public {
        // your code start here
        uint256 usdcWantedAmount = 1337e6;

        // Create the path for the swap: WETH -> USDC
        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = usdc;

        // Use getAmountsIn to calculate how much WETH we need to get exactly 1337 USDC
        uint256[] memory amountsIn = IUniswapV2Router(router).getAmountsIn(
            usdcWantedAmount,
            path
        );
        uint256 wethAmountIn = amountsIn[0];

        // Approve the router to spend our WETH
        IERC20(weth).approve(router, wethAmountIn);

        // Perform the swap
        IUniswapV2Router(router).swapExactTokensForTokens(
            wethAmountIn,
            usdcWantedAmount, // Set minimum output to exactly what we want
            path,
            address(this),
            deadline
        );
    }
}

interface IUniswapV2Router {
    /**
     *     amountIn: the amount of input tokens to swap.
     *     amountOutMin: the minimum amount of output tokens that must be received for the transaction not to revert.
     *     path: an array of token addresses. In our case, WETH and USDC.
     *     to: recipient address to receive the liquidity tokens.
     *     deadline: timestamp after which the transaction will revert.
     */
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    /**
     *     amountOut: the exact amount of output tokens we want to receive.
     *     path: an array of token addresses. In our case, WETH and USDC.
     */
    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}
