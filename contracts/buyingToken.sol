// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract buyToken is ERC20 {
    constructor()ERC20("buyToken", "BTK") {
        _mint(msg.sender, 1000000 *10**18);
    }
}
interface iBuyToken{
    
}