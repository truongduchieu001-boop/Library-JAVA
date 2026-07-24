package com.group18.library.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Entity
@Table(name = "authors")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Author extends BaseEntity {
    @Column(nullable = false, length = 150)
    private String name;
    @Column(columnDefinition = "TEXT")
    private String biography;
    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;
}
