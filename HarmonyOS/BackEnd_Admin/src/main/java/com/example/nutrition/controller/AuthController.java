package com.example.nutrition.controller;

import com.example.nutrition.common.ApiResponse;
import com.example.nutrition.dto.LoginRequest;
import com.example.nutrition.dto.RegisterRequest;
import com.example.nutrition.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import javax.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@Tag(name = "Auth", description = "用户认证相关接口")
public class AuthController {

    private final UserService userService;

    public AuthController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/register")
    @Operation(summary = "用户注册")
    public ApiResponse<Map<String, Object>> register(@Valid @RequestBody RegisterRequest req) {
        Map<String, Object> data = userService.register(req);
        return ApiResponse.success(data);
    }

    @PostMapping("/login")
    @Operation(summary = "用户登录")
    public ApiResponse<Map<String, Object>> login(@Valid @RequestBody LoginRequest req) {
        Map<String, Object> data = userService.login(req);
        return ApiResponse.success(data);
    }
}
