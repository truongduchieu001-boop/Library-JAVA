package com.group18.library.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "publishers")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Publisher extends BaseEntity {
    @Column(nullable = false, unique = true, length = 150)
    private String name;
    @Column(length = 255)
    private String address;

    @Column(length = 20)
    private String phone;

    @Column(length = 150)
    private String email;
}
