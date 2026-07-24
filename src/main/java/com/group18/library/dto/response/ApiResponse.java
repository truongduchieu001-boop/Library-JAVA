package com.group18.library.dto.response;
import java.time.LocalDateTime;
public record ApiResponse<T>(boolean success, String message, T data, LocalDateTime timestamp) {
    public static <T> ApiResponse<T> success(String message, T data) {
        return new ApiResponse<>(true, message, data, LocalDateTime.now());
    }
}
