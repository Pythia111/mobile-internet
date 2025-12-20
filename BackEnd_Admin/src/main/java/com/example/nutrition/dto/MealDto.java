package com.example.nutrition.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * 单餐饮食记录DTO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MealDto {
    private String mealType;
    private List<DietRecordDetailDto> foods;
}
