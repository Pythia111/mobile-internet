package com.example.nutrition.dto;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Pattern;
import lombok.Data;

@Data
public class SendCodeRequest {
    @NotBlank
    @Pattern(regexp = "^\\+?\\d{6,20}$", message = "手机号格式不正确")
    private String phone;
}
