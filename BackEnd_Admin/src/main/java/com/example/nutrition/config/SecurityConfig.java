package com.example.nutrition.config;

import com.example.nutrition.entity.Role;
import com.example.nutrition.entity.User;
import com.example.nutrition.repository.RoleRepository;
import com.example.nutrition.repository.UserRepository;
import com.example.nutrition.security.JwtAuthenticationFilter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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

    private static final Logger logger = LoggerFactory.getLogger(SecurityConfig.class);

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http, JwtAuthenticationFilter jwtFilter)
            throws Exception {
        http
                .csrf().disable()
                .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS).and()
                .authorizeRequests()
                // 公开接口 - 无需认证
                .antMatchers("/api/auth/**",
                        "/v3/api-docs/**",
                        "/swagger-ui/**",
                        "/swagger-ui.html",
                        "/actuator/health",
                        "/uploads/**")
                .permitAll()
                // 论坛公开接口 - GET 请求无需认证
                .antMatchers(HttpMethod.GET, "/api/forum/posts/**", "/api/forum/user/*/posts")
                .permitAll()
                // 管理员接口
                .antMatchers(HttpMethod.GET, "/actuator/**").hasRole("ADMIN")
                // 其他接口需要认证
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
                        .authorities(user.getRoles().stream().map(r -> "ROLE_" + r.getName().replace("ROLE_", ""))
                                .toArray(String[]::new))
                        .build())
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public AuthenticationProvider authenticationProvider(UserDetailsService userDetailsService,
            PasswordEncoder passwordEncoder) {
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
    public CommandLineRunner initDefaultData(RoleRepository roleRepository, UserRepository userRepository,
            PasswordEncoder encoder) {
        return args -> {
            logger.info("Starting to initialize default data...");

            try {
                // 初始化角色
                logger.info("Initializing roles...");
                Role roleUser = roleRepository.findByName("ROLE_USER")
                        .orElseGet(() -> {
                            logger.info("Creating ROLE_USER");
                            return roleRepository.save(Role.builder().name("ROLE_USER").build());
                        });
                Role roleAdmin = roleRepository.findByName("ROLE_ADMIN")
                        .orElseGet(() -> {
                            logger.info("Creating ROLE_ADMIN");
                            return roleRepository.save(Role.builder().name("ROLE_ADMIN").build());
                        });

                // 初始化一个管理员账号（仅用于开发环境）
                logger.info("Checking for admin user...");
                if (!userRepository.findByPhone("+8613800000000").isPresent()) {
                    logger.info("Creating admin user...");
                    User admin = User.builder()
                            .phone("+8613800000000")
                            .name("Admin")
                            .passwordHash(encoder.encode("Admin@123"))
                            .build();
                    admin = userRepository.save(admin);

                    // 设置角色关联
                    Set<Role> roles = new java.util.HashSet<>();
                    roles.add(roleUser);
                    roles.add(roleAdmin);
                    admin.setRoles(roles);
                    userRepository.save(admin);
                    logger.info("Admin user created successfully");
                } else {
                    logger.info("Admin user already exists");
                }

                logger.info("Default data initialization completed!");
            } catch (Exception e) {
                logger.error("Error initializing default data", e);
                throw e;
            }
        };
    }
}
