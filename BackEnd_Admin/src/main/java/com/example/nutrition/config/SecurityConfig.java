package com.example.nutrition.config;

import com.example.nutrition.entity.Role;
import com.example.nutrition.entity.User;
import com.example.nutrition.repository.RoleRepository;
import com.example.nutrition.repository.UserRepository;
import com.example.nutrition.security.JwtAuthenticationFilter;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import java.util.Set;

@Configuration
@EnableGlobalMethodSecurity(prePostEnabled = true)
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http, JwtAuthenticationFilter jwtFilter) throws Exception {
    http
        .csrf().disable()
        .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS).and()
        .authorizeRequests()
            .antMatchers("/api/auth/**", 
                 "/v3/api-docs/**", 
                 "/swagger-ui/**", 
                 "/swagger-ui.html", 
                 "/actuator/health").permitAll()
            .antMatchers(HttpMethod.GET, "/actuator/**").hasRole("ADMIN")
            .anyRequest().authenticated()
        .and()
        .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);
    return http.build();
    }

    @Bean
    public UserDetailsService userDetailsService(UserRepository userRepository) {
        return username -> userRepository.findByPhone(username)
                .map(user -> org.springframework.security.core.userdetails.User
                        .withUsername(user.getPhone())
                        .password(user.getPasswordHash() == null ? "" : user.getPasswordHash())
                        .authorities(user.getRoles().stream().map(r -> "ROLE_" + r.getName().replace("ROLE_", "")).toArray(String[]::new))
                        .build())
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public AuthenticationProvider authenticationProvider(UserDetailsService userDetailsService, PasswordEncoder passwordEncoder) {
        DaoAuthenticationProvider provider = new DaoAuthenticationProvider();
        provider.setUserDetailsService(userDetailsService);
        provider.setPasswordEncoder(passwordEncoder);
        return provider;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    @Bean
    public CommandLineRunner initDefaultData(RoleRepository roleRepository, UserRepository userRepository, PasswordEncoder encoder) {
        return args -> {
            Role roleUser = roleRepository.findByName("ROLE_USER").orElseGet(() -> roleRepository.save(Role.builder().name("ROLE_USER").build()));
            Role roleAdmin = roleRepository.findByName("ROLE_ADMIN").orElseGet(() -> roleRepository.save(Role.builder().name("ROLE_ADMIN").build()));

            // 初始化一个管理员账号（仅用于开发环境）
            userRepository.findByPhone("+8613800000000").orElseGet(() -> {
                User admin = User.builder()
                        .phone("+8613800000000")
                        .name("Admin")
                        .passwordHash(encoder.encode("Admin@123"))
                        .roles(new java.util.HashSet<>(java.util.Arrays.asList(roleUser, roleAdmin)))
                        .build();
                return userRepository.save(admin);
            });
        };
    }
}
