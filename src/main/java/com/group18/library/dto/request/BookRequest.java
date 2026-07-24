package com.group18.library.dto.request;

import jakarta.validation.constraints.*;
import java.util.Set;

public record BookRequest(
    @Size(max = 20) String isbn,
    @NotBlank @Size(max = 255) String title,
    @NotNull Long categoryId,
    Long publisherId,
    @Min(1000) @Max(2100) Integer publicationYear,
    @NotBlank @Size(max = 50) String language,
    @Positive Integer pageCount,
    @Size(max = 2000) String description,
    Set<Long> authorIds
) {}
