const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const hre = require("hardhat");
web3 = require('web3')

describe("LuluVoteToken Tests.", function () {
    async function deployTokenFixture() {
        const [owner, addr1, addr2] = await ethers.getSigners();

        const Token = await ethers.getContractFactory("LuluVoteToken");

        const voteToken = await Token.deploy();
        await voteToken.deployed();

        return { Token, voteToken, owner, addr1, addr2 };
    }

    it("You are not owner test.", async () => {
        const { voteToken, addr1 } = await loadFixture(deployTokenFixture);

        await expect(voteToken.connect(addr1).addParticipant(addr1.getAddress()))
            .to.be.revertedWith('You are not owner.');

    });

    it("Add participant test.", async () => {
        const { voteToken, owner, addr1 } = await loadFixture(deployTokenFixture);
        await expect(voteToken.connect(owner).addParticipant(await addr1.getAddress())).to.emit(voteToken, "participantAdded").withArgs(await addr1.getAddress());

    });

    it("Vote happy path test.", async () => {
        const { voteToken, owner, addr1 } = await loadFixture(deployTokenFixture);
        await voteToken.connect(owner).addParticipant(await addr1.getAddress());
        await expect(voteToken.connect(owner).startVoting()).to.emit(voteToken, "votingStarted");
        //await expect(voteToken.connect(addr1).vote(0)).to.emit(voteToken, "voted").withArgs(await addr1.getAddress());
    });

    it("Voting not started test.", async () => {
        const { voteToken, addr1 } = await loadFixture(deployTokenFixture);
        await expect(voteToken.connect(addr1).vote("aaa")).to.be.revertedWith("You can't vote now.");
    });

    it("Not participant test.", async () => {
        const { voteToken, owner, addr1 } = await loadFixture(deployTokenFixture);
        await expect(voteToken.connect(owner).startVoting()).to.emit(voteToken, "votingStarted");
        await expect(voteToken.connect(addr1).vote("aaa")).to.be.revertedWith("You are not participant.");
    });

    it("Try to vote again test.", async () => {
        const { voteToken, owner, addr1 } = await loadFixture(deployTokenFixture);
        await expect(voteToken.connect(owner).addTopic("aaa")).to.emit(voteToken, "topicAdded").withArgs("aaa");
        await voteToken.connect(owner).addParticipant(await addr1.getAddress());
        await voteToken.connect(owner).startVoting()
        await expect(voteToken.connect(addr1).vote("aaa")).to.emit(voteToken, "voted").withArgs(await addr1.getAddress());
        await expect(voteToken.connect(addr1).vote("aaa")).to.be.revertedWith("You have already voted.");
    });

    it("Not topic test.", async () => {
        const { voteToken, owner, addr1 } = await loadFixture(deployTokenFixture);
        await expect(voteToken.connect(owner).addTopic("aaa")).to.emit(voteToken, "topicAdded").withArgs("aaa");
        await voteToken.connect(owner).addParticipant(await addr1.getAddress());
        await voteToken.connect(owner).startVoting();
        await expect(voteToken.connect(addr1).vote("bbb")).to.be.revertedWith("Your topic not in session.");
    });

    it("State test.", async () => {
        const { voteToken, owner } = await loadFixture(deployTokenFixture);

        expect(await voteToken.getCurrentState()).to.equal(0);
        await voteToken.connect(owner).startVoting();
        expect(await voteToken.getCurrentState()).to.equal(1);
        await expect(voteToken.connect(owner).closeVoting()).to.emit(voteToken, "votingClosed");
        expect(await voteToken.getCurrentState()).to.equal(2);
    });

    it("Can't change state test.", async () => {
        const { voteToken, owner, addr1 } = await loadFixture(deployTokenFixture);

        expect(voteToken.connect(addr1).startVoting()).to.be.revertedWith("You are not owner.");
        await voteToken.connect(owner).startVoting();
        expect(voteToken.connect(addr1).closeVoting()).to.be.revertedWith("You are not owner.");
        await voteToken.connect(owner).closeVoting();
    });

    

});