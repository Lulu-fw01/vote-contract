//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Participant.sol";

contract LuluVoteToken is ERC20 {
    uint256 constant _initial_supply = 100 * (10**18);

    constructor() ERC20("LuluVoteToken", "LVT") {
        _mint(msg.sender, _initial_supply);
        //revealSpan = 5;
        owner = msg.sender;
    }

    event participantAdded(address addr);
    event voted(address addr);

    // Contract creator.
    address private owner;

    //address[] participants;
    mapping(address => Participant.Info) participants;

    modifier IsOwner(address addr) {
        require(owner == addr, "You are not owner.");
        _;
    }

    modifier IsParticipant(address addr) {
        require(participants[addr].isInfo, "You are not participant");
        _;
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

    function vote(uint voteNum) public IsParticipant(msg.sender) {
        // TODO add modifier which check voteNum.
        participants[msg.sender].voteNum = voteNum;
        emit voted(msg.sender);
    }

    /**
     * Get owner of the contract.
     *
     * @return owner address of the contract.
     */
    function getOwner() public view returns (address) {
        return owner;
    }
}
