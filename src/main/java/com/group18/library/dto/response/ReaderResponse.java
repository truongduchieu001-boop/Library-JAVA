package com.group18.library.dto.response;

import com.group18.library.entity.enums.ReaderStatus;

import java.time.LocalDate;
import java.time.LocalDateTime;

public record ReaderResponse(
    Long id,
    String readerCode,
    String fullName,
    String email,
    String phone,
    String address,
    LocalDate dateOfBirth,
    LocalDate registeredDate,
    LocalDate expiredDate,
    ReaderStatus status,
    LocalDateTime createdAt,
    LocalDateTime updatedAt
) {}
