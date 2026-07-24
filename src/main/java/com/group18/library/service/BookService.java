package com.group18.library.service;
import com.group18.library.dto.request.BookRequest;
import com.group18.library.dto.response.BookResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
public interface BookService {
    BookResponse create(BookRequest request);
    BookResponse getById(Long id);
    Page<BookResponse> getAll(String keyword, Pageable pageable);
    BookResponse update(Long id, BookRequest request);
    void delete(Long id);
}
