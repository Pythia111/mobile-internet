package com.example.nutrition.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 添加饮食记录响应DTO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AddDietRecordResponse {
    private String recordId;
}
