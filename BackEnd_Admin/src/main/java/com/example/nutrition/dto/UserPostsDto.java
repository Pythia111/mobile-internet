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
public class UserPostsDto {
    private String userId;
    private String username;
    private String avatar;
    private List<PostDto> posts;
}

