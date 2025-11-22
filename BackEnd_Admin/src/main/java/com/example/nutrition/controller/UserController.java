package com.example.nutrition.controller;

import com.example.nutrition.common.ApiResponse;
import com.example.nutrition.dto.UpdateProfileRequest;
import com.example.nutrition.dto.UserProfileDto;
import com.example.nutrition.entity.User;
import com.example.nutrition.repository.UserRepository;
import com.example.nutrition.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import javax.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/user")
@Tag(name = "User", description = "个人中心相关接口")
public class UserController {
    private final UserService userService;
    private final UserRepository userRepository;

    public UserController(UserService userService, UserRepository userRepository) {
        this.userService = userService;
        this.userRepository = userRepository;
    }

    @GetMapping("/profile")
    @Operation(summary = "获取个人资料")
    public ApiResponse<UserProfileDto> getProfile(Authentication authentication) {
        User user = userRepository.findByPhone(authentication.getName())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        return ApiResponse.success(userService.getProfile(user.getId()));
    }

    @PutMapping("/profile")
    @Operation(summary = "修改个人资料")
    public ApiResponse<Void> updateProfile(Authentication authentication, @Valid @RequestBody UpdateProfileRequest req) {
        User user = userRepository.findByPhone(authentication.getName())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        userService.updateProfile(user.getId(), req);
        return ApiResponse.success(null);
    }
}
