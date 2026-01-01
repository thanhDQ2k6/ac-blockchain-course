// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title VotingOptimized
/// @notice Hệ thống bầu cử tối ưu hóa Gas cực đại (1 Slot/Candidate).
contract VotingOptimized {

    // =============================================================
    //                           TYPES
    // =============================================================

    struct Candidate {
        // Tối ưu Storage: 
        // name (28 bytes) + voteCount (4 bytes) = 32 bytes (1 Slot).
        // uint32 max = 4.2 tỷ phiếu (Dư sức cho hầu hết quy mô bầu cử).
        bytes28 name;      
        uint32 voteCount;  
    }

    // =============================================================
    //                           STORAGE
    // =============================================================

    address public owner;
    uint256 public candidateCount; // ID counter

    mapping(uint256 => Candidate) public candidates;
    mapping(address => bool) public hasVoted;

    // =============================================================
    //                           EVENTS
    // =============================================================

    event Voted(address indexed voter, uint256 candidateId);
    event CandidateAdded(uint256 candidateId, string name);

    // =============================================================
    //                           ERRORS
    // =============================================================

    error NotOwner();
    error AlreadyVoted();
    error CandidateDoesNotExist();
    error NameTooLong();

    // =============================================================
    //                           MODIFIERS
    // =============================================================

    modifier onlyOwner() {
        bool isCallerOwner = msg.sender == owner;
        if (!isCallerOwner) {
            revert NotOwner();
        }
        _;
    }

    // =============================================================
    //                           LOGIC
    // =============================================================

    constructor() {
        owner = msg.sender;
    }

    function addCandidate(string calldata _name) external onlyOwner {
        // --- Validation Phase ---
        
        bytes memory nameAsBytes = bytes(_name);
        bool isNameTooLong = nameAsBytes.length > 28;

        if (isNameTooLong) {
            revert NameTooLong();
        }

        // --- Action Phase ---

        // 1. Increment ID
        // Unchecked vì candidateCount khó mà tràn 2^256
        uint256 newId;
        unchecked {
            candidateCount++;
            newId = candidateCount;
        }
        
        // 2. Pack data & Save
        bytes28 packedName = bytes28(nameAsBytes);
        
        // Ghi vào Storage (Chỉ tốn 1 SSTORE cho cả tên và số phiếu khởi tạo)
        candidates[newId] = Candidate(packedName, 0);

        emit CandidateAdded(newId, _name);
    }

    function vote(uint256 _candidateId) external {
        // --- Validation Phase ---

        bool isUserVoted = hasVoted[msg.sender];
        if (isUserVoted) {
            revert AlreadyVoted();
        }

        // Check sự tồn tại của Candidate. 
        // Vì Candidate pack trong 1 slot, ta đọc cả struct ra memory để check cho rẻ.
        Candidate memory targetCandidate = candidates[_candidateId];
        
        // Nếu name rỗng (0x00...) nghĩa là candidate không tồn tại
        bool isCandidateInvalid = targetCandidate.name == bytes28(0);
        if (isCandidateInvalid) {
            revert CandidateDoesNotExist();
        }

        // --- Action Phase ---

        hasVoted[msg.sender] = true;

        // Tăng phiếu bầu
        // Unchecked vì uint32 (4 tỷ) khó tràn trong ngữ cảnh thực tế, 
        // và logic vote thường +1 nên rất an toàn.
        unchecked {
            // Lưu ý: Phải ghi thẳng vào storage pointer
            candidates[_candidateId].voteCount++;
        }

        emit Voted(msg.sender, _candidateId);
    }

    /// @notice Helper để frontend lấy tên dạng string thay vì bytes28
    function getCandidateName(uint256 _candidateId) external view returns (string memory) {
        return string(abi.encodePacked(candidates[_candidateId].name));
    }
}