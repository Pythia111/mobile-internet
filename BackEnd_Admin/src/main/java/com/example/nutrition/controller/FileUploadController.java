package com.example.nutrition.controller;

import com.example.nutrition.common.ApiResponse;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.UUID;

@RestController
@RequestMapping("/api/upload")
public class FileUploadController {

    private static final String UPLOAD_DIR = "uploads";

    @PostMapping("/image")
    public ApiResponse<String> uploadImage(@RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return ApiResponse.error(400, "Please select a file to upload");
        }

        try {
            // 确保上传目录存在
            File uploadDir = new File(UPLOAD_DIR);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            // 生成唯一文件名
            String originalFilename = file.getOriginalFilename();
            String extension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            String newFilename = UUID.randomUUID().toString() + extension;

            // 保存文件
            File dest = new File(uploadDir.getAbsolutePath() + File.separator + newFilename);
            file.transferTo(dest);

            // 返回访问 URL (假设后端运行在同一域名/端口，或者前端配置了代理)
            // 这里返回相对路径，前端可以拼接 host
            String fileUrl = "/uploads/" + newFilename;
            return ApiResponse.success("Upload successful", fileUrl);

        } catch (IOException e) {
            e.printStackTrace();
            return ApiResponse.error(500, "Failed to upload file: " + e.getMessage());
        }
    }
}
