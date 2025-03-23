// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract NyanWorld is ERC721Upgradeable, ReentrancyGuardUpgradeable, OwnableUpgradeable, UUPSUpgradeable {
    struct Nyan {
        string name;
        string tag;
        address owner;
        uint timestamp;
        uint auctionPrice;
        uint auctionEndTime;
        uint voteCount;
    }

    Nyan[] public nyans;
    mapping(address => bool) public hasVoted;
    uint public votingEndTime;
    address public charity;
    uint public charityFunds;

    event BidPlaced(uint indexed nyanIndex, address bidder, uint amount);

    function initialize(uint _votingDuration, address _charity) public initializer {
        __ERC721_init("NyanWorld", "NYAN");
        __Ownable_init(msg.sender);
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();
        nyans.push(Nyan(unicode"にゃんこ！", unicode"可愛い", msg.sender, block.timestamp, 0, block.timestamp + 3600, 0));
        _mint(msg.sender, 0);
        votingEndTime = block.timestamp + _votingDuration;
        charity = _charity;
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    function registerNyan(string memory _name, string memory _tag, uint _auctionDuration) public {
        uint id = nyans.length;
        nyans.push(Nyan(_name, _tag, msg.sender, block.timestamp, 0, block.timestamp + _auctionDuration, 0));
        _mint(msg.sender, id);
    }

    function bid(uint nyanIndex) public payable nonReentrant {
        Nyan storage nyan = nyans[nyanIndex];
        require(nyanIndex < nyans.length, "Invalid nyan index");
        require(block.timestamp < nyan.auctionEndTime, "Auction has ended");
        require(msg.value > nyan.auctionPrice, "Bid too low");
        require(msg.sender != nyan.owner, "Owner cannot bid");

        uint fee = msg.value / 10;
        uint newPrice = msg.value - fee;
        charityFunds += fee;

        if (nyan.auctionPrice > 0) {
            payable(nyan.owner).transfer(nyan.auctionPrice);
        }
        address oldOwner = nyan.owner;
        nyan.owner = msg.sender;
        nyan.auctionPrice = newPrice;
        _transfer(oldOwner, msg.sender, nyanIndex);
        emit BidPlaced(nyanIndex, msg.sender, msg.value);
    }

    function vote(uint nyanIndex) public {
        require(block.timestamp < votingEndTime, "Voting has ended");
        require(nyanIndex < nyans.length, "Invalid nyan index");
        require(!hasVoted[msg.sender], "You have already voted");
        
        nyans[nyanIndex].voteCount++;
        hasVoted[msg.sender] = true;
    }

    function getNyanCount() public view returns (uint) {
        return nyans.length;
    }

    function getNyan(uint index) public view returns (string memory, string memory, address, uint, uint, uint, uint) {
        require(index < nyans.length, "Index out of range");
        Nyan memory nyan = nyans[index];
        return (nyan.name, nyan.tag, nyan.owner, nyan.timestamp, nyan.auctionPrice, nyan.auctionEndTime, nyan.voteCount);
    }

    function getVoteWinner() public view returns (string memory, uint) {
        require(block.timestamp >= votingEndTime, "Voting still ongoing");
        uint topVotes = 0;
        uint topIndex = 0;
        for (uint i = 0; i < nyans.length; i++) {
            if (nyans[i].voteCount > topVotes) {
                topVotes = nyans[i].voteCount;
                topIndex = i;
            }
        }
        return (nyans[topIndex].name, topVotes);
    }

    function withdrawCharityFunds() public {
        require(msg.sender == charity, "Only charity can withdraw");
        uint amount = charityFunds;
        charityFunds = 0;
        payable(charity).transfer(amount);
    }
}
