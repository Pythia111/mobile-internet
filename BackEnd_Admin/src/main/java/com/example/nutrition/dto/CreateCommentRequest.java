package com.example.nutrition.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.validation.constraints.NotBlank;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateCommentRequest {

    @NotBlank(message = "评论内容不能为空")
    private String content;

    @NotBlank(message = "用户名不能为空")
    private String username;

    @NotBlank(message = "头像不能为空")
    private String avatar;
}

