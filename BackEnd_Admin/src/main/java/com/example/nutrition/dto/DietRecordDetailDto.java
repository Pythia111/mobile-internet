package com.example.nutrition.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * 饮食记录详情DTO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DietRecordDetailDto {
    private String recordId;
    private String foodName;
    private BigDecimal calories;
    private BigDecimal protein;
    private BigDecimal carbohydrates;
    private BigDecimal fat;
    private BigDecimal weight;
    private String image;
}
