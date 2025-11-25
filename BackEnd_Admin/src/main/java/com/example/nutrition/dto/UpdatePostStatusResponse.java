package com.example.nutrition.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdatePostStatusResponse {
    private String postId;
    private Integer newStatus;
    private Integer oldStatus;
    private OperatorInfo operator;
    private Instant updatedAt;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class OperatorInfo {
        private String id;
        private String role;
    }
}

