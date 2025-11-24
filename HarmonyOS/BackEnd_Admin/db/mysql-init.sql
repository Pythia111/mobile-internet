-- MySQL initialization for nutrition backend (Member A scope)
-- Charset: utf8mb4, Engine: InnoDB

-- 1) Create database and switch
CREATE DATABASE IF NOT EXISTS `nutrition`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE `nutrition`;

-- 2) Tables

-- roles: system roles
CREATE TABLE IF NOT EXISTS `roles` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(64) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_roles_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- users: application users
CREATE TABLE IF NOT EXISTS `users` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `phone` VARCHAR(20) NOT NULL,
  `password_hash` VARCHAR(255) NULL,
  `name` VARCHAR(64) NULL,
  `email` VARCHAR(128) NULL,
  `avatar_url` VARCHAR(256) NULL,
  `created_at` DATETIME(6) NULL,
  `updated_at` DATETIME(6) NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_users_phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- user_roles: many-to-many join between users and roles
CREATE TABLE IF NOT EXISTS `user_roles` (
  `user_id` BIGINT NOT NULL,
  `role_id` BIGINT NOT NULL,
  PRIMARY KEY (`user_id`, `role_id`),
  KEY `idx_ur_user` (`user_id`),
  KEY `idx_ur_role` (`role_id`),
  CONSTRAINT `fk_ur_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ur_role` FOREIGN KEY (`role_id`) REFERENCES `roles`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- system_configs: key-value system configuration
CREATE TABLE IF NOT EXISTS `system_configs` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `config_key` VARCHAR(128) NOT NULL,
  `config_value` TEXT NULL,
  `description` VARCHAR(256) NULL,
  `updated_at` DATETIME(6) NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_syscfg_key` (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3) Seed data (idempotent)

-- roles
INSERT IGNORE INTO `roles` (`name`) VALUES ('ROLE_USER');
INSERT IGNORE INTO `roles` (`name`) VALUES ('ROLE_ADMIN');

-- admin user (phone only; password can be set later via API)
INSERT INTO `users` (`phone`, `name`)
SELECT '+8613800000000', 'Admin'
WHERE NOT EXISTS (SELECT 1 FROM `users` WHERE `phone` = '+8613800000000');

-- bind admin roles
INSERT IGNORE INTO `user_roles` (`user_id`, `role_id`)
SELECT u.id, r.id
FROM `users` u, `roles` r
WHERE u.`phone` = '+8613800000000' AND r.`name` IN ('ROLE_USER','ROLE_ADMIN');

-- 4) Useful checks
-- SHOW TABLES;
-- SELECT u.phone, r.name FROM user_roles ur
-- JOIN users u ON ur.user_id = u.id
-- JOIN roles r ON ur.role_id = r.id
-- ORDER BY u.phone, r.name;
