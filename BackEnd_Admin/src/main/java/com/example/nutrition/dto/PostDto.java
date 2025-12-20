package com.example.nutrition.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PostDto {
    private String postId;
    private String title;
    private String content;
    private List<String> images;
    private String userId;
    private String username;
    private String avatar;
    private Integer status;
    private Integer likeCount;
    private Integer commentCount;
    private Instant createdAt;
    private Instant updatedAt;
}

