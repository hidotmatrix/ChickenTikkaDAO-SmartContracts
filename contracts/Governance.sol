// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract Governance is
    Governor,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorVotesQuorumFraction,
    GovernorTimelockControl
{
    /**@notice Struct storing proposal data
        @dev iterator - proposal iterator
        @dev description - proposal description
        @dev proposalId - proposal Id
        @dev startBlock - proposal starting block
        @dev endBlock - proposal ending block
    */
    struct Proposal {
        uint256 iterator;
        string description;
        uint256 proposalId;
        uint256 startBlock;
        uint256 endBlock;
    }

    // Mapping to store proposal struct based on their iterator Ids
    mapping(uint256 => Proposal) public proposals;

    // voting delay
    uint256 public votingDelay_;

    // voting period
    uint256 public votingPeriod_;

    // propsal iterator
    uint256 public proposalIterator;

    /**@notice contract constructor
        @param _token ERC20Votes token
        @param _timelock Timelock contract
        @param _quorum quorum
        @param _votingDelay voting delay     
        @param _votingPeriod voting period
     */
    constructor(
        ERC20Votes _token,
        TimelockController _timelock,
        uint256 _quorum,
        uint256 _votingDelay,
        uint256 _votingPeriod
    )
        Governor("DApp University DAO")
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(_quorum)
        GovernorTimelockControl(_timelock)
    {
        votingDelay_ = _votingDelay;
        votingPeriod_ = _votingPeriod;
    }

    /**@notice votingDelay
        @dev returns uint256 votingDelay value
     */
    function votingDelay() public view override returns (uint256) {
        return votingDelay_;
    }

    /**@notice votingPeriod
        @dev returns uint256 votingPeriod_ value
     */
    function votingPeriod() public view override returns (uint256) {
        return votingPeriod_;
    }

    // The following functions are overrides required by Solidity

    /**@notice quorum
        @dev returns uint256 quorum value    
        @param blockNumber blockNumber
     */
    function quorum(uint256 blockNumber)
        public
        view
        override(IGovernor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    /**@notice getVotes
        @dev returns votes of a account
        @param account account address
        @param blockNumber blockNumber
     */
    function getVotes(address account, uint256 blockNumber)
        public
        view
        override(Governor, IGovernor)
        returns (uint256)
    {
        return super.getVotes(account, blockNumber);
    }

    /**@notice state
        @dev returns the current state of the proposal
        @param proposalId proposal Id
     */
    function state(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }

    /**@notice propose
        @dev create a new proposal
        @param targets targets array (treasuries, actions, etc)
        @param values values array (amount of ethers you want to send)
        @param calldatas encoded functions
        @param description proposal description
     */
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) public override(Governor, IGovernor) returns (uint256) {
        uint256 proposal = super.propose(
            targets,
            values,
            calldatas,
            description
        );
        uint256 start = proposalSnapshot(proposal);
        uint256 end = proposalDeadline(proposal);
        proposalIterator++;
        proposals[proposalIterator] = Proposal(
            proposalIterator,
            description,
            proposal,
            start,
            end
        );
        return proposal;
    }

    /**@notice _execute
        @dev create a new proposal
        @param targets targets array (treasuries, actions, etc)
        @param values values array (amount of ethers you want to send)
        @param calldatas encoded functions
        @param descriptionHash proposal description hash
     */
    function _execute(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    /**@notice _execute
        @dev cancel a proposal
        @param targets targets array (treasuries, actions, etc)
        @param values values array (amount of ethers you want to send)
        @param calldatas encoded functions
        @param descriptionHash proposal description hash
     */
    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) returns (uint256) {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    /**@notice _executor
        @dev return address of the executor 
     */
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