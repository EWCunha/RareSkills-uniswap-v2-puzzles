// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IERC20.sol";

/**
 *
 *  ARBITRAGE A POOL
 *
 * Given two pools where the token pair represents the same underlying; WETH/USDC and WETH/USDT (the formal has the correct price, while the latter doesnt).
 * The challenge is to flash borrow some USDC (>1000) from `flashLenderPool` to arbitrage the pool(s), then make profit by ensuring MyMevBot contract's USDC balance
 * is more than 0.
 *
 */
contract MyMevBot {
    IUniswapV3Pool public immutable flashLenderPool;
    IERC20 public immutable weth;
    IERC20 public immutable usdc;
    IERC20 public immutable usdt;
    IUniswapV2Router public immutable router;
    bool public flashLoaned;

    constructor(
        address _flashLenderPool,
        address _weth,
        address _usdc,
        address _usdt,
        address _router
    ) {
        flashLenderPool = IUniswapV3Pool(_flashLenderPool);
        weth = IERC20(_weth);
        usdc = IERC20(_usdc);
        usdt = IERC20(_usdt);
        router = IUniswapV2Router(_router);
    }

    function performArbitrage() public {
        // your code here
        flashLenderPool.flash(address(this), 1000e6, 0, "");

        require(usdc.balanceOf(address(this)) > 0, "No USDC balance");
    }

    function uniswapV3FlashCallback(
        uint256 _fee0,
        uint256,
        bytes calldata /* data */
    ) external {
        callMeCallMe();

        // your code start here
        address[] memory path = new address[](2);

        // USDC -> WETH
        path[0] = address(usdc);
        path[1] = address(weth);

        uint256 balance = usdc.balanceOf(address(this));
        uint256 usdcToReturn = balance + _fee0;
        usdc.approve(address(router), balance);

        IUniswapV2Router(router).swapExactTokensForTokens(
            balance,
            0,
            path,
            address(this),
            block.timestamp
        );

        // WETH -> USDT
        path[0] = address(weth);
        path[1] = address(usdt);

        balance = weth.balanceOf(address(this));
        weth.approve(address(router), balance);

        IUniswapV2Router(router).swapExactTokensForTokens(
            balance,
            0,
            path,
            address(this),
            block.timestamp
        );

        // USDT -> USDC
        path[0] = address(usdt);
        path[1] = address(usdc);

        balance = usdt.balanceOf(address(this));
        usdt.approve(address(router), balance);

        IUniswapV2Router(router).swapExactTokensForTokens(
            balance,
            0,
            path,
            address(this),
            block.timestamp
        );

        usdc.transfer(address(flashLenderPool), usdcToReturn);
    }

    function callMeCallMe() private {
        uint256 usdcBal = usdc.balanceOf(address(this));
        require(msg.sender == address(flashLenderPool), "not callback");
        require(
            flashLoaned = usdcBal >= 1000e6,
            "FlashLoan less than 1,000 USDC."
        );
    }
}

interface IUniswapV3Pool {
    /**
     * recipient: the address which will receive the token0 and/or token1 amounts.
     * amount0: the amount of USDC to borrow.
     * amount1: the amount of WETH to borrow.
     * data: any data to be passed through to the callback.
     */
    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;
}

interface IUniswapV2Router {
    /**
     *     amountIn: the amount to use for swap.
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
}
