package com.example.nutrition.dto;

import lombok.Data;

import java.time.Instant;
import java.util.List;

@Data
public class UserSummaryDto {
    private Long id;
    private String phone;
    private String username;
    private String email;
    private String avatar;
    private List<String> roles;
    private Instant createdAt;
}
