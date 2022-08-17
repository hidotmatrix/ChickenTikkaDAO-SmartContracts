// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Treasury is Ownable {
    uint256 public totalFunds;
    address public payee;
    bool public isReleased;
    bool public veto;
    string data;

    /**@notice contract constructor
        @param _payee who receives the funds
     */
    constructor(address _payee) payable {
        totalFunds = msg.value;
        payee = _payee;
        isReleased = false;
    }

    /**@notice relaseFunds
        @dev release the funds inside the treasury
     */
    function releaseFunds() public onlyOwner {
        payable(payee).transfer(totalFunds);
        isReleased = true;
    }

    // A demo setter function
    function setData(string memory _data) public {
        data = _data;
    }

    // A demo veto proposal function
    function setVeto() public {
        veto = true;
    }
}