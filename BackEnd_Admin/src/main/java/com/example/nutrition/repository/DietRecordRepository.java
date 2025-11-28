package com.example.nutrition.repository;

import com.example.nutrition.entity.DietRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

/**
 * 饮食记录数据访问接口
 */
@Repository
public interface DietRecordRepository extends JpaRepository<DietRecord, Long> {

    /**
     * 查询用户在指定日期的所有饮食记录
     */
    List<DietRecord> findByUserIdAndRecordDateOrderByCreatedAt(Long userId, LocalDate recordDate);

    /**
     * 查询用户的所有饮食记录
     */
    List<DietRecord> findByUserIdOrderByRecordDateDescCreatedAtDesc(Long userId);

    /**
     * 查询用户在日期范围内的饮食记录
     */
    @Query("SELECT d FROM DietRecord d WHERE d.userId = :userId AND d.recordDate BETWEEN :startDate AND :endDate ORDER BY d.recordDate DESC, d.createdAt DESC")
    List<DietRecord> findByUserIdAndDateRange(@Param("userId") Long userId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);

    /**
     * 删除用户的指定记录
     */
    void deleteByIdAndUserId(Long id, Long userId);

    /**
     * 检查记录是否属于用户
     */
    boolean existsByIdAndUserId(Long id, Long userId);
}
