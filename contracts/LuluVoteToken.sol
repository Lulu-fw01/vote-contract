//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./VoteLibrary.sol";

contract LuluVoteToken {
    uint256 constant _initial_supply = 100 * (10**18);

    constructor() {
        owner = msg.sender;
        currentState = VoteLibrary.VotingState.CREATED;
    }

    event participantAdded(address addr);
    event voted(address addr);
    event topicAdded(string topic);
    event votingStarted();
    event votingClosed();

    // Contract creator.
    address private owner;

    // Topics of voting
    mapping(string => VoteLibrary.TopicInfo) private topics;
    string[] private topicNames;

    //address[] participants;
    mapping(address => VoteLibrary.Info) private participants;

    VoteLibrary.VotingState private currentState;

    modifier IsOwner(address addr) {
        require(owner == addr, "You are not owner.");
        _;
    }

    modifier IsParticipant(address addr) {
        require(participants[addr].isInfo, "You are not participant.");
        _;
    }

    modifier CanVote() {
        require(
            currentState == VoteLibrary.VotingState.STARTED,
            "You can't vote now."
        );
        _;
    }

    modifier IsTopic(string memory topic) {
        require(topics[topic].isTopicInfo, "Your topic not in session.");
        _;
    }

    modifier CanParticipantVote(address addr) {
        require(!participants[addr].voted, "You have already voted.");
        _;
    }

    /**
     * Add new voting topic.
     */
    function addTopic(string memory newTopic) public IsOwner(msg.sender) {
        topics[newTopic].sum = 0;
        topics[newTopic].isTopicInfo = true;
        topicNames.push(newTopic);
        emit topicAdded(newTopic);
    }

    /**
     * Add participant to voting session.
     *
     */
    function addParticipant(address newParticipant) public IsOwner(msg.sender) {
        participants[newParticipant].voted = false;
        participants[newParticipant].isInfo = true;
        emit participantAdded(newParticipant);
    }

    /** Vote. */
    function vote(string memory voteTopic)
        public
        CanVote
        IsParticipant(msg.sender)
        CanParticipantVote(msg.sender)
        IsTopic(voteTopic)
    {
        participants[msg.sender].voteTopic = voteTopic;
        participants[msg.sender].voted = true;
        topics[voteTopic].sum++;
        emit voted(msg.sender);
    }

    /**Start voting. */
    function startVoting() public IsOwner(msg.sender) {
        currentState = VoteLibrary.VotingState.STARTED;
        emit votingStarted();
    }

    /**Cloe voting session. */
    function closeVoting() public IsOwner(msg.sender) {
        currentState = VoteLibrary.VotingState.CLOSED;
        emit votingClosed();
    }

    /**
     * Get owner of the contract.
     *
     * @return owner address of the contract.
     */
    function getOwner() public view returns (address) {
        return owner;
    }

    /**
     * Get stte of voting session.
     */
    function getCurrentState() public view returns (VoteLibrary.VotingState) {
        return currentState;
    }

    function getResults() public view returns (string[] memory, uint[] memory) {
        uint[] memory results = new uint[](topicNames.length);
        for (uint i = 0; i < topicNames.length; ++i) {
            results[i] = topics[topicNames[i]].sum;
        }

        return (topicNames, results);
    }
}
