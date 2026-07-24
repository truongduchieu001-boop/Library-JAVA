package com.group18.library.mapper;

import com.group18.library.dto.response.BookResponse;
import com.group18.library.entity.Author;
import com.group18.library.entity.Book;
import org.springframework.stereotype.Component;
import java.util.stream.Collectors;

@Component
public class BookMapper {
    public BookResponse toResponse(Book book) {
        return new BookResponse(
            book.getId(), book.getIsbn(), book.getTitle(),
            book.getCategory().getId(), book.getCategory().getName(),
            book.getPublisher() == null ? null : book.getPublisher().getId(),
            book.getPublisher() == null ? null : book.getPublisher().getName(),
            book.getPublicationYear(), book.getLanguage(), book.getPageCount(),
            book.getDescription(),
            book.getAuthors().stream().map(Author::getName).collect(Collectors.toSet())
        );
    }
}
