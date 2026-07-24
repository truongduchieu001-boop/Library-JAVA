package com.group18.library.service.impl;

import com.group18.library.dto.request.BookRequest;
import com.group18.library.dto.response.BookResponse;
import com.group18.library.entity.*;
import com.group18.library.exception.*;
import com.group18.library.mapper.BookMapper;
import com.group18.library.repository.*;
import com.group18.library.service.BookService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.HashSet;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class BookServiceImpl implements BookService {
    private final BookRepository bookRepository;
    private final CategoryRepository categoryRepository;
    private final PublisherRepository publisherRepository;
    private final AuthorRepository authorRepository;
    private final BookMapper bookMapper;

    @Override @Transactional
    public BookResponse create(BookRequest request) {
        if (request.isbn() != null && bookRepository.existsByIsbn(request.isbn()))
            throw new BusinessException("ISBN đã tồn tại");
        Book book = new Book();
        apply(book, request);
        return bookMapper.toResponse(bookRepository.save(book));
    }

    @Override
    public BookResponse getById(Long id) { return bookMapper.toResponse(find(id)); }

    @Override
    public Page<BookResponse> getAll(String keyword, Pageable pageable) {
        Page<Book> page = keyword == null || keyword.isBlank()
            ? bookRepository.findAll(pageable)
            : bookRepository.findByTitleContainingIgnoreCase(keyword.trim(), pageable);
        return page.map(bookMapper::toResponse);
    }

    @Override @Transactional
    public BookResponse update(Long id, BookRequest request) {
        Book book = find(id);
        if (request.isbn() != null && !request.isbn().isBlank()) {
            bookRepository.findByIsbn(request.isbn())
                .filter(existing -> !existing.getId().equals(id))
                .ifPresent(existing -> {
                    throw new BusinessException("ISBN đã được sử dụng");
                });
        }
        apply(book, request);
        return bookMapper.toResponse(bookRepository.save(book));
    }

    @Override @Transactional
    public void delete(Long id) { bookRepository.delete(find(id)); }

    private Book find(Long id) {
        return bookRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy sách id=" + id));
    }

    private void apply(Book book, BookRequest r) {
        Category category = categoryRepository.findById(r.categoryId())
            .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy thể loại"));
        Publisher publisher = r.publisherId() == null ? null : publisherRepository.findById(r.publisherId())
            .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy nhà xuất bản"));
        book.setIsbn(r.isbn());
        book.setTitle(r.title().trim());
        book.setCategory(category);
        book.setPublisher(publisher);
        book.setPublicationYear(r.publicationYear());
        book.setLanguage(r.language().trim());
        book.setPageCount(r.pageCount());
        book.setDescription(r.description());
        if (r.authorIds() == null || r.authorIds().isEmpty()) book.setAuthors(new HashSet<>());
        else {
            var authors = new HashSet<>(authorRepository.findAllById(r.authorIds()));
            if (authors.size() != r.authorIds().size())
                throw new ResourceNotFoundException("Có tác giả không tồn tại");
            book.setAuthors(authors);
        }
    }
}
