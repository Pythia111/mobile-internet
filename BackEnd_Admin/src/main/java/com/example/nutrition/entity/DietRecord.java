package com.example.nutrition.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 饮食记录实体类
 */
@Entity
@Table(name = "diet_records")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DietRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "food_name", nullable = false)
    private String foodName;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal calories;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal protein;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal carbohydrates;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal fat;

    @Column(name = "meal_type", nullable = false, length = 20)
    private String mealType; // breakfast, lunch, dinner, snack

    @Column(name = "record_date", nullable = false)
    private LocalDate recordDate;


    @Column(name = "weight", precision = 10, scale = 2)
    private BigDecimal weight;

    @Column(name = "image_url", length = 512)
    private String imageUrl;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
