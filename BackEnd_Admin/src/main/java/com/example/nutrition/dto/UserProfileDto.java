package com.example.nutrition.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class UserProfileDto {
    private Long userId;
    private String phone;
    private String username;
    private String avatar;
    private String role;
}
