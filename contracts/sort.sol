// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SortedArrayMerger {
    uint256[] private arr1 = [1, 5, 6, 8, 9, 25, 45, 56];
    uint256[] private arr2 = [2, 5, 8, 9, 12, 16, 18, 26, 89];  // 修复：无空槽

    // 返回合并后的有序数组
    function mergeSortedArrays() external view returns (uint256[] memory) {
        uint256[] memory merged = new uint256[](arr1.length + arr2.length);
        uint256 i = 0;  // arr1 的指针
        uint256 j = 0;  // arr2 的指针
        uint256 k = 0;  // merged 的指针

        // 当两个数组都有元素时，比较并合并
        while (i < arr1.length && j < arr2.length) {
            if (arr1[i] < arr2[j]) {
                merged[k] = arr1[i];
                i++;
            } else {
                merged[k] = arr2[j];
                j++;
            }
            k++;
        }

        // 复制 arr1 剩余元素（如果有）
        while (i < arr1.length) {
            merged[k] = arr1[i];
            i++;
            k++;
        }

        // 复制 arr2 剩余元素（如果有）
        while (j < arr2.length) {
            merged[k] = arr2[j];
            j++;
            k++;
        }

        return merged;
    }
}