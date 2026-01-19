package com.example.nutrition.service;

import com.example.nutrition.config.XfyunAIConfig;
import com.example.nutrition.dto.FoodInfoDto;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonArray;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import okhttp3.*;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

/**
 * AI食物识别和搜索服务
 * 集成讯飞星火大模型API
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class AIFoodService {

    private final XfyunAIConfig xfyunConfig;
    private final Gson gson = new Gson();

    // OkHttp客户端，确保UTF-8编码
    private final OkHttpClient httpClient = new OkHttpClient.Builder()
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(60, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
            .build();

    // 模拟食物数据库（当AI功能未启用时使用）
    private static final List<FoodInfoDto> FOOD_DATABASE = Arrays.asList(
            new FoodInfoDto("米饭", new BigDecimal("116"), new BigDecimal("2.6"), new BigDecimal("25.6"),
                    new BigDecimal("0.3")),
            new FoodInfoDto("鸡蛋", new BigDecimal("147"), new BigDecimal("12.8"), new BigDecimal("1.3"),
                    new BigDecimal("10.6")),
            new FoodInfoDto("鸡胸肉", new BigDecimal("133"), new BigDecimal("24.6"), new BigDecimal("2.5"),
                    new BigDecimal("3.6")),
            new FoodInfoDto("西兰花", new BigDecimal("34"), new BigDecimal("2.8"), new BigDecimal("6.6"),
                    new BigDecimal("0.4")),
            new FoodInfoDto("苹果", new BigDecimal("52"), new BigDecimal("0.3"), new BigDecimal("13.8"),
                    new BigDecimal("0.2")),
            new FoodInfoDto("香蕉", new BigDecimal("89"), new BigDecimal("1.1"), new BigDecimal("22.8"),
                    new BigDecimal("0.3")),
            new FoodInfoDto("牛奶", new BigDecimal("54"), new BigDecimal("3.0"), new BigDecimal("5.0"),
                    new BigDecimal("3.2")),
            new FoodInfoDto("全麦面包", new BigDecimal("246"), new BigDecimal("13.2"), new BigDecimal("41.0"),
                    new BigDecimal("3.5")),
            new FoodInfoDto("燕麦", new BigDecimal("367"), new BigDecimal("12.5"), new BigDecimal("61.0"),
                    new BigDecimal("7.2")),
            new FoodInfoDto("三文鱼", new BigDecimal("208"), new BigDecimal("20.0"), new BigDecimal("0.0"),
                    new BigDecimal("13.4")),
            new FoodInfoDto("牛肉", new BigDecimal("250"), new BigDecimal("26.0"), new BigDecimal("0.0"),
                    new BigDecimal("15.0")),
            new FoodInfoDto("番茄", new BigDecimal("18"), new BigDecimal("0.9"), new BigDecimal("3.9"),
                    new BigDecimal("0.2")),
            new FoodInfoDto("黄瓜", new BigDecimal("16"), new BigDecimal("0.7"), new BigDecimal("3.6"),
                    new BigDecimal("0.1")),
            new FoodInfoDto("土豆", new BigDecimal("77"), new BigDecimal("2.0"), new BigDecimal("17.5"),
                    new BigDecimal("0.1")),
            new FoodInfoDto("红薯", new BigDecimal("86"), new BigDecimal("1.6"), new BigDecimal("20.1"),
                    new BigDecimal("0.1")),
            new FoodInfoDto("豆腐", new BigDecimal("76"), new BigDecimal("8.1"), new BigDecimal("4.2"),
                    new BigDecimal("3.7")),
            new FoodInfoDto("花生", new BigDecimal("567"), new BigDecimal("24.8"), new BigDecimal("21.7"),
                    new BigDecimal("44.3")),
            new FoodInfoDto("核桃", new BigDecimal("654"), new BigDecimal("15.2"), new BigDecimal("13.7"),
                    new BigDecimal("65.2")),
            new FoodInfoDto("酸奶", new BigDecimal("72"), new BigDecimal("3.5"), new BigDecimal("9.3"),
                    new BigDecimal("2.7")),
            new FoodInfoDto("胡萝卜", new BigDecimal("41"), new BigDecimal("0.9"), new BigDecimal("9.6"),
                    new BigDecimal("0.2")));

    /**
     * AI识别食物
     * 根据配置选择使用真实AI或模拟数据
     */
    public FoodInfoDto recognizeFood(String foodDescription) {
        if (xfyunConfig.isEnabled()) {
            log.info("使用讯飞星火AI识别食物: {}", foodDescription);
            return recognizeFoodByAI(foodDescription);
        } else {
            log.info("AI功能未启用，返回模拟数据");
            return FOOD_DATABASE.get((int) (Math.random() * FOOD_DATABASE.size()));
        }
    }

    /**
     * 搜索食物
     * 根据配置选择使用真实AI或模拟数据
     */
    public List<FoodInfoDto> searchFood(String keyword) {
        if (xfyunConfig.isEnabled()) {
            log.info("使用讯飞星火AI搜索食物: {}", keyword);
            return searchFoodByAI(keyword);
        } else {
            log.info("AI功能未启用，使用本地数据库搜索: {}", keyword);
            return searchFoodLocal(keyword);
        }
    }

    /**
     * 使用讯飞星火AI识别食物（真实实现）
     */
    private FoodInfoDto recognizeFoodByAI(String foodDescription) {
        String prompt = String.format(
                "请根据食物描述'%s'，返回JSON格式的营养信息，格式如下：\n" +
                        "{\"foodName\":\"食物名称\",\"calories\":热量值(kcal),\"protein\":蛋白质(g)," +
                        "\"carbohydrates\":碳水化合物(g),\"fat\":脂肪(g)}\n" +
                        "注意：所有营养成分都是每100克的含量。请根据描述识别最可能的食物。",
                foodDescription);

        try {
            // 构建请求JSON
            JsonObject requestJson = new JsonObject();
            requestJson.addProperty("model", xfyunConfig.getModelId());
            requestJson.addProperty("temperature", 0.7);
            requestJson.addProperty("max_tokens", 1024);

            // 构建messages
            JsonArray messages = new JsonArray();
            JsonObject userMessage = new JsonObject();
            userMessage.addProperty("role", "user");
            userMessage.addProperty("content", prompt);
            messages.add(userMessage);
            requestJson.add("messages", messages);

            // 设置JSON模式
            JsonObject responseFormat = new JsonObject();
            responseFormat.addProperty("type", "json_object");
            requestJson.add("response_format", responseFormat);

            JsonObject extraBody = new JsonObject();
            extraBody.addProperty("search_disable", true);
            requestJson.add("extra_body", extraBody);

            // 调用API
            String responseText = callXfyunAPI(requestJson.toString());

            // 解析响应
            return parseFoodInfoFromResponse(responseText);

        } catch (Exception e) {
            log.error("AI识别食物失败: {}", e.getMessage(), e);
            // 降级：返回模拟数据
            return FOOD_DATABASE.get(0);
        }
    }

    /**
     * 使用讯飞星火AI搜索食物（真实实现）
     */
    private List<FoodInfoDto> searchFoodByAI(String keyword) {
        String prompt = String.format(
                "请提供关于'%s'的营养信息，返回JSON数组格式，每个元素包含：\n" +
                        "{\"foodName\":\"食物名称\",\"calories\":热量值(kcal),\"protein\":蛋白质(g)," +
                        "\"carbohydrates\":碳水化合物(g),\"fat\":脂肪(g)}\n" +
                        "注意：所有营养成分都是每100克的含量。如果'%s'可以指代多种食物，请返回最多5种常见的。",
                keyword, keyword);

        try {
            // 构建请求JSON
            JsonObject requestJson = new JsonObject();
            requestJson.addProperty("model", xfyunConfig.getModelId());
            requestJson.addProperty("temperature", 0.7);
            requestJson.addProperty("max_tokens", 2048);

            JsonArray messages = new JsonArray();
            JsonObject userMessage = new JsonObject();
            userMessage.addProperty("role", "user");
            userMessage.addProperty("content", prompt);
            messages.add(userMessage);
            requestJson.add("messages", messages);

            JsonObject responseFormat = new JsonObject();
            responseFormat.addProperty("type", "json_object");
            requestJson.add("response_format", responseFormat);

            JsonObject extraBody = new JsonObject();
            extraBody.addProperty("search_disable", true);
            requestJson.add("extra_body", extraBody);

            // 调用API
            String responseText = callXfyunAPI(requestJson.toString());
            log.info("[搜索食物] API调用成功，开始解析响应");

            // 解析响应
            List<FoodInfoDto> result = parseFoodListFromResponse(responseText);
            log.info("[搜索食物] 解析完成，返回{}条结果", result.size());
            return result;

        } catch (Exception e) {
            log.error("AI搜索食物失败: {}", e.getMessage(), e);
            // 降级：使用本地搜索
            return searchFoodLocal(keyword);
        }
    }

    /**
     * 调用讯飞星火API
     */
    private String callXfyunAPI(String requestBody) throws IOException {
        // 确保UTF-8编码
        MediaType mediaType = MediaType.parse("application/json; charset=utf-8");
        RequestBody body = RequestBody.create(requestBody.getBytes(java.nio.charset.StandardCharsets.UTF_8), mediaType);

        Request request = new Request.Builder()
                .url(xfyunConfig.getApiBase() + "/chat/completions")
                .addHeader("Authorization", "Bearer " + xfyunConfig.getApiKey())
                .addHeader("Content-Type", "application/json; charset=utf-8")
                .addHeader("Accept", "application/json; charset=utf-8")
                .post(body)
                .build();

        try (Response response = httpClient.newCall(request).execute()) {
            if (!response.isSuccessful()) {
                String errorBody = response.body() != null
                        ? new String(response.body().bytes(), java.nio.charset.StandardCharsets.UTF_8)
                        : "";
                log.error("API调用失败: HTTP {}, body: {}", response.code(), errorBody);
                throw new IOException("API调用失败: " + response.code());
            }

            String responseBody = new String(response.body().bytes(), java.nio.charset.StandardCharsets.UTF_8);
            log.debug("API响应: {}", responseBody);
            return responseBody;
        }
    }

    /**
     * 从API响应中解析单个食物信息
     */
    private FoodInfoDto parseFoodInfoFromResponse(String responseText) {
        try {
            log.debug("解析AI响应: {}", responseText);
            JsonObject responseJson = gson.fromJson(responseText, JsonObject.class);
            JsonArray choices = responseJson.getAsJsonArray("choices");
            if (choices != null && choices.size() > 0) {
                JsonObject firstChoice = choices.get(0).getAsJsonObject();
                JsonObject message = firstChoice.getAsJsonObject("message");
                String content = message.get("content").getAsString();

                log.info("AI返回的content: {}", content);

                // 解析content中的JSON
                JsonObject foodJson = gson.fromJson(content, JsonObject.class);

                // 尝试从不同的字段名获取值
                String foodName = getFoodName(foodJson);
                BigDecimal calories = getNumericValue(foodJson, "calories");
                BigDecimal protein = getNumericValue(foodJson, "protein");
                BigDecimal carbohydrates = getNumericValue(foodJson, "carbohydrates");
                BigDecimal fat = getNumericValue(foodJson, "fat");

                log.info("AI识别成功: {} - 热量:{}, 蛋白质:{}", foodName, calories, protein);

                return new FoodInfoDto(foodName, calories, protein, carbohydrates, fat);
            }
        } catch (Exception e) {
            log.error("解析AI响应失败: {}, 响应内容: {}", e.getMessage(), responseText);
        }

        // 解析失败时返回默认值
        log.warn("解析AI响应失败，返回默认食物数据");
        return new FoodInfoDto("未知食物", BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO);
    }

    private String getFoodName(JsonObject json) {
        if (json.has("foodName"))
            return json.get("foodName").getAsString();
        if (json.has("name"))
            return json.get("name").getAsString();
        if (json.has("food"))
            return json.get("food").getAsString();
        return "未知食物";
    }

    private BigDecimal getNumericValue(JsonObject json, String key) {
        try {
            if (json.has(key)) {
                String value = json.get(key).getAsString();
                return new BigDecimal(value);
            }
        } catch (Exception e) {
            log.debug("无法解析数值字段 {}: {}", key, e.getMessage());
        }
        return BigDecimal.ZERO;
    }

    /**
     * 从API响应中解析食物列表
     */
    private List<FoodInfoDto> parseFoodListFromResponse(String responseText) {
        try {
            log.debug("[解析食物列表] 完整响应: {}", responseText);
            JsonObject responseJson = gson.fromJson(responseText, JsonObject.class);
            JsonArray choices = responseJson.getAsJsonArray("choices");
            if (choices != null && choices.size() > 0) {
                JsonObject firstChoice = choices.get(0).getAsJsonObject();
                JsonObject message = firstChoice.getAsJsonObject("message");
                String content = message.get("content").getAsString();

                log.info("[解析食物列表] AI返回的content: {}", content);

                // 尝试解析为数组或单个对象
                try {
                    log.debug("[解析食物列表] 尝试解析为JSON数组");
                    JsonArray foodArray = gson.fromJson(content, JsonArray.class);
                    log.info("[解析食物列表] 成功解析为数组，包含{}个元素", foodArray.size());
                    return parseFoodArray(foodArray);
                } catch (Exception e) {
                    log.debug("[解析食物列表] 不是数组格式，尝试解析为对象: {}", e.getMessage());
                    // 可能返回的是包含数组的对象
                    try {
                        JsonObject contentObj = gson.fromJson(content, JsonObject.class);
                        log.debug("[解析食物列表] 成功解析为对象，字段: {}", contentObj.keySet());

                        if (contentObj.has("data")) {
                            JsonArray foodArray = contentObj.getAsJsonArray("data");
                            log.info("[解析食物列表] 从'data'字段获取到{}个元素", foodArray.size());
                            return parseFoodArray(foodArray);
                        } else if (contentObj.has("foods")) {
                            JsonArray foodArray = contentObj.getAsJsonArray("foods");
                            log.info("[解析食物列表] 从'foods'字段获取到{}个元素", foodArray.size());
                            return parseFoodArray(foodArray);
                        } else if (contentObj.has("results")) {
                            JsonArray foodArray = contentObj.getAsJsonArray("results");
                            log.info("[解析食物列表] 从'results'字段获取到{}个元素", foodArray.size());
                            return parseFoodArray(foodArray);
                        } else {
                            log.warn("[解析食物列表] 对象中未找到'data'/'foods'/'results'字段，实际字段: {}", contentObj.keySet());
                        }
                    } catch (Exception e2) {
                        log.error("[解析食物列表] 解析为对象也失败: {}", e2.getMessage());
                    }
                }
            } else {
                log.warn("[解析食物列表] 响应中没有choices或choices为空");
            }
        } catch (Exception e) {
            log.error("[解析食物列表] 解析AI响应失败: {}", e.getMessage(), e);
        }

        // 解析失败时返回本地数据的前3条
        log.warn("[解析食物列表] 所有解析尝试失败，返回本地模拟数据");
        return FOOD_DATABASE.subList(0, Math.min(3, FOOD_DATABASE.size()));
    }

    /**
     * 解析食物JSON数组
     */
    private List<FoodInfoDto> parseFoodArray(JsonArray foodArray) {
        List<FoodInfoDto> result = new java.util.ArrayList<>();
        for (int i = 0; i < foodArray.size(); i++) {
            try {
                JsonObject foodJson = foodArray.get(i).getAsJsonObject();
                FoodInfoDto food = new FoodInfoDto(
                        foodJson.get("foodName").getAsString(),
                        new BigDecimal(foodJson.get("calories").getAsString()),
                        new BigDecimal(foodJson.get("protein").getAsString()),
                        new BigDecimal(foodJson.get("carbohydrates").getAsString()),
                        new BigDecimal(foodJson.get("fat").getAsString()));
                result.add(food);
            } catch (Exception e) {
                log.warn("解析第{}个食物信息失败: {}", i, e.getMessage());
            }
        }
        return result;
    }

    /**
     * 本地搜索食物（降级方案）
     */
    private List<FoodInfoDto> searchFoodLocal(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return FOOD_DATABASE;
        }

        String lowercaseKeyword = keyword.toLowerCase();
        return FOOD_DATABASE.stream()
                .filter(food -> food.getFoodName().toLowerCase().contains(lowercaseKeyword))
                .collect(Collectors.toList());
    }
}
