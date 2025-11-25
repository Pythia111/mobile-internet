package com.example.nutrition.repository;

import com.example.nutrition.entity.PostLike;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PostLikeRepository extends JpaRepository<PostLike, Long> {

    // 检查用户是否点赞了某个帖子
    boolean existsByPostIdAndUserId(Long postId, Long userId);

    // 查找用户对某个帖子的点赞记录
    Optional<PostLike> findByPostIdAndUserId(Long postId, Long userId);

    // 统计帖子的点赞数
    long countByPostId(Long postId);
}

