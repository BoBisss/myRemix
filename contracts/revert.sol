// SPDX-License-Identifier: MIT
pragma solidity ~0.8.0;

// ✅ 反转字符串 (Reverse String)
// 题目描述：反转一个字符串。输入 "abcde"，输出 "edcba"

contract reverseString{
    function reversS(string calldata s)external pure returns (string memory){
        bytes memory a = bytes(s);
        bytes memory b = new bytes(a.length);

        for (uint i = 0; i < a.length; i++) {
            b[i] = a[a.length - 1 - i];
        }
        return string(b);
    }
}