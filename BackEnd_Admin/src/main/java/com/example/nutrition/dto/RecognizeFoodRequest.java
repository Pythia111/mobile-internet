package com.example.nutrition.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * AI食物识别请求DTO
 */
@Data
public class RecognizeFoodRequest {

    @NotBlank(message = "食物描述不能为空")
    private String description; // 食物描述文字
}
