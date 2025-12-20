package com.example.nutrition.dto;

import lombok.Data;

import javax.validation.constraints.DecimalMin;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Pattern;
import java.math.BigDecimal;

/**
 * 添加饮食记录请求DTO
 */
@Data
public class AddDietRecordRequest {

    @NotBlank(message = "食物名称不能为空")
    private String foodName;

    @NotNull(message = "热量不能为空")
    @DecimalMin(value = "0.0", message = "热量不能为负数")
    private BigDecimal calories;

    @NotNull(message = "蛋白质不能为空")
    @DecimalMin(value = "0.0", message = "蛋白质不能为负数")
    private BigDecimal protein;

    @NotNull(message = "碳水化合物不能为空")
    @DecimalMin(value = "0.0", message = "碳水化合物不能为负数")
    private BigDecimal carbohydrates;

    @NotNull(message = "脂肪不能为空")
    @DecimalMin(value = "0.0", message = "脂肪不能为负数")
    private BigDecimal fat;

    @NotBlank(message = "餐别不能为空")
    @Pattern(regexp = "breakfast|lunch|dinner|snack", message = "餐别必须是 breakfast, lunch, dinner 或 snack")
    private String mealType;

    @NotBlank(message = "日期不能为空")
    @Pattern(regexp = "\\d{4}-\\d{2}-\\d{2}", message = "日期格式必须为 YYYY-MM-DD")
    private String date;

    private String image; // 图片URL(可选)
}
