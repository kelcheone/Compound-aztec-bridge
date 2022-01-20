// SPDX-License-Identifier: MIT

pragma solidity  >=0.6.6 <=0.9.0;

interface IcETH{
    // Deposit to compound
    function mint() external payable;

    // Withdraw from compound
    function redeem(uint redeemToken) external returns(uint);

    // Determine how much tokens you will redeem from compound
    function exchangeRateStored() external view returns(uint);
    function balanceOf(address owner) external view returns (uint balance); 

}