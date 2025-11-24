package com.example.nutrition.dto;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Pattern;
import lombok.Data;

@Data
public class LoginSmsRequest {
    @NotBlank
    @Pattern(regexp = "^\\+?\\d{6,20}$")
    private String phone;

    @NotBlank
    private String code;
}
