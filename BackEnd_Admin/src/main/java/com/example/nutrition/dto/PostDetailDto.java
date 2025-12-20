package com.example.nutrition.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PostDetailDto {
    private String postId;
    private String title;
    private String content;
    private List<String> images;
    private String userId;
    private String username;
    private String avatar;
    private Integer status;
    private Integer likeCount;
    private boolean isLiked; // 当前用户是否已点赞
    private List<CommentDto> comments;
}
