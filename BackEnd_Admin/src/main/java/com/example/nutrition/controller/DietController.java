package com.example.nutrition.controller;

import com.example.nutrition.common.ApiResponse;
import com.example.nutrition.dto.*;
import com.example.nutrition.entity.User;
import com.example.nutrition.repository.UserRepository;
import com.example.nutrition.service.DietService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;

/**
 * 饮食记录控制器
 */
@RestController
@RequestMapping("/api/diet")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "饮食记录", description = "饮食记录与食物识别相关接口")
public class DietController {

    private final DietService dietService;
    private final UserRepository userRepository;

    /**
     * 2.1 添加饮食记录
     */
    @PostMapping("/records")
    @Operation(summary = "添加饮食记录", description = "添加用户的饮食记录")
    public ResponseEntity<ApiResponse<AddDietRecordResponse>> addDietRecord(
            @Valid @RequestBody AddDietRecordRequest request,
            Authentication authentication) {

        Long userId = getUserIdFromAuth(authentication);
        AddDietRecordResponse response = dietService.addDietRecord(userId, request);

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * 2.2 AI食物识别
     */
    @PostMapping("/recognize")
    @Operation(summary = "AI食物识别", description = "通过文字描述识别食物并返回营养信息")
    public ResponseEntity<ApiResponse<FoodInfoDto>> recognizeFood(
            @Valid @RequestBody RecognizeFoodRequest request,
            Authentication authentication) {

        FoodInfoDto foodInfo = dietService.recognizeFood(request.getDescription());
        return ResponseEntity.ok(ApiResponse.success(foodInfo));
    }

    /**
     * 2.3 搜索食物
     */
    @GetMapping("/search")
    @Operation(summary = "搜索食物", description = "根据关键词搜索食物营养信息")
    public ResponseEntity<ApiResponse<List<FoodInfoDto>>> searchFood(
            @RequestParam String keyword,
            Authentication authentication) {

        List<FoodInfoDto> foods = dietService.searchFood(keyword);
        return ResponseEntity.ok(ApiResponse.success(foods));
    }

    /**
     * 2.4 获取饮食历史
     */
    @GetMapping("/records/all")
    @Operation(summary = "获取饮食历史", description = "获取用户的饮食历史记录")
    public ResponseEntity<ApiResponse<DietHistoryResponse>> getDietHistory(
            Authentication authentication) {

        Long userId = getUserIdFromAuth(authentication);
        DietHistoryResponse history = dietService.getDietHistory(userId);

        return ResponseEntity.ok(ApiResponse.success(history));
    }

    /**
     * 2.5 删除饮食记录
     */
    @DeleteMapping("/records/{recordId}")
    @Operation(summary = "删除饮食记录", description = "删除指定的饮食记录")
    public ResponseEntity<ApiResponse<String>> deleteDietRecord(
            @PathVariable Long recordId,
            Authentication authentication) {

        Long userId = getUserIdFromAuth(authentication);
        dietService.deleteDietRecord(userId, recordId);

        return ResponseEntity.ok(ApiResponse.success("删除成功"));
    }

    /**
     * 从认证信息中获取用户ID
     */
    private Long getUserIdFromAuth(Authentication authentication) {
        if (authentication == null || authentication.getPrincipal() == null) {
            throw new IllegalStateException("未认证的用户");
        }

        Object principal = authentication.getPrincipal();
        if (principal instanceof UserDetails) {
            String phone = ((UserDetails) principal).getUsername();
            // 根据phone查询用户获取userId
            User user = userRepository.findByPhone(phone)
                    .orElseThrow(() -> new IllegalStateException("用户不存在"));
            return user.getId();
        }

        throw new IllegalStateException("无效的认证信息");
    }
}
