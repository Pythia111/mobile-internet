package com.example.nutrition.controller;

import com.example.nutrition.common.ApiResponse;
import com.example.nutrition.dto.*;
import com.example.nutrition.entity.User;
import com.example.nutrition.repository.UserRepository;
import com.example.nutrition.service.ForumService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/forum")
@Tag(name = "Forum", description = "论坛相关接口")
@RequiredArgsConstructor
public class ForumController {

    private final ForumService forumService;
    private final UserRepository userRepository;

    /**
     * 3.1 发布帖子
     */
    @PostMapping("/posts")
    @Operation(summary = "发布帖子")
    public ApiResponse<Map<String, String>> createPost(
            Authentication authentication,
            @Valid @RequestBody CreatePostRequest request) {

        User user = getCurrentUser(authentication);
        PostDto post = forumService.createPost(user.getId(), request);

        Map<String, String> response = new HashMap<>();
        response.put("postId", post.getPostId());
        response.put("creatorName", post.getUsername());
        response.put("creatorAvatar", post.getAvatar());

        return ApiResponse.success("发布成功", response);
    }

    /**
     * 3.2 获取论坛帖子列表
     */
    @GetMapping("/posts")
    @Operation(summary = "获取论坛帖子列表")
    public ApiResponse<Map<String, Object>> getPosts(
            @Parameter(description = "页码，默认1") @RequestParam(defaultValue = "1") int page,
            @Parameter(description = "每页数量，默认10") @RequestParam(defaultValue = "10") int size,
            @Parameter(description = "状态筛选：0=公开, 1=待审核, 2=私密, 3=已删除") @RequestParam(required = false) Integer status) {

        Page<PostDto> posts = forumService.getPosts(status, page, size);

        Map<String, Object> response = new HashMap<>();
        response.put("posts", posts.getContent());
        response.put("totalPages", posts.getTotalPages());
        response.put("totalElements", posts.getTotalElements());
        response.put("currentPage", page);

        return ApiResponse.success(response);
    }

    /**
     * 3.3 获取帖子详情
     */
    @GetMapping("/posts/{postId}")
    @Operation(summary = "获取帖子详情")
    public ApiResponse<PostDetailDto> getPostDetail(@PathVariable Long postId) {
        PostDetailDto post = forumService.getPostDetail(postId);
        return ApiResponse.success(post);
    }

    /**
     * 3.4 点赞帖子
     */
    @PostMapping("/posts/{postId}/like")
    @Operation(summary = "点赞/取消点赞帖子")
    public ApiResponse<Map<String, Boolean>> toggleLike(
            Authentication authentication,
            @PathVariable Long postId) {

        User user = getCurrentUser(authentication);
        boolean liked = forumService.toggleLike(postId, user.getId());

        Map<String, Boolean> response = new HashMap<>();
        response.put("liked", liked);

        return ApiResponse.success("操作成功", response);
    }

    /**
     * 3.5 评论帖子
     */
    @PostMapping("/posts/{postId}/comments")
    @Operation(summary = "评论帖子")
    public ApiResponse<Map<String, String>> addComment(
            Authentication authentication,
            @PathVariable Long postId,
            @Valid @RequestBody CreateCommentRequest request) {

        User user = getCurrentUser(authentication);
        CommentDto comment = forumService.addComment(postId, user.getId(), request);

        Map<String, String> response = new HashMap<>();
        response.put("commentId", comment.getCommentId());
        response.put("username", comment.getUsername());
        response.put("avatar", comment.getAvatar());

        return ApiResponse.success("评论成功", response);
    }

    /**
     * 3.6 更新帖子状态
     */
    @PutMapping("/posts/{postId}/status")
    @Operation(summary = "更新帖子状态（用户删帖/管理员管理）")
    public ApiResponse<UpdatePostStatusResponse> updatePostStatus(
            Authentication authentication,
            @PathVariable Long postId,
            @Valid @RequestBody UpdatePostStatusRequest request) {

        User user = getCurrentUser(authentication);
        String userRole = getUserRole(user);

        UpdatePostStatusResponse response = forumService.updatePostStatus(
                postId, user.getId(), userRole, request);

        return ApiResponse.success("操作成功", response);
    }

    /**
     * 3.7 获取用户主页
     */
    @GetMapping("/user/{userId}/posts")
    @Operation(summary = "获取用户主页及其帖子")
    public ApiResponse<UserPostsDto> getUserPosts(@PathVariable Long userId) {
        UserPostsDto userPosts = forumService.getUserPosts(userId);
        return ApiResponse.success(userPosts);
    }

    /**
     * 获取当前登录用户
     */
    private User getCurrentUser(Authentication authentication) {
        return userRepository.findByPhone(authentication.getName())
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));
    }

    /**
     * 获取用户角色
     */
    private String getUserRole(User user) {
        boolean isAdmin = user.getRoles().stream()
                .anyMatch(role -> "ROLE_ADMIN".equals(role.getName()));
        return isAdmin ? "admin" : "user";
    }
}

