package com.group18.library.controller;

import com.group18.library.dto.request.ReaderRequest;
import com.group18.library.dto.response.ApiResponse;
import com.group18.library.dto.response.ReaderResponse;
import com.group18.library.service.ReaderService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/readers")
@RequiredArgsConstructor
public class ReaderController {

    private final ReaderService readerService;

    @PostMapping
    public ResponseEntity<ApiResponse<ReaderResponse>> create(
            @Valid @RequestBody ReaderRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.success("Thêm độc giả thành công", readerService.create(request)));
    }

    @GetMapping("/{id}")
    public ApiResponse<ReaderResponse> getById(@PathVariable Long id) {
        return ApiResponse.success("Lấy độc giả thành công", readerService.getById(id));
    }

    @GetMapping
    public ApiResponse<Page<ReaderResponse>> getAll(
            @RequestParam(required = false) String keyword,
            @PageableDefault(size = 10, sort = "fullName") Pageable pageable) {
        return ApiResponse.success(
            "Lấy danh sách độc giả thành công",
            readerService.getAll(keyword, pageable)
        );
    }

    @PutMapping("/{id}")
    public ApiResponse<ReaderResponse> update(
            @PathVariable Long id,
            @Valid @RequestBody ReaderRequest request) {
        return ApiResponse.success(
            "Cập nhật độc giả thành công",
            readerService.update(id, request)
        );
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        readerService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
