// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedVoting {
    struct Proposal {
        string description;
        uint256 votes;
        mapping(address => bool) hasVoted;
    }

    mapping(uint256 => Proposal) public proposals;
    uint256 public proposalCount;
    uint256 public votingEndTime;

    event ProposalAdded(uint256 indexed proposalId, string description);
    event Voted(address indexed voter, uint256 indexed proposalId);

    constructor(uint256 _votingDuration) {
        votingEndTime = block.timestamp + _votingDuration;
    }

    function addProposal(string memory _description) external {
        require(block.timestamp < votingEndTime, "Voting period has ended");

        uint256 proposalId = proposalCount++;
        proposals[proposalId].description = _description;

        emit ProposalAdded(proposalId, _description);
    }

    function vote(uint256 _proposalId) external {
        require(block.timestamp < votingEndTime, "Voting period has ended");
        require(_proposalId < proposalCount, "Invalid proposal ID");
        require(!proposals[_proposalId].hasVoted[msg.sender], "Already voted");

        proposals[_proposalId].votes++;
        proposals[_proposalId].hasVoted[msg.sender] = true;

        emit Voted(msg.sender, _proposalId);
    }

    function getWinner() external view returns (uint256 winnerId, string memory winnerDescription, uint256 winningVotes) {
        require(block.timestamp >= votingEndTime, "Voting period has not ended yet");

        for (uint256 i = 0; i < proposalCount; i++) {
            if (proposals[i].votes > winningVotes) {
                winnerId = i;
                winnerDescription = proposals[i].description;
                winningVotes = proposals[i].votes;
            }
        }
    }
}
