// SPDX-License-Identifier: MIT
pragma solidity ~0.8.0;

contract binarySearch{
    function search(int256[] memory nums,int256 target)external pure returns(uint256 index) {
        uint256 left = 0;
        uint256 right = nums.length - 1;

        while (left <= right) {
            // 防止 (left + right) 溢出
            uint256 mid = left + (right - left) / 2;

            if (nums[mid] == target) {
                return mid;            // 找到目标
            } else if (nums[mid] < target) {
                left = mid + 1;        // 目标在右半边
            } else {
                right = mid - 1;       // 目标在左半边
            }
        }
    }
}