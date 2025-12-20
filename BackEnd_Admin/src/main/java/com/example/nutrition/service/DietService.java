package com.example.nutrition.service;

import com.example.nutrition.dto.*;
import com.example.nutrition.entity.DietRecord;
import com.example.nutrition.repository.DietRecordRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 饮食记录服务类
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class DietService {

    private final DietRecordRepository dietRecordRepository;
    private final AIFoodService aiFoodService;

    /**
     * 添加饮食记录
     */
    @Transactional
    public AddDietRecordResponse addDietRecord(Long userId, AddDietRecordRequest request) {
        DietRecord record = new DietRecord();
        record.setUserId(userId);
        record.setFoodName(request.getFoodName());
        record.setCalories(request.getCalories());
        record.setProtein(request.getProtein());
        record.setCarbohydrates(request.getCarbohydrates());
        record.setFat(request.getFat());
        record.setMealType(request.getMealType());
        record.setRecordDate(LocalDate.parse(request.getDate()));
        record.setImageUrl(request.getImage());

        DietRecord saved = dietRecordRepository.save(record);
        log.info("用户 {} 添加饮食记录: {}", userId, saved.getId());

        return new AddDietRecordResponse(String.valueOf(saved.getId()));
    }

    /**
     * AI识别食物
     */
    public FoodInfoDto recognizeFood(String foodDescription) {
        log.info("开始AI食物识别: {}", foodDescription);
        return aiFoodService.recognizeFood(foodDescription);
    }

    /**
     * 搜索食物
     */
    public List<FoodInfoDto> searchFood(String keyword) {
        log.info("搜索食物: {}", keyword);
        return aiFoodService.searchFood(keyword);
    }

    /**
     * 获取用户饮食历史
     */
    public DietHistoryResponse getDietHistory(Long userId) {
        // 获取所有记录
        List<DietRecord> records = dietRecordRepository.findByUserIdOrderByRecordDateDescCreatedAtDesc(userId);

        if (records.isEmpty()) {
            return new DietHistoryResponse(LocalDate.now().toString(), Collections.emptyList());
        }

        // 按日期分组
        Map<LocalDate, List<DietRecord>> recordsByDate = records.stream()
                .collect(Collectors.groupingBy(DietRecord::getRecordDate));

        // 获取最新日期
        LocalDate latestDate = recordsByDate.keySet().stream()
                .max(LocalDate::compareTo)
                .orElse(LocalDate.now());

        // 获取最新日期的记录
        List<DietRecord> latestRecords = recordsByDate.get(latestDate);

        // 按餐别分组
        Map<String, List<DietRecord>> recordsByMeal = latestRecords.stream()
                .collect(Collectors.groupingBy(DietRecord::getMealType));

        // 构造响应
        List<MealDto> meals = new ArrayList<>();
        for (String mealType : Arrays.asList("breakfast", "lunch", "dinner", "snack")) {
            List<DietRecord> mealRecords = recordsByMeal.getOrDefault(mealType, Collections.emptyList());
            if (!mealRecords.isEmpty()) {
            List<DietRecordDetailDto> foods = mealRecords.stream()
                .map(r -> new DietRecordDetailDto(
                    String.valueOf(r.getId()),
                    r.getFoodName(),
                    r.getCalories(),
                    r.getProtein(),
                    r.getCarbohydrates(),
                    r.getFat(),
                    r.getWeight(),
                    r.getImageUrl()))
                .collect(Collectors.toList());
            meals.add(new MealDto(mealType, foods));
            }
        }

        return new DietHistoryResponse(latestDate.toString(), meals);
    }

    /**
     * 删除饮食记录
     */
    @Transactional
    public void deleteDietRecord(Long userId, Long recordId) {
        // 检查记录是否存在且属于该用户
        if (!dietRecordRepository.existsByIdAndUserId(recordId, userId)) {
            throw new IllegalArgumentException("记录不存在或无权删除");
        }

        dietRecordRepository.deleteByIdAndUserId(recordId, userId);
        log.info("用户 {} 删除饮食记录: {}", userId, recordId);
    }
}
