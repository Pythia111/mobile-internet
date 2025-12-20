package com.example.nutrition.config;

import com.example.nutrition.entity.Role;
import com.example.nutrition.entity.User;
import com.example.nutrition.repository.RoleRepository;
import com.example.nutrition.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

@Configuration
public class DataInitializer {

    @Bean
    public CommandLineRunner initData(
            UserRepository userRepository,
            RoleRepository roleRepository,
            PasswordEncoder passwordEncoder) {
        return args -> {
            // Create roles if they don't exist
            Role roleUser = roleRepository.findByName("ROLE_USER")
                    .orElseGet(() -> roleRepository.save(Role.builder().name("ROLE_USER").build()));

            Role roleAdmin = roleRepository.findByName("ROLE_ADMIN")
                    .orElseGet(() -> roleRepository.save(Role.builder().name("ROLE_ADMIN").build()));

            // Create default test user if doesn't exist
            if (!userRepository.findByPhone("13800138000").isPresent()) {
                User testUser = User.builder()
                        .phone("13800138000")
                        .passwordHash(passwordEncoder.encode("user123"))
                        .name("测试用户")
                        .roles(Collections.singleton(roleUser))
                        .build();
                userRepository.save(testUser);
                System.out.println("✓ Created test user: 13800138000 / user123");
            }

            // Create default admin user if doesn't exist
            if (!userRepository.findByPhone("13900139000").isPresent()) {
                Set<Role> adminRoles = new HashSet<>();
                adminRoles.add(roleUser);
                adminRoles.add(roleAdmin);

                User adminUser = User.builder()
                        .phone("13900139000")
                        .passwordHash(passwordEncoder.encode("admin123"))
                        .name("管理员")
                        .roles(adminRoles)
                        .build();
                userRepository.save(adminUser);
                System.out.println("✓ Created admin user: 13900139000 / admin123");
            }

            System.out.println("Database initialization complete!");
        };
    }
}
