package com.example.nutrition.service;

import com.example.nutrition.dto.LoginRequest;
import com.example.nutrition.dto.RegisterRequest;
import com.example.nutrition.dto.UpdateProfileRequest;
import com.example.nutrition.dto.UserProfileDto;
import com.example.nutrition.entity.Role;
import com.example.nutrition.entity.User;
import com.example.nutrition.repository.RoleRepository;
import com.example.nutrition.repository.UserRepository;
import com.example.nutrition.security.JwtService;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

@Service
public class UserService implements UserDetailsService {
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public UserService(UserRepository userRepository, RoleRepository roleRepository, PasswordEncoder passwordEncoder,
            JwtService jwtService) {
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        return userRepository.findByPhone(username)
                .map(user -> org.springframework.security.core.userdetails.User
                        .withUsername(user.getPhone())
                        .password(user.getPasswordHash() == null ? "" : user.getPasswordHash())
                        .authorities(user.getRoles().stream().map(r -> "ROLE_" + r.getName().replace("ROLE_", ""))
                                .toArray(String[]::new))
                        .build())
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));
    }

    @Transactional
    public Map<String, Object> register(RegisterRequest request) {
        if (userRepository.findByPhone(request.getPhone()).isPresent()) {
            throw new IllegalArgumentException("Phone already registered");
        }

        Role roleUser = roleRepository.findByName("ROLE_USER")
                .orElseGet(() -> roleRepository.save(Role.builder().name("ROLE_USER").build()));

        Role roleAdmin = roleRepository.findByName("ROLE_ADMIN")
                .orElseGet(() -> roleRepository.save(Role.builder().name("ROLE_ADMIN").build()));

        // Web端用户默认都是管理员
        Set<Role> roles = new HashSet<>();
        roles.add(roleUser);
        roles.add(roleAdmin);

        User user = User.builder()
                .phone(request.getPhone())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .name(request.getUsername())
                .roles(roles)
                .build();

        user = userRepository.save(user);

        UserDetails userDetails = loadUserByUsername(user.getPhone());
        String token = jwtService.generateToken(userDetails);

        Map<String, Object> data = new HashMap<>();
        data.put("userId", user.getId());
        data.put("token", token);
        return data;
    }

    public Map<String, Object> login(LoginRequest request) {
        User user = userRepository.findByPhone(request.getPhone())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new IllegalArgumentException("Invalid password");
        }

        UserDetails userDetails = loadUserByUsername(user.getPhone());
        String token = jwtService.generateToken(userDetails);

        Map<String, Object> data = new HashMap<>();
        data.put("userId", user.getId());
        data.put("token", token);
        data.put("role", user.getRoles().stream().findFirst().map(Role::getName).orElse("ROLE_USER"));

        return data;
    }

    public UserProfileDto getProfile(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        return UserProfileDto.builder()
                .userId(user.getId())
                .phone(user.getPhone())
                .username(user.getName())
                .avatar(user.getAvatarUrl())
                .role(user.getRoles().stream().findFirst().map(Role::getName).orElse("ROLE_USER"))
                .build();
    }

    @Transactional
    public void updateProfile(Long userId, UpdateProfileRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        if (request.getUsername() != null) {
            user.setName(request.getUsername());
        }
        if (request.getPassword() != null) {
            user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        }
        if (request.getAvatar() != null) {
            user.setAvatarUrl(request.getAvatar());
        }
        userRepository.save(user);
    }

    @Transactional
    public User registerIfNotExists(String phone, String name) {
        return userRepository.findByPhone(phone).orElseGet(() -> {
            Role roleUser = roleRepository.findByName("ROLE_USER")
                    .orElseGet(() -> roleRepository.save(Role.builder().name("ROLE_USER").build()));
            User user = User.builder()
                    .phone(phone)
                    .name(name)
                    .roles(Collections.singleton(roleUser))
                    .build();
            return userRepository.save(user);
        });
    }

    @Transactional
    public void changePassword(User user, String oldPassword, String newPassword) {
        String hash = user.getPasswordHash();
        if (hash == null || hash.isEmpty()) {
            // 没有设置过密码时，允许直接设置新密码
            user.setPasswordHash(passwordEncoder.encode(newPassword));
            userRepository.save(user);
            return;
        }
        if (!passwordEncoder.matches(oldPassword, hash)) {
            throw new IllegalArgumentException("原密码不正确");
        }
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        userRepository.save(user);
    }
}
