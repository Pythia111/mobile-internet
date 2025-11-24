package com.example.nutrition.service;

import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Map;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class SmsCodeService {
    private static class CodeEntry {
        String code;
        Instant expireAt;
        int sendCount;
        Instant windowStart;
    }

    private final Map<String, CodeEntry> codes = new ConcurrentHashMap<>();
    private final Random random = new Random();

    private static final long EXPIRE_SECONDS = 5 * 60; // 5分钟
    private static final long WINDOW_SECONDS = 60; // 限流窗口60秒
    private static final int MAX_PER_WINDOW = 3; // 每窗口最多发送3次

    public String generateAndStore(String phone) {
        CodeEntry entry = codes.computeIfAbsent(phone, k -> new CodeEntry());
        Instant now = Instant.now();
        if (entry.windowStart == null || now.isAfter(entry.windowStart.plusSeconds(WINDOW_SECONDS))) {
            entry.windowStart = now;
            entry.sendCount = 0;
        }
        if (entry.sendCount >= MAX_PER_WINDOW) {
            throw new IllegalStateException("验证码发送频率过高，请稍后再试");
        }
        String code = String.format("%06d", random.nextInt(1_000_000));
        entry.code = code;
        entry.expireAt = now.plusSeconds(EXPIRE_SECONDS);
        entry.sendCount++;
        // 模拟发送：生产中应集成第三方短信服务
        System.out.println("[SmsCodeService] phone=" + phone + ", code=" + code);
        return code;
    }

    public boolean verify(String phone, String code) {
        CodeEntry entry = codes.get(phone);
        if (entry == null) return false;
        if (Instant.now().isAfter(entry.expireAt)) return false;
        return entry.code.equals(code);
    }

    public void clear(String phone) {
        codes.remove(phone);
    }
}
