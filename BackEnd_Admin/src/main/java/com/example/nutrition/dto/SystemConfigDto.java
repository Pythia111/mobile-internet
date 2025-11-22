package com.example.nutrition.dto;

import javax.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class SystemConfigDto {
    private Long id;

    @NotBlank
    private String key;

    private String value;

    private String description;
}
