package com.group18.library.dto.response;
import java.util.Set;
public record BookResponse(Long id, String isbn, String title, Long categoryId,
    String categoryName, Long publisherId, String publisherName,
    Integer publicationYear, String language, Integer pageCount,
    String description, Set<String> authors) {}
