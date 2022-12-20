//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

library VoteLibrary {
    // Participant info.
    struct Info {
        string voteTopic;
        bool voted;
        bool isInfo;
    }

    struct TopicInfo {
        uint sum;
        bool isTopicInfo;
    }

    enum VotingState {
        CREATED,
        STARTED,
        CLOSED
    }
}
