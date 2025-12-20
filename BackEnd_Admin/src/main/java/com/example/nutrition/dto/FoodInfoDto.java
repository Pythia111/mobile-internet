package com.example.nutrition.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * 食物信息DTO (用于AI识别和搜索)
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class FoodInfoDto {
    private String foodName;
    private BigDecimal calories;
    private BigDecimal protein;
    private BigDecimal carbohydrates;
    private BigDecimal fat;
}
