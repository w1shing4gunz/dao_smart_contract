// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SimpleDAO {
    
    // Proposal structure
    struct Proposal {
        string description;
        uint256 yesVotes;
        uint256 noVotes;
        uint256 deadline;
        bool executed;
        mapping(address => bool) voted;
    }
    
    // State variables
    address public owner;
    uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;
    mapping(address => bool) public members;
    
    // Events
    event ProposalCreated(uint256 id, string description);
    event Voted(uint256 proposalId, address voter, bool vote);
    event ProposalExecuted(uint256 proposalId, bool passed);
    
    constructor() {
        owner = msg.sender;
        members[msg.sender] = true;
    }
    
    modifier onlyMember() {
        require(members[msg.sender], "Not a member");
        _;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    // Add new member
    function addMember(address _member) external onlyOwner {
        members[_member] = true;
    }
    
    // Create proposal
    function createProposal(string memory _description) external onlyMember {
        proposalCount++;
        Proposal storage newProposal = proposals[proposalCount];
        newProposal.description = _description;
        newProposal.deadline = block.timestamp + 7 days;
        
        emit ProposalCreated(proposalCount, _description);
    }
    
    // Vote on proposal
    function vote(uint256 _proposalId, bool _vote) external onlyMember {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp <= proposal.deadline, "Voting ended");
        require(!proposal.voted[msg.sender], "Already voted");
        
        proposal.voted[msg.sender] = true;
        
        if (_vote) {
            proposal.yesVotes++;
        } else {
            proposal.noVotes++;
        }
        
        emit Voted(_proposalId, msg.sender, _vote);
    }
    
    // Execute proposal
    function executeProposal(uint256 _proposalId) external {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp > proposal.deadline, "Voting still active");
        require(!proposal.executed, "Already executed");
        
        proposal.executed = true;
        bool passed = proposal.yesVotes > proposal.noVotes;
        
        emit ProposalExecuted(_proposalId, passed);
    }
    
    // Get proposal info
    function getProposal(uint256 _proposalId) external view returns (
        string memory description,
        uint256 yesVotes,
        uint256 noVotes,
        uint256 deadline,
        bool executed
    ) {
        Proposal storage proposal = proposals[_proposalId];
        return (
            proposal.description,
            proposal.yesVotes,
            proposal.noVotes,
            proposal.deadline,
            proposal.executed
        );
    }
}
