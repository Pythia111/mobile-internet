package com.example.nutrition.dto;

import lombok.Data;

import java.util.Map;

@Data
public class UserStatsDto {
    private long totalUsers;
    private long adminUsers;
    private long usersWithPassword;
    private Map<String, Long> dailyRegistrations; // key: yyyy-MM-dd, last 7 days
}
