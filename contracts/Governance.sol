// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract MyGovernor is Governor, GovernorSettings, GovernorCountingSimple, GovernorVotes, GovernorVotesQuorumFraction, GovernorTimelockControl {

    mapping (address => uint256) public fundsLocked;
    mapping (address => bool) public alreadyProposed;
    mapping (address => uint256) public alreadyProposedId;
    

    uint256 totalProposals;

    mapping (uint256 => uint256) public fundsLockedforProposals;
    mapping (address => mapping (uint256 => uint256)) public proposerLockedAmt;

    address public treasuryAddress;

    event FundsLocked(address locker,uint256 amount,uint256 proposalId);

    constructor(IVotes _token, TimelockController _timelock, address _treasuryAdderess)
        Governor("Raspberry DAO")
        GovernorSettings(1 /* 1 block */, 10000 /* 1 week */, 0)
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(4)
        GovernorTimelockControl(_timelock)
    {
        treasuryAddress = _treasuryAdderess;
    }

    function lockFundsAndPropose(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, string memory description) external payable {
        uint256 _treasuryBalance = treasuryAddress.balance;
        require(msg.value>=(10*_treasuryBalance)/100,"Not locking sufficient funds");
        fundsLockedforProposals[totalProposals+1]=msg.value;
        uint proposalId = propose(targets,values,calldatas,description);
        proposerLockedAmt[msg.sender][proposalId]=msg.value;
        emit FundsLocked(msg.sender,msg.value,proposalId);
    }

    function withdrawProposerLockedAmounts(uint256 _proposalId) external {
        require(state(_proposalId)==ProposalState.Succeeded,"Proposal hasn't been passed");
        require(proposerLockedAmt[msg.sender][_proposalId]>0,"You havent locked any funds for proposing");
        (bool success,)=msg.sender.call{value:proposerLockedAmt[msg.sender][_proposalId]}("");
        require(success, "Withdrawal failed!");
    }

    // The following functions are overrides required by Solidity.

    function votingDelay()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingDelay();
    }

    function votingPeriod()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingPeriod();
    }

    function quorum(uint256 blockNumber)
        public
        view
        override(IGovernor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    function state(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }

    function propose(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, string memory description)
        public override(Governor, IGovernor)
        returns (uint256)
    {
        uint256 _treasuryBalance = treasuryAddress.balance;
        require(fundsLockedforProposals[totalProposals+1]>(10*_treasuryBalance)/100,"You haven't locked funds");
        return super.propose(targets, values, calldatas, description);
    }

    function proposalThreshold()
        public
        view
        override(Governor, GovernorSettings)
        returns (uint256)
    {
        return super.proposalThreshold();
    }

    function _execute(uint256 proposalId, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
        internal
        override(Governor, GovernorTimelockControl)
    {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
        internal
        override(Governor, GovernorTimelockControl)
        returns (uint256)
    {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor()
        internal
        view
        override(Governor, GovernorTimelockControl)
        returns (address)
    {
        return super._executor();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
