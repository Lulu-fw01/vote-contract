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

        //owner = await voteToken.getOwner();

        await expect(voteToken.connect(owner).addParticipant(await addr1.getAddress())).to.emit(voteToken, "participantAdded").withArgs(await addr1.getAddress());

    });

});