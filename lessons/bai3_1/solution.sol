// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Profile {
    // Biến state (lưu trữ trên blockchain)
    // Đại diện cho thông tin của 1 node (người dùng)
    bytes16 public name;
    uint128 public age;

    // Hàm cập nhật thông tin
    // _name là biến dạng tham chiếu, cần chỉ định vị trí lưu trữ là 'memory' (hoặc 'calldata')
    function setProfile(bytes16 _name, uint128 _age) public {
        name = _name;
        age = _age;
    }
}