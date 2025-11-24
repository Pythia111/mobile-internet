package com.example.nutrition.controller;

import com.example.nutrition.common.ApiResponse;
import com.example.nutrition.dto.UserStatsDto;
import com.example.nutrition.dto.UserSummaryDto;
import com.example.nutrition.entity.User;
import com.example.nutrition.repository.UserRepository;
import com.example.nutrition.service.UserStatsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin/users")
@Tag(name = "AdminUser", description = "管理员用户管理接口")
@PreAuthorize("hasRole('ADMIN')")
public class AdminUserController {

    private final UserRepository userRepository;
    private final UserStatsService userStatsService;

    public AdminUserController(UserRepository userRepository, UserStatsService userStatsService) {
        this.userRepository = userRepository;
        this.userStatsService = userStatsService;
    }

    @GetMapping
    @Operation(summary = "获取所有用户列表")
    public ApiResponse<List<UserSummaryDto>> getAllUsers() {
        List<User> users = userRepository.findAll();
        List<UserSummaryDto> dtos = users.stream().map(this::convertToDto).collect(Collectors.toList());
        return ApiResponse.success(dtos);
    }

    @GetMapping("/stats")
    @Operation(summary = "获取用户统计数据")
    public ApiResponse<UserStatsDto> getUserStats(@RequestParam(defaultValue = "7") int days) {
        return ApiResponse.success(userStatsService.buildStats(days));
    }

    private UserSummaryDto convertToDto(User user) {
        UserSummaryDto dto = new UserSummaryDto();
        dto.setId(user.getId());
        dto.setPhone(user.getPhone());
        dto.setUsername(user.getName());
        dto.setEmail(user.getEmail());
        dto.setAvatar(user.getAvatarUrl());
        dto.setRoles(user.getRoles().stream().map(r -> r.getName()).collect(Collectors.toList()));
        dto.setCreatedAt(user.getCreatedAt());
        return dto;
    }
}
