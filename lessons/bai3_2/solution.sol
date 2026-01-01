// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingEligibility {
    // Biến state
    address public owner; // Người deploy contract
    uint96 public minAge; //Chiếm nốt phần lưu trữ còn lại

    // Constructor chạy 1 lần khi deploy
    constructor() {
        owner = msg.sender; // Lưu địa chỉ người deploy làm owner
        minAge = 18;
    }

    // Hàm kiểm tra điều kiện
    // pure: hàm này không đọc state (nếu chỉ so sánh tham số), nhưng ở đây ta đọc minAge (state) nên dùng view
    function checkEligibility(uint age) public view returns (bool) {
        return age >= minAge;
    }

    // Hàm cập nhật minAge, chỉ owner được gọi
    function updateMinAge(uint _minAge) public {
        // Kiểm tra người gọi có phải owner không
        require(msg.sender == owner, "Only owner can update minAge");
        
        // Kiểm tra xem số nhập vào có vừa với uint96 không
        // type(uint96).max là số lớn nhất mà uint96 chứa được
        require(_minAge <= type(uint96).max, "Age too large for uint96");
        
        minAge = uint96(_minAge);
    }
}