package com.example.nutrition.controller;

import com.example.nutrition.dto.SystemConfigDto;
import com.example.nutrition.entity.SystemConfig;
import com.example.nutrition.repository.SystemConfigRepository;
import com.example.nutrition.service.SystemService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.core.io.FileSystemResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/system")
@Tag(name = "System", description = "系统管理与工具接口（管理员）")
@PreAuthorize("hasRole('ADMIN')")
public class SystemController {
    private final SystemConfigRepository configRepository;
    private final SystemService systemService;

    public SystemController(SystemConfigRepository configRepository, SystemService systemService) {
        this.configRepository = configRepository;
        this.systemService = systemService;
    }

    @GetMapping("/configs")
    @Operation(summary = "列出所有系统配置")
    public List<SystemConfigDto> listConfigs() {
        return configRepository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    @PostMapping("/configs")
    @Operation(summary = "新增或更新系统配置")
    public ResponseEntity<?> upsertConfig(@Valid @RequestBody SystemConfigDto dto) {
        Optional<SystemConfig> exist = configRepository.findByKey(dto.getKey());
        SystemConfig cfg = exist.orElseGet(() -> SystemConfig.builder().key(dto.getKey()).build());
        cfg.setValue(dto.getValue());
        cfg.setDescription(dto.getDescription());
        configRepository.save(cfg);
        return ResponseEntity.ok(toDto(cfg));
    }

    @DeleteMapping("/configs/{key}")
    @Operation(summary = "删除某个配置")
    public ResponseEntity<?> deleteConfig(@PathVariable("key") String key) {
        return configRepository.findByKey(key)
                .map(cfg -> { configRepository.delete(cfg); return ResponseEntity.ok().build(); })
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping("/backup/export")
    @Operation(summary = "导出备份为JSON文件并下载")
    public ResponseEntity<FileSystemResource> exportBackup() throws IOException {
        Path file = systemService.exportBackup();
        FileSystemResource resource = new FileSystemResource(file.toFile());
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + file.getFileName().toString())
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .contentLength(resource.contentLength())
                .body(resource);
    }

    @PostMapping("/backup/import")
    @Operation(summary = "从 backups 目录导入指定JSON文件")
    public ResponseEntity<?> importBackup(@RequestParam("file") String filename) throws IOException {
        Path path = new File("backups", filename).toPath();
        if (!Files.exists(path)) {
            return ResponseEntity.badRequest().body("文件不存在: " + path);
        }
        systemService.importBackup(path);
        return ResponseEntity.ok("导入完成");
    }

    @GetMapping("/logs/tail")
    @Operation(summary = "查看应用日志的尾部内容")
    public ResponseEntity<String> tailLogs(@RequestParam(value = "lines", defaultValue = "200") int lines) throws IOException {
        Path log = new File("logs", "app.log").toPath();
        if (!Files.exists(log)) {
            return ResponseEntity.ok("日志文件不存在或尚未生成。");
        }
        List<String> all = Files.readAllLines(log);
        int from = Math.max(0, all.size() - Math.max(10, lines));
        String content = all.subList(from, all.size()).stream().collect(Collectors.joining("\n"));
        return ResponseEntity.ok().contentType(MediaType.TEXT_PLAIN).body(content);
    }

    private SystemConfigDto toDto(SystemConfig cfg) {
        SystemConfigDto dto = new SystemConfigDto();
        dto.setId(cfg.getId());
        dto.setKey(cfg.getKey());
        dto.setValue(cfg.getValue());
        dto.setDescription(cfg.getDescription());
        return dto;
    }
}
