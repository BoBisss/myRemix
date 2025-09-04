// SPDX-License-Identifier: MIT
pragma solidity ~0.8.0;

// ✅  用 solidity 实现整数转罗马数字
// 	题目描述在 https://leetcode.cn/problems/roman-to-integer/description/3.

contract luoma{
    mapping(bytes1 => uint256) number;

    constructor(){
        number['I'] = 1;
        number['V'] = 5;
        number['X'] = 10;
        number['L'] = 50;
        number['C'] = 100;
        number['D'] = 500;
        number['M'] = 1000;
    }

    function calcute(string calldata src)external view returns (uint256){
        uint256 num = 0;
        bytes memory a = bytes(src);
        if (a.length == 1){
            return number[a[0]];
        }
        for (uint256 i = 1; i < a.length; i++) {
            if (number[a[i-1]] >= number[a[i]]){
                num += number[a[i-1]];
                if (i == a.length - 1){
                    num += number[a[i]];
                }
                continue ;
            }
            uint256 n = number[a[i]] - number[a[i-1]];
            num += n;
            i ++;
        }
        return num;
    }
}

