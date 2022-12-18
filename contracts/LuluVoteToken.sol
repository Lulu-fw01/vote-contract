//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LuluVoteToken is ERC20 {
    uint256 constant _initial_supply = 100 * (10**18);

    constructor() ERC20("LuluVoteToken", "LVT") {
        _mint(msg.sender, _initial_supply);
        //revealSpan = 5;
        owner = msg.sender;
    }

    event participantAdded(address addr);

    // Contract creator.
    address private owner;

    address[] participants;

    modifier IsOwner(address addr) {
        require(owner == addr, "You are not owner.");
        _;
    }

    modifier NewParticipant(address addr) {
        
    }

    function addParticipant(address newParticipnt) public IsOwner(msg.sender) {
        participants.push(newParticipnt);
        emit participantAdded(newParticipnt);
    }

    function getOwner() public view returns(address) {
        return owner;
    }
}
