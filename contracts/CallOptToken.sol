//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


// 期权也可以理解为一种token

// 本期权 标的 是 eth
contract CallOptToken  is ERC20, Ownable {
    using SafeERC20 for IERC20;

    uint public price;
    uint public settlementTime;
    uint public constant duringTime = 1 days;
    address public usdcToken;


    constructor (address usdc_) ERC20("CallOptToken","COPT") {
        usdcToken = usdc_;
        settlementTime = 20 days;
    }


    // 发行。根据转入标的发行期权
    function mint() external payable onlyOwner{
        _mint(msg.sender, msg.value );
    }


    // 行权
    function settlement(uint amount_) external {
        require(block.timestamp >= settlementTime && block.timestamp <= settlementTime + duringTime,"invalid time");

        _burn(msg.sender, amount_);


        uint needUsdcAmount = price * amount_;

        IERC20(usdcToken).safeTransferFrom(msg.sender,address(this),needUsdcAmount);
        // 标的 转给行权人
        safeTransferEth(msg.sender,amount_);
    }


    function safeTransferEth(address to_,uint amount_) internal {
        //  call调用转账eth
        (bool success,) = to_.call{value:amount_}(new bytes(0));
        require(success,"TransferHelper::safeTransferETH: ETH transfer failed");
    }



    //  过期销毁
    function burnAll() external onlyOwner{
        require(block.timestamp > settlementTime+duringTime,"not end");
        uint usdcAmount = IERC20(usdcToken).balanceOf(address(this));

        IERC20(usdcToken).safeTransfer(msg.sender,usdcAmount);

        // 销毁。  合约中的eth 转入指定账户。 且不会触动指定账户的fallback函数
        selfdestruct(payable(msg.sender));
    }









}
