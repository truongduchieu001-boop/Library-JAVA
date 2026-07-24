package com.group18.library.exception;
import java.time.LocalDateTime;
import java.util.Map;
public record ErrorResponse(int status, String error, String message, String path,
                            Map<String,String> validationErrors, LocalDateTime timestamp) {}
