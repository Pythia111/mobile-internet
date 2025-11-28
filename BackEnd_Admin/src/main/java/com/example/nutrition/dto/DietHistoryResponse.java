package com.example.nutrition.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * 饮食历史响应DTO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DietHistoryResponse {
    private String date;
    private List<MealDto> meals;
}
