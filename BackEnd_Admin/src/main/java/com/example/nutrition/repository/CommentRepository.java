package com.example.nutrition.repository;

import com.example.nutrition.entity.Comment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CommentRepository extends JpaRepository<Comment, Long> {

    // 根据帖子ID查询评论
    List<Comment> findByPostIdOrderByCreatedAtAsc(Long postId);

    // 根据用户ID查询评论
    List<Comment> findByUserIdOrderByCreatedAtDesc(Long userId);
}

