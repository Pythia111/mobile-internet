package com.example.nutrition.service;

import com.example.nutrition.dto.UserStatsDto;
import com.example.nutrition.entity.User;
import com.example.nutrition.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class UserStatsService {
    private final UserRepository userRepository;

    public UserStatsService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public UserStatsDto buildStats(int days) {
        List<User> all = userRepository.findAll();
        UserStatsDto dto = new UserStatsDto();
        dto.setTotalUsers(all.size());
        dto.setAdminUsers(all.stream().filter(u -> u.getRoles().stream().anyMatch(r -> "ROLE_ADMIN".equals(r.getName()))).count());
        dto.setUsersWithPassword(all.stream().filter(u -> u.getPasswordHash() != null && !u.getPasswordHash().isEmpty()).count());

        LocalDate today = LocalDate.now();
        Map<String, Long> daily = new LinkedHashMap<>();
        for (int i = days - 1; i >= 0; i--) {
            LocalDate d = today.minusDays(i);
            String key = d.toString();
            long count = all.stream()
                    .filter(u -> u.getCreatedAt() != null && toDate(u.getCreatedAt()).equals(d))
                    .count();
            daily.put(key, count);
        }
        dto.setDailyRegistrations(daily);
        return dto;
    }

    private LocalDate toDate(Instant instant) {
        return instant.atZone(ZoneId.systemDefault()).toLocalDate();
    }
}
