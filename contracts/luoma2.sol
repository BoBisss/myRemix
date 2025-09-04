// SPDX-License-Identifier: MIT
pragma solidity ~0.8.0;

contract luoma{
    uint256[] values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
    string[] symbols = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"];

    function transLuoma(uint256 num)external view returns (string memory){
        bytes memory roman;
        for (uint8 i = 0; i < values.length; i++) {
            uint256 value = values[i];
            string memory symbol = symbols[i];
            while (num >= value){
                 num -= value;
                 roman = abi.encodePacked(roman,symbol);
            }
            if (num == 0){
                break ;
            }
        }
        return string(roman);
    }
}