package com.example.nutrition.service;

import com.example.nutrition.dto.*;
import com.example.nutrition.entity.Comment;
import com.example.nutrition.entity.Post;
import com.example.nutrition.entity.PostLike;
import com.example.nutrition.entity.User;
import com.example.nutrition.repository.CommentRepository;
import com.example.nutrition.repository.PostLikeRepository;
import com.example.nutrition.repository.PostRepository;
import com.example.nutrition.repository.UserRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ForumService {

    private final PostRepository postRepository;
    private final CommentRepository commentRepository;
    private final PostLikeRepository postLikeRepository;
    private final UserRepository userRepository;
    private final ObjectMapper objectMapper;

    /**
     * 创建帖子
     */
    @Transactional
    public PostDto createPost(Long userId, CreatePostRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));

        Post post = Post.builder()
                .title(request.getTitle())
                .content(request.getContent())
                .images(convertListToJson(request.getImages()))
                .user(user)
                .creatorName(request.getCreatorName())
                .creatorAvatar(request.getCreatorAvatar())
                .status(0) // 默认公开
                .likeCount(0)
                .commentCount(0)
                .build();

        post = postRepository.save(post);
        return convertToPostDto(post);
    }

    /**
     * 获取帖子列表
     */
    public Page<PostDto> getPosts(Integer status, int page, int size) {
        Pageable pageable = PageRequest.of(page - 1, size);
        Page<Post> posts;

        if (status != null) {
            posts = postRepository.findByStatusOrderByCreatedAtDesc(status, pageable);
        } else {
            // 默认不显示已删除的帖子
            posts = postRepository.findByStatusNotOrderByCreatedAtDesc(3, pageable);
        }

        return posts.map(this::convertToPostDto);
    }

    /**
     * 获取帖子详情
     */
    @Transactional(readOnly = true)
    public PostDetailDto getPostDetail(Long postId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new IllegalArgumentException("帖子不存在"));

        if (post.getStatus() == 3) {
            throw new IllegalArgumentException("帖子已删除");
        }

        // 在事务中获取评论列表，避免 LazyInitializationException
        List<CommentDto> comments = commentRepository.findByPostIdOrderByCreatedAtAsc(postId).stream()
                .map(this::convertToCommentDto)
                .collect(Collectors.toList());

        return PostDetailDto.builder()
                .postId(post.getId().toString())
                .title(post.getTitle())
                .content(post.getContent())
                .images(convertJsonToList(post.getImages()))
                .userId(post.getUser().getId().toString())
                .username(post.getCreatorName())
                .avatar(post.getCreatorAvatar())
                .status(post.getStatus())
                .likeCount(post.getLikeCount())
                .comments(comments)
                .build();
    }

    /**
     * 点赞/取消点赞帖子
     */
    @Transactional
    public boolean toggleLike(Long postId, Long userId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new IllegalArgumentException("帖子不存在"));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));

        java.util.Optional<PostLike> existingLike = postLikeRepository.findByPostIdAndUserId(postId, userId);

        if (existingLike.isPresent()) {
            // 取消点赞
            postLikeRepository.delete(existingLike.get());
            post.setLikeCount(Math.max(0, post.getLikeCount() - 1));
            postRepository.save(post);
            return false;
        } else {
            // 点赞
            PostLike like = PostLike.builder()
                    .post(post)
                    .user(user)
                    .build();
            postLikeRepository.save(like);
            post.setLikeCount(post.getLikeCount() + 1);
            postRepository.save(post);
            return true;
        }
    }

    /**
     * 添加评论
     */
    @Transactional
    public CommentDto addComment(Long postId, Long userId, CreateCommentRequest request) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new IllegalArgumentException("帖子不存在"));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));

        Comment comment = Comment.builder()
                .content(request.getContent())
                .post(post)
                .user(user)
                .username(request.getUsername())
                .avatar(request.getAvatar())
                .build();

        comment = commentRepository.save(comment);

        // 更新帖子评论数
        post.setCommentCount(post.getCommentCount() + 1);
        postRepository.save(post);

        return convertToCommentDto(comment);
    }

    /**
     * 更新帖子状态
     */
    @Transactional
    public UpdatePostStatusResponse updatePostStatus(Long postId, Long userId, String userRole, UpdatePostStatusRequest request) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new IllegalArgumentException("帖子不存在"));

        Integer oldStatus = post.getStatus();
        Integer newStatus = determineNewStatus(request.getAction(), userRole, post, userId);

        post.setStatus(newStatus);
        postRepository.save(post);

        return UpdatePostStatusResponse.builder()
                .postId(post.getId().toString())
                .newStatus(newStatus)
                .oldStatus(oldStatus)
                .operator(UpdatePostStatusResponse.OperatorInfo.builder()
                        .id(userId.toString())
                        .role(userRole)
                        .build())
                .updatedAt(Instant.now())
                .build();
    }

    /**
     * 获取用户的帖子列表
     */
    public UserPostsDto getUserPosts(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));

        List<Post> posts = postRepository.findByUserIdOrderByCreatedAtDesc(userId);
        List<PostDto> postDtos = posts.stream()
                .filter(p -> p.getStatus() != 3) // 不包含已删除的
                .map(this::convertToPostDto)
                .collect(Collectors.toList());

        return UserPostsDto.builder()
                .userId(user.getId().toString())
                .username(user.getName())
                .avatar(user.getAvatarUrl())
                .posts(postDtos)
                .build();
    }

    /**
     * 根据action和用户角色确定新状态
     */
    private Integer determineNewStatus(String action, String userRole, Post post, Long userId) {
        switch (action.toLowerCase()) {
            case "delete":
                // 用户删除自己的帖子
                if (!post.getUser().getId().equals(userId)) {
                    throw new IllegalArgumentException("无权删除他人的帖子");
                }
                return 3; // 已删除

            case "privatize":
                // 用户可以隐藏自己的帖子，管理员可以隐藏任何帖子
                if (!"admin".equalsIgnoreCase(userRole) && !post.getUser().getId().equals(userId)) {
                    throw new IllegalArgumentException("权限不足，无法隐藏他人的帖子");
                }
                return 2; // 私密

            case "publicize":
            case "approve":
                // 管理员审核通过/公开帖子
                if (!"admin".equalsIgnoreCase(userRole)) {
                    throw new IllegalArgumentException("权限不足，仅管理员可执行此操作");
                }
                return 0; // 公开

            case "reject":
                // 管理员驳回/设为违规
                if (!"admin".equalsIgnoreCase(userRole)) {
                    throw new IllegalArgumentException("权限不足，仅管理员可执行此操作");
                }
                return 2; // 违规/私密

            default:
                throw new IllegalArgumentException("无效的操作类型: " + action);
        }
    }

    /**
     * 转换 Post 到 PostDto
     */
    private PostDto convertToPostDto(Post post) {
        return PostDto.builder()
                .postId(post.getId().toString())
                .title(post.getTitle())
                .content(post.getContent())
                .images(convertJsonToList(post.getImages()))
                .userId(post.getUser().getId().toString())
                .username(post.getCreatorName())
                .avatar(post.getCreatorAvatar())
                .status(post.getStatus())
                .likeCount(post.getLikeCount())
                .commentCount(post.getCommentCount())
                .createdAt(post.getCreatedAt())
                .updatedAt(post.getUpdatedAt())
                .build();
    }

    /**
     * 转换 Comment 到 CommentDto
     */
    private CommentDto convertToCommentDto(Comment comment) {
        return CommentDto.builder()
                .commentId(comment.getId().toString())
                .content(comment.getContent())
                .userId(comment.getUser().getId().toString())
                .username(comment.getUsername())
                .avatar(comment.getAvatar())
                .createdAt(comment.getCreatedAt())
                .build();
    }

    /**
     * 将 List 转换为 JSON 字符串
     */
    private String convertListToJson(List<String> list) {
        if (list == null || list.isEmpty()) {
            return "[]";
        }
        try {
            return objectMapper.writeValueAsString(list);
        } catch (JsonProcessingException e) {
            return "[]";
        }
    }

    /**
     * 将 JSON 字符串转换为 List
     */
    private List<String> convertJsonToList(String json) {
        if (json == null || json.trim().isEmpty()) {
            return new ArrayList<>();
        }
        try {
            return objectMapper.readValue(json, new TypeReference<List<String>>() {});
        } catch (JsonProcessingException e) {
            return new ArrayList<>();
        }
    }
}

