package com.example.nutrition.service;

import com.example.nutrition.entity.SystemConfig;
import com.example.nutrition.entity.User;
import com.example.nutrition.repository.SystemConfigRepository;
import com.example.nutrition.repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.Instant;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class SystemService {
    private final SystemConfigRepository configRepository;
    private final UserRepository userRepository;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public SystemService(SystemConfigRepository configRepository, UserRepository userRepository) {
        this.configRepository = configRepository;
        this.userRepository = userRepository;
    }

    public Path exportBackup() throws IOException {
        Map<String, Object> payload = new HashMap<>();
        payload.put("exportedAt", Instant.now().toString());
        payload.put("users", userRepository.findAll());
        payload.put("systemConfigs", configRepository.findAll());

        Path dir = Paths.get("backups");
        if (!Files.exists(dir)) {
            Files.createDirectories(dir);
        }
        String filename = "backup-" + System.currentTimeMillis() + ".json";
        Path file = dir.resolve(filename);
        byte[] bytes = objectMapper.writerWithDefaultPrettyPrinter().writeValueAsBytes(payload);
        Files.write(file, bytes);
        return file;
    }

    @SuppressWarnings("unchecked")
    public void importBackup(Path file) throws IOException {
        String json = new String(Files.readAllBytes(file), StandardCharsets.UTF_8);
        Map<String, Object> payload = objectMapper.readValue(json, Map.class);
        // 注意：以下导入逻辑是示例，生产环境需更严谨的数据校验与去重策略
        List<Map<String, Object>> users = (List<Map<String, Object>>) (payload.containsKey("users") ? payload.get("users") : java.util.Collections.emptyList());
        for (Map<String, Object> u : users) {
            String phone = String.valueOf(u.get("phone"));
            java.util.Optional<com.example.nutrition.entity.User> maybe = userRepository.findByPhone(phone);
            if (!maybe.isPresent()) {
                User user = new User();
                user.setPhone(phone);
                user.setName((String) u.get("name"));
                user.setPasswordHash((String) u.get("passwordHash"));
                userRepository.save(user);
            }
        }
        List<Map<String, Object>> configs = (List<Map<String, Object>>) (payload.containsKey("systemConfigs") ? payload.get("systemConfigs") : java.util.Collections.emptyList());
        for (Map<String, Object> c : configs) {
            String key = String.valueOf(c.get("key"));
            String value = c.get("value") == null ? null : String.valueOf(c.get("value"));
            String description = c.get("description") == null ? null : String.valueOf(c.get("description"));
            java.util.Optional<SystemConfig> cfg = configRepository.findByKey(key);
            if (cfg.isPresent()) {
                SystemConfig existing = cfg.get();
                existing.setValue(value);
                existing.setDescription(description);
                configRepository.save(existing);
            } else {
                SystemConfig sc = SystemConfig.builder().key(key).value(value).description(description).build();
                configRepository.save(sc);
            }
        }
    }
}
