package com.group18.library.entity;

import com.group18.library.entity.enums.ReaderStatus;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "readers")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Reader extends BaseEntity {

    @Column(name = "reader_code", nullable = false, unique = true, length = 30)
    private String readerCode;

    @Column(name = "full_name", nullable = false, length = 150)
    private String fullName;

    @Column(length = 150)
    private String email;

    @Column(length = 20)
    private String phone;

    @Column(length = 255)
    private String address;

    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;

    @Column(name = "registered_date", nullable = false)
    private LocalDate registeredDate;

    @Column(name = "expired_date")
    private LocalDate expiredDate;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private ReaderStatus status = ReaderStatus.ACTIVE;
}
