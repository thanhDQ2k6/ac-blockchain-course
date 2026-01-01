// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title StudentRegistryV2Optimized
/// @notice Quản lý sinh viên (Admin mode) với code sạch và tối ưu Gas.
contract StudentRegistryV2Optimized {
    
    // =============================================================
    //                           CONSTANTS & TYPES
    // =============================================================

    struct Student {
        // Gom nhóm 32 bytes = 1 Slot -> Tiết kiệm 50% Gas lưu trữ
        bytes30 name;      
        uint8 age;         
        bool isRegistered; 
    } 

    // =============================================================
    //                           STORAGE
    // =============================================================

    address public owner;
    mapping(address => Student) private students;

    // =============================================================
    //                           EVENTS
    // =============================================================

    // Lưu ý: Dùng uint8 cho age trong event để khớp với struct
    event StudentRegistered(address indexed studentAddress, string name, uint8 age);

    // =============================================================
    //                           ERRORS
    // =============================================================

    error NotOwner();
    error StudentAlreadyRegistered();
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
    //                           CONSTRUCTOR
    // =============================================================

    constructor() {
        owner = msg.sender;
    }

    // =============================================================
    //                           LOGIC
    // =============================================================

    /// @notice Admin đăng ký sinh viên (Chỉ tốn 1 lần ghi Storage).
    function registerStudent(
        address _studentAddress, 
        string calldata _name, 
        uint8 _age
    ) 
        external 
        onlyOwner 
    {
        // --- Validation Phase ---

        bool isAlreadyRegistered = students[_studentAddress].isRegistered;
        if (isAlreadyRegistered) {
            revert StudentAlreadyRegistered();
        }

        bytes memory nameAsBytes = bytes(_name);
        bool isNameTooLong = nameAsBytes.length > 30;

        if (isNameTooLong) {
            revert NameTooLong();
        }

        // --- Action Phase ---

        bytes30 packedName = bytes30(nameAsBytes);
        bool status = true;

        // Ghi đè 1 Slot (32 bytes) -> Tối ưu cực đại
        students[_studentAddress] = Student(packedName, _age, status);

        emit StudentRegistered(_studentAddress, _name, _age);
    }

    /// @notice Lấy thông tin sinh viên (Auto convert bytes30 -> string).
    function getStudent(address _user) 
        external 
        view 
        returns (string memory name, uint8 age, bool isRegistered) 
    {
        // --- Fetch Data ---
        Student memory studentRecord = students[_user];

        // --- Transform Data ---
        string memory unpackedName = string(abi.encodePacked(studentRecord.name));

        return (unpackedName, studentRecord.age, studentRecord.isRegistered);
    }
}