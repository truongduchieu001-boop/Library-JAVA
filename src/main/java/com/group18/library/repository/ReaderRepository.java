package com.group18.library.repository;

import com.group18.library.entity.Reader;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ReaderRepository extends JpaRepository<Reader, Long> {
    boolean existsByReaderCodeIgnoreCase(String readerCode);
    Optional<Reader> findByReaderCodeIgnoreCase(String readerCode);
    Optional<Reader> findByEmailIgnoreCase(String email);

    Page<Reader> findByFullNameContainingIgnoreCaseOrReaderCodeContainingIgnoreCase(
        String fullName,
        String readerCode,
        Pageable pageable
    );
}
