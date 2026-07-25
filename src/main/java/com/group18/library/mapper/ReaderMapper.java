package com.group18.library.mapper;

import com.group18.library.dto.response.ReaderResponse;
import com.group18.library.entity.Reader;
import org.springframework.stereotype.Component;

@Component
public class ReaderMapper {
    public ReaderResponse toResponse(Reader reader) {
        return new ReaderResponse(
            reader.getId(),
            reader.getReaderCode(),
            reader.getFullName(),
            reader.getEmail(),
            reader.getPhone(),
            reader.getAddress(),
            reader.getDateOfBirth(),
            reader.getRegisteredDate(),
            reader.getExpiredDate(),
            reader.getStatus(),
            reader.getCreatedAt(),
            reader.getUpdatedAt()
        );
    }
}
