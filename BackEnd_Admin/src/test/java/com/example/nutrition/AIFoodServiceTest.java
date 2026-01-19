package com.example.nutrition;

import com.example.nutrition.dto.FoodInfoDto;
import com.example.nutrition.service.AIFoodService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.List;

/**
 * AI食物服务测试
 */
@SpringBootTest
public class AIFoodServiceTest {

    @Autowired
    private AIFoodService aiFoodService;

    @Test
    public void testSearchBeef() {
        System.out.println("\n========== 测试搜索：牛肉 ==========");
        System.out.println("AI配置状态: " + (aiFoodService != null ? "已注入" : "未注入"));

        try {
            List<FoodInfoDto> results = aiFoodService.searchFood("牛肉");

            System.out.println("搜索结果数量: " + results.size());
            System.out.println("\n详细信息:");

            for (int i = 0; i < results.size(); i++) {
                FoodInfoDto food = results.get(i);
                System.out.println("\n【食物 " + (i + 1) + "】");
                System.out.println("  名称: " + food.getFoodName());
                System.out.println("  热量: " + food.getCalories() + " kcal/100g");
                System.out.println("  蛋白质: " + food.getProtein() + " g/100g");
                System.out.println("  碳水化合物: " + food.getCarbohydrates() + " g/100g");
                System.out.println("  脂肪: " + food.getFat() + " g/100g");
            }
        } catch (Exception e) {
            System.err.println("测试失败: " + e.getMessage());
            e.printStackTrace();
        }

        System.out.println("\n========================================\n");
    }

    @Test
    public void testRecognizeFood() {
        System.out.println("\n========== 测试识别：红烧牛肉 ==========");

        FoodInfoDto result = aiFoodService.recognizeFood("红烧牛肉");

        System.out.println("识别结果:");
        System.out.println("  名称: " + result.getFoodName());
        System.out.println("  热量: " + result.getCalories() + " kcal/100g");
        System.out.println("  蛋白质: " + result.getProtein() + " g/100g");
        System.out.println("  碳水化合物: " + result.getCarbohydrates() + " g/100g");
        System.out.println("  脂肪: " + result.getFat() + " g/100g");

        System.out.println("\n========================================\n");
    }
}
