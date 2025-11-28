package com.example.nutrition.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

/**
 * 讯飞星火AI配置
 */
@Configuration
@ConfigurationProperties(prefix = "app.ai.xfyun")
@Data
public class XfyunAIConfig {

    /**
     * API密钥
     */
    private String apiKey;

    /**
     * API基础地址
     */
    private String apiBase;

    /**
     * 模型ID
     */
    private String modelId;

    /**
     * 是否启用AI功能
     */
    private boolean enabled = false;
}
