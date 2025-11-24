package com.example.nutrition.dto;

import javax.validation.constraints.Size;
import lombok.Data;

@Data
public class UpdateProfileRequest {
    @Size(min = 1, max = 64)
    private String username;

    @Size(min = 6)
    private String password;

    @Size(max = 256)
    private String avatar;
}
