// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/governance/TimelockController.sol";

contract TimeLock is TimelockController {
    /**@notice contract constructor
        @param _minDelay minimum delay
        @param _proposers address array of proposers (who can create a proposal)
        @param _executors address array of executors (who can execute a proposal)
     */
    constructor(
        uint256 _minDelay,
        address[] memory _proposers,
        address[] memory _executors
    ) TimelockController(_minDelay, _proposers, _executors) {}
}