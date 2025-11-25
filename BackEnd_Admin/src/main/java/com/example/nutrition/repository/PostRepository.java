package com.example.nutrition.repository;

import com.example.nutrition.entity.Post;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PostRepository extends JpaRepository<Post, Long> {

    // 根据状态分页查询帖子
    Page<Post> findByStatusOrderByCreatedAtDesc(Integer status, Pageable pageable);

    // 查询所有非删除状态的帖子
    Page<Post> findByStatusNotOrderByCreatedAtDesc(Integer status, Pageable pageable);

    // 根据用户ID查询帖子
    List<Post> findByUserIdOrderByCreatedAtDesc(Long userId);

    // 根据用户ID和状态查询帖子
    List<Post> findByUserIdAndStatusOrderByCreatedAtDesc(Long userId, Integer status);

    // 查询帖子（包含状态判断）
    @Query("SELECT p FROM Post p WHERE p.id = :postId AND p.status != 3")
    Optional<Post> findActivePostById(Long postId);
}

