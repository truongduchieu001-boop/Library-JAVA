package com.group18.library.repository;
import com.group18.library.entity.Author;
import org.springframework.data.jpa.repository.JpaRepository;
public interface AuthorRepository extends JpaRepository<Author, Long> {}
