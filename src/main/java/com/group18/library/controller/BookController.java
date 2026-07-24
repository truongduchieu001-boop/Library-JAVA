package com.group18.library.controller;

import com.group18.library.dto.request.BookRequest;
import com.group18.library.dto.response.*;
import com.group18.library.service.BookService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/books")
@RequiredArgsConstructor
public class BookController {
    private final BookService bookService;

    @PostMapping
    public ResponseEntity<ApiResponse<BookResponse>> create(@Valid @RequestBody BookRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.success("Thêm sách thành công", bookService.create(request)));
    }

    @GetMapping("/{id}")
    public ApiResponse<BookResponse> get(@PathVariable Long id) {
        return ApiResponse.success("Lấy sách thành công", bookService.getById(id));
    }

    @GetMapping
    public ApiResponse<Page<BookResponse>> all(@RequestParam(required=false) String keyword,
            @PageableDefault(size=10, sort="title") Pageable pageable) {
        return ApiResponse.success("Lấy danh sách thành công", bookService.getAll(keyword, pageable));
    }

    @PutMapping("/{id}")
    public ApiResponse<BookResponse> update(@PathVariable Long id, @Valid @RequestBody BookRequest request) {
        return ApiResponse.success("Cập nhật thành công", bookService.update(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        bookService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
