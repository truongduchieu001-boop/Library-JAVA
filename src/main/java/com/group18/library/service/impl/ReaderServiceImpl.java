package com.group18.library.service.impl;

import com.group18.library.dto.request.ReaderRequest;
import com.group18.library.dto.response.ReaderResponse;
import com.group18.library.entity.Reader;
import com.group18.library.exception.BusinessException;
import com.group18.library.exception.ResourceNotFoundException;
import com.group18.library.mapper.ReaderMapper;
import com.group18.library.repository.ReaderRepository;
import com.group18.library.service.ReaderService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ReaderServiceImpl implements ReaderService {

    private final ReaderRepository readerRepository;
    private final ReaderMapper readerMapper;

    @Override
    @Transactional
    public ReaderResponse create(ReaderRequest request) {
        String readerCode = normalizeRequired(request.readerCode());
        String email = normalizeOptional(request.email());

        if (readerRepository.existsByReaderCodeIgnoreCase(readerCode)) {
            throw new BusinessException("Mã độc giả đã tồn tại");
        }
        validateUniqueEmail(email, null);
        validateDates(request);

        Reader reader = new Reader();
        apply(reader, request, readerCode, email);
        return readerMapper.toResponse(readerRepository.save(reader));
    }

    @Override
    public ReaderResponse getById(Long id) {
        return readerMapper.toResponse(find(id));
    }

    @Override
    public Page<ReaderResponse> getAll(String keyword, Pageable pageable) {
        Page<Reader> page = keyword == null || keyword.isBlank()
            ? readerRepository.findAll(pageable)
            : readerRepository.findByFullNameContainingIgnoreCaseOrReaderCodeContainingIgnoreCase(
                keyword.trim(), keyword.trim(), pageable
            );
        return page.map(readerMapper::toResponse);
    }

    @Override
    @Transactional
    public ReaderResponse update(Long id, ReaderRequest request) {
        Reader reader = find(id);
        String readerCode = normalizeRequired(request.readerCode());
        String email = normalizeOptional(request.email());

        readerRepository.findByReaderCodeIgnoreCase(readerCode)
            .filter(existing -> !existing.getId().equals(id))
            .ifPresent(existing -> {
                throw new BusinessException("Mã độc giả đã được sử dụng");
            });

        validateUniqueEmail(email, id);
        validateDates(request);
        apply(reader, request, readerCode, email);
        return readerMapper.toResponse(readerRepository.save(reader));
    }

    @Override
    @Transactional
    public void delete(Long id) {
        readerRepository.delete(find(id));
    }

    private Reader find(Long id) {
        return readerRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy độc giả id=" + id));
    }

    private void validateUniqueEmail(String email, Long currentId) {
        if (email == null) {
            return;
        }

        readerRepository.findByEmailIgnoreCase(email)
            .filter(existing -> currentId == null || !existing.getId().equals(currentId))
            .ifPresent(existing -> {
                throw new BusinessException("Email đã được sử dụng");
            });
    }

    private void validateDates(ReaderRequest request) {
        if (request.expiredDate() != null
                && request.expiredDate().isBefore(request.registeredDate())) {
            throw new BusinessException("Ngày hết hạn phải lớn hơn hoặc bằng ngày đăng ký");
        }
    }

    private void apply(Reader reader, ReaderRequest request, String readerCode, String email) {
        reader.setReaderCode(readerCode);
        reader.setFullName(normalizeRequired(request.fullName()));
        reader.setEmail(email);
        reader.setPhone(normalizeOptional(request.phone()));
        reader.setAddress(normalizeOptional(request.address()));
        reader.setDateOfBirth(request.dateOfBirth());
        reader.setRegisteredDate(request.registeredDate());
        reader.setExpiredDate(request.expiredDate());
        reader.setStatus(request.status());
    }

    private String normalizeRequired(String value) {
        return value.trim();
    }

    private String normalizeOptional(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }
}
