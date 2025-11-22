package com.example.nutrition.dto;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;
import lombok.Data;

@Data
public class RegisterRequest {
    @NotBlank(message = "Phone is required")
    @Pattern(regexp = "^\\+?\\d{6,20}$", message = "Invalid phone format")
    private String phone;

    @NotBlank(message = "Password is required")
    @Size(min = 6, message = "Password must be at least 6 characters")
    @Pattern(regexp = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{6,}$", message = "Password must contain letters and numbers")
    private String password;

    @NotBlank(message = "Username is required")
    @Size(min = 1, max = 64)
    private String username;
}
