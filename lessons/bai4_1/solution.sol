// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title StudentRegistryOptimized
/// @notice Quản lý sinh viên với cấu trúc lưu trữ tối ưu hóa Gas.
/// @dev Sử dụng kỹ thuật Packing biến để gom dữ liệu vào 1 Slot (32 bytes).
contract StudentRegistryOptimized {
    
    // =============================================================
    //                           CONSTANTS & TYPES
    // =============================================================

    struct Student {
        bytes30 name;      
        uint8 age;         
        bool isRegistered; 
    } 

    // =============================================================
    //                           STORAGE
    // =============================================================

    mapping(address => Student) private students;

    // =============================================================
    //                           ERRORS
    // =============================================================

    error StudentAlreadyRegistered();
    error NameTooLong();

    // =============================================================
    //                           LOGIC
    // =============================================================

    function register(string calldata _name, uint8 _age) external {
        // --- Validation Phase ---
        
        bool isUserAlreadyRegistered = students[msg.sender].isRegistered;
        if (isUserAlreadyRegistered) {
            revert StudentAlreadyRegistered();
        }

        bytes memory nameAsBytes = bytes(_name);
        bool isNameTooLong = nameAsBytes.length > 30;

        if (isNameTooLong) {
            revert NameTooLong();
        }

        // --- Action Phase ---

        // Cast to bytes30 to fit the packed struct
        bytes30 packedName = bytes30(nameAsBytes);
        bool registrationStatus = true;

        students[msg.sender] = Student(packedName, _age, registrationStatus);
    }

    function getStudent(address _user) 
        external 
        view 
        returns (string memory name, uint8 age, bool isRegistered) 
    {
        // --- Fetch Data ---
        Student memory studentRecord = students[_user];
        
        // --- Transform Data ---
        
        // Unpack bytes30 back to string, removing null padding
        string memory unpackedName = string(abi.encodePacked(studentRecord.name));

        return (unpackedName, studentRecord.age, studentRecord.isRegistered);
    }
}