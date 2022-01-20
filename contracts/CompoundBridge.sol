// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6 <= 0.9.0;


import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

import { IDefiBridge } from "./interfaces/IDefiBridge.sol";
import {IcETH} from "./interfaces/IcETH.sol";
import { Types } from "./Types.sol";

contract CompoundBridge is IDefiBridge{
    using SafeMath for uint256;
    
    IcETH ceth = IcETH (0x20572e4c090f15667cF7378e16FaD2eA0e2f3EfF);

  address public immutable rollupProcessor;

  

     constructor(address _rollupProcessor) public {
        rollupProcessor = _rollupProcessor;
    }
  receive() external payable {}


  function convert(
    Types.AztecAsset calldata inputAssetA,
    Types.AztecAsset calldata,
    Types.AztecAsset calldata outputAssetA,
    Types.AztecAsset calldata,
    uint256 inputValue,
    uint256,
    uint64
  )
    external
    payable
    override
    returns (
      uint256 outputValueA,
      uint256,
      bool isAsync
    )
  {
      require(msg.sender == rollupProcessor, "CompoundBridge: Only the rollupProcessor can call this function");
      require( inputAssetA.assetType == Types.AztecAssetType.ETH, "CompoundBridge: inputAssetA must be ETH");
        require( outputAssetA.assetType == Types.AztecAssetType.ERC20, "CompoundBridge: outputAssetA must be ERC20");

      isAsync = false;

      ceth.mint{value: inputValue}();
      
      uint256 outputcETHBalance = IERC20(address(ceth)).balanceOf(address(this));
    //   IERC20(address(ceth)).safeIncreaseAllowance(address(ceth), outputcETHBalance);

      outputValueA = ceth.balanceOf(address(this)) * ceth.exchangeRateStored()/1e18;


       IERC20(address(ceth)).transfer(rollupProcessor, outputValueA);
  }

  function canFinalise(
    uint256 /*interactionNonce*/
  ) external view override returns (bool) {
    return false;
  }

  function finalise(
    Types.AztecAsset calldata,
    Types.AztecAsset calldata,
    Types.AztecAsset calldata,
    Types.AztecAsset calldata,
    uint256,
    uint64
  ) external payable override returns (uint256, uint256) {
    require(false);
  }
}