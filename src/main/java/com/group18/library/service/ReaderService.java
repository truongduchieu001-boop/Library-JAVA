package com.group18.library.service;

import com.group18.library.dto.request.ReaderRequest;
import com.group18.library.dto.response.ReaderResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface ReaderService {
    ReaderResponse create(ReaderRequest request);
    ReaderResponse getById(Long id);
    Page<ReaderResponse> getAll(String keyword, Pageable pageable);
    ReaderResponse update(Long id, ReaderRequest request);
    void delete(Long id);
}
