-- =========================================================
-- DATABASE: Library Management System - Group 18
-- DBMS: MySQL 8+
-- =========================================================

DROP DATABASE IF EXISTS library_management;
CREATE DATABASE library_management
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE library_management;

-- =========================================================
-- 1. USERS
-- =========================================================
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE,
    phone VARCHAR(20),
    role ENUM('ADMIN', 'LIBRARIAN') NOT NULL DEFAULT 'LIBRARIAN',
    status ENUM('ACTIVE', 'INACTIVE', 'LOCKED') NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP
);

-- =========================================================
-- 2. READERS
-- =========================================================
CREATE TABLE readers (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    reader_code VARCHAR(30) NOT NULL UNIQUE,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE,
    phone VARCHAR(20),
    address VARCHAR(255),
    date_of_birth DATE,
    registered_date DATE NOT NULL,
    expired_date DATE,
    status ENUM('ACTIVE', 'LOCKED', 'EXPIRED') NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_reader_expired_date
        CHECK (expired_date IS NULL OR expired_date >= registered_date)
);

-- =========================================================
-- 3. CATEGORIES
-- =========================================================
CREATE TABLE categories (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(500),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP
);

-- =========================================================
-- 4. PUBLISHERS
-- =========================================================
CREATE TABLE publishers (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL UNIQUE,
    address VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(150),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP
);

-- =========================================================
-- 5. AUTHORS
-- =========================================================
CREATE TABLE authors (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    biography TEXT,
    date_of_birth DATE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_authors_name (name)
);

-- =========================================================
-- 6. BOOKS
-- =========================================================
CREATE TABLE books (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    isbn VARCHAR(20) UNIQUE,
    title VARCHAR(255) NOT NULL,
    category_id BIGINT NOT NULL,
    publisher_id BIGINT,
    publication_year INT,
    language VARCHAR(50) NOT NULL DEFAULT 'Vietnamese',
    page_count INT,
    description TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_books_category
        FOREIGN KEY (category_id)
        REFERENCES categories(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_books_publisher
        FOREIGN KEY (publisher_id)
        REFERENCES publishers(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT chk_books_publication_year
        CHECK (publication_year IS NULL OR publication_year BETWEEN 1000 AND 2100),

    CONSTRAINT chk_books_page_count
        CHECK (page_count IS NULL OR page_count > 0),

    INDEX idx_books_title (title),
    INDEX idx_books_category_id (category_id),
    INDEX idx_books_publisher_id (publisher_id)
);

-- =========================================================
-- 7. BOOK_AUTHORS (N-N)
-- =========================================================
CREATE TABLE book_authors (
    book_id BIGINT NOT NULL,
    author_id BIGINT NOT NULL,

    PRIMARY KEY (book_id, author_id),

    CONSTRAINT fk_book_authors_book
        FOREIGN KEY (book_id)
        REFERENCES books(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_book_authors_author
        FOREIGN KEY (author_id)
        REFERENCES authors(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    INDEX idx_book_authors_author_id (author_id)
);

-- =========================================================
-- 8. BOOK_COPIES
-- =========================================================
CREATE TABLE book_copies (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    book_id BIGINT NOT NULL,
    copy_code VARCHAR(30) NOT NULL UNIQUE,
    shelf_location VARCHAR(100),
    import_date DATE,
    condition_status ENUM('NEW', 'GOOD', 'FAIR', 'POOR') NOT NULL DEFAULT 'GOOD',
    availability_status ENUM(
        'AVAILABLE',
        'BORROWED',
        'LOST',
        'DAMAGED',
        'MAINTENANCE'
    ) NOT NULL DEFAULT 'AVAILABLE',
    note VARCHAR(500),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_book_copies_book
        FOREIGN KEY (book_id)
        REFERENCES books(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    INDEX idx_book_copies_book_id (book_id),
    INDEX idx_book_copies_availability (availability_status)
);

-- =========================================================
-- 9. BORROW_SLIPS
-- =========================================================
CREATE TABLE borrow_slips (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    borrow_code VARCHAR(30) NOT NULL UNIQUE,
    reader_id BIGINT NOT NULL,
    staff_id BIGINT NOT NULL,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    completed_date DATE,
    status ENUM(
        'BORROWING',
        'COMPLETED',
        'OVERDUE',
        'CANCELLED'
    ) NOT NULL DEFAULT 'BORROWING',
    note VARCHAR(500),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_borrow_slips_reader
        FOREIGN KEY (reader_id)
        REFERENCES readers(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_borrow_slips_staff
        FOREIGN KEY (staff_id)
        REFERENCES users(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_borrow_due_date
        CHECK (due_date >= borrow_date),

    CONSTRAINT chk_borrow_completed_date
        CHECK (completed_date IS NULL OR completed_date >= borrow_date),

    INDEX idx_borrow_slips_reader_id (reader_id),
    INDEX idx_borrow_slips_staff_id (staff_id),
    INDEX idx_borrow_slips_status (status),
    INDEX idx_borrow_slips_due_date (due_date)
);

-- =========================================================
-- 10. BORROW_DETAILS
-- =========================================================
CREATE TABLE borrow_details (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    borrow_slip_id BIGINT NOT NULL,
    book_copy_id BIGINT NOT NULL,
    returned_date DATE,
    condition_on_borrow ENUM('NEW', 'GOOD', 'FAIR', 'POOR') NOT NULL,
    condition_on_return ENUM('NEW', 'GOOD', 'FAIR', 'POOR'),
    status ENUM('BORROWED', 'RETURNED', 'LOST', 'DAMAGED') NOT NULL DEFAULT 'BORROWED',
    note VARCHAR(500),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_borrow_details_slip
        FOREIGN KEY (borrow_slip_id)
        REFERENCES borrow_slips(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_borrow_details_copy
        FOREIGN KEY (book_copy_id)
        REFERENCES book_copies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT uk_borrow_detail_copy
        UNIQUE (borrow_slip_id, book_copy_id),

    INDEX idx_borrow_details_slip_id (borrow_slip_id),
    INDEX idx_borrow_details_copy_id (book_copy_id),
    INDEX idx_borrow_details_status (status)
);

-- =========================================================
-- 11. FINES
-- Cho phép một chi tiết mượn có nhiều khoản phạt.
-- =========================================================
CREATE TABLE fines (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    borrow_detail_id BIGINT NOT NULL,
    fine_type ENUM('OVERDUE', 'LOST', 'DAMAGED', 'OTHER') NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    reason VARCHAR(500),
    payment_status ENUM('UNPAID', 'PAID', 'CANCELLED') NOT NULL DEFAULT 'UNPAID',
    paid_date DATETIME,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_fines_borrow_detail
        FOREIGN KEY (borrow_detail_id)
        REFERENCES borrow_details(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT chk_fines_amount
        CHECK (amount >= 0),

    CONSTRAINT chk_fines_paid_date
        CHECK (
            (payment_status = 'PAID' AND paid_date IS NOT NULL)
            OR
            (payment_status <> 'PAID')
        ),

    INDEX idx_fines_borrow_detail_id (borrow_detail_id),
    INDEX idx_fines_payment_status (payment_status)
);

-- =========================================================
-- 12. RESERVATIONS (TÍNH NĂNG NÂNG CAO)
-- =========================================================
CREATE TABLE reservations (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    reservation_code VARCHAR(30) NOT NULL UNIQUE,
    reader_id BIGINT NOT NULL,
    book_id BIGINT NOT NULL,
    reservation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expiry_date DATETIME,
    status ENUM('PENDING', 'READY', 'COMPLETED', 'CANCELLED', 'EXPIRED')
        NOT NULL DEFAULT 'PENDING',
    note VARCHAR(500),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_reservations_reader
        FOREIGN KEY (reader_id)
        REFERENCES readers(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_reservations_book
        FOREIGN KEY (book_id)
        REFERENCES books(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_reservation_expiry
        CHECK (expiry_date IS NULL OR expiry_date >= reservation_date),

    INDEX idx_reservations_reader_id (reader_id),
    INDEX idx_reservations_book_id (book_id),
    INDEX idx_reservations_status (status)
);

-- =========================================================
-- SAMPLE DATA
-- Mật khẩu chỉ là chuỗi minh họa, khi code phải dùng BCrypt.
-- =========================================================

INSERT INTO users
(username, password_hash, full_name, email, phone, role, status)
VALUES
('admin', '$2a$10$demo.admin.hash', 'Quản trị viên', 'admin@library.local', '0900000001', 'ADMIN', 'ACTIVE'),
('librarian01', '$2a$10$demo.staff.hash', 'Nguyễn Thị Thủ Thư', 'staff@library.local', '0900000002', 'LIBRARIAN', 'ACTIVE');

INSERT INTO readers
(reader_code, full_name, email, phone, address, date_of_birth, registered_date, expired_date, status)
VALUES
('DG001', 'Trần Minh Anh', 'minhanh@example.com', '0911000001', 'TP. Hồ Chí Minh', '2004-03-12', '2026-07-18', '2027-07-18', 'ACTIVE'),
('DG002', 'Lê Quốc Bảo', 'quocbao@example.com', '0911000002', 'Bình Dương', '2003-08-21', '2026-07-18', '2027-07-18', 'ACTIVE'),
('DG003', 'Phạm Ngọc Lan', 'ngoclan@example.com', '0911000003', 'Đồng Nai', '2005-11-05', '2026-07-18', '2027-07-18', 'ACTIVE'),
('DG004', 'Võ Thành Đạt', 'thanhdat@example.com', '0911000004', 'TP. Hồ Chí Minh', '2004-01-30', '2026-07-18', '2027-07-18', 'LOCKED'),
('DG005', 'Nguyễn Hoài Nam', 'hoainam@example.com', '0911000005', 'Long An', '2002-06-17', '2026-07-18', '2027-07-18', 'ACTIVE');

INSERT INTO categories (name, description)
VALUES
('Công nghệ thông tin', 'Sách về lập trình, hệ thống và công nghệ'),
('Kinh tế', 'Sách kinh tế và quản trị'),
('Văn học', 'Tác phẩm văn học trong và ngoài nước'),
('Ngoại ngữ', 'Sách học ngoại ngữ'),
('Khoa học', 'Sách khoa học tự nhiên và ứng dụng');

INSERT INTO publishers (name, address, phone, email)
VALUES
('NXB Trẻ', 'TP. Hồ Chí Minh', '0281111111', 'contact@nxbtre.vn'),
('NXB Kim Đồng', 'Hà Nội', '0242222222', 'contact@kimdong.vn'),
('NXB Thông tin và Truyền thông', 'Hà Nội', '0243333333', 'contact@mic.gov.vn');

INSERT INTO authors (name, biography, date_of_birth)
VALUES
('Robert C. Martin', 'Tác giả nhiều sách về kỹ nghệ phần mềm.', '1952-12-05'),
('Joshua Bloch', 'Chuyên gia Java và tác giả Effective Java.', '1961-08-28'),
('Nguyễn Nhật Ánh', 'Nhà văn Việt Nam.', '1955-05-07'),
('Dale Carnegie', 'Tác giả sách kỹ năng và giao tiếp.', '1888-11-24'),
('Eric Freeman', 'Đồng tác giả Head First Design Patterns.', NULL);

INSERT INTO books
(isbn, title, category_id, publisher_id, publication_year, language, page_count, description)
VALUES
('9780132350884', 'Clean Code', 1, 3, 2008, 'English', 464, 'Nguyên tắc viết mã sạch.'),
('9780134685991', 'Effective Java', 1, 3, 2018, 'English', 416, 'Thực hành tốt trong Java.'),
('9786041123456', 'Tôi thấy hoa vàng trên cỏ xanh', 3, 1, 2010, 'Vietnamese', 380, 'Tiểu thuyết của Nguyễn Nhật Ánh.'),
('9786042234567', 'Đắc nhân tâm', 2, 1, 2019, 'Vietnamese', 320, 'Sách kỹ năng giao tiếp.'),
('9780596007126', 'Head First Design Patterns', 1, 3, 2004, 'English', 694, 'Các mẫu thiết kế phần mềm.');

INSERT INTO book_authors (book_id, author_id)
VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

INSERT INTO book_copies
(book_id, copy_code, shelf_location, import_date, condition_status, availability_status)
VALUES
(1, 'BC001', 'A1-01', '2026-07-18', 'GOOD', 'AVAILABLE'),
(1, 'BC002', 'A1-01', '2026-07-18', 'GOOD', 'AVAILABLE'),
(2, 'BC003', 'A1-02', '2026-07-18', 'NEW', 'AVAILABLE'),
(2, 'BC004', 'A1-02', '2026-07-18', 'GOOD', 'AVAILABLE'),
(3, 'BC005', 'B1-01', '2026-07-18', 'GOOD', 'AVAILABLE'),
(3, 'BC006', 'B1-01', '2026-07-18', 'FAIR', 'AVAILABLE'),
(4, 'BC007', 'C1-01', '2026-07-18', 'GOOD', 'AVAILABLE'),
(4, 'BC008', 'C1-01', '2026-07-18', 'GOOD', 'AVAILABLE'),
(5, 'BC009', 'A1-03', '2026-07-18', 'NEW', 'AVAILABLE'),
(5, 'BC010', 'A1-03', '2026-07-18', 'GOOD', 'AVAILABLE');

-- Phiếu mượn mẫu
INSERT INTO borrow_slips
(borrow_code, reader_id, staff_id, borrow_date, due_date, status, note)
VALUES
('PM001', 1, 2, '2026-07-18', '2026-08-01', 'BORROWING', 'Phiếu mượn mẫu');

INSERT INTO borrow_details
(borrow_slip_id, book_copy_id, condition_on_borrow, status)
VALUES
(1, 1, 'GOOD', 'BORROWED'),
(1, 3, 'NEW', 'BORROWED');

UPDATE book_copies
SET availability_status = 'BORROWED'
WHERE id IN (1, 3);

-- =========================================================
-- USEFUL VIEWS
-- =========================================================

CREATE OR REPLACE VIEW vw_book_inventory AS
SELECT
    b.id AS book_id,
    b.isbn,
    b.title,
    COUNT(bc.id) AS total_copies,
    SUM(CASE WHEN bc.availability_status = 'AVAILABLE' THEN 1 ELSE 0 END) AS available_copies,
    SUM(CASE WHEN bc.availability_status = 'BORROWED' THEN 1 ELSE 0 END) AS borrowed_copies,
    SUM(CASE WHEN bc.availability_status = 'LOST' THEN 1 ELSE 0 END) AS lost_copies,
    SUM(CASE WHEN bc.availability_status = 'DAMAGED' THEN 1 ELSE 0 END) AS damaged_copies
FROM books b
LEFT JOIN book_copies bc ON bc.book_id = b.id
GROUP BY b.id, b.isbn, b.title;

CREATE OR REPLACE VIEW vw_overdue_borrow_details AS
SELECT
    bs.borrow_code,
    r.reader_code,
    r.full_name AS reader_name,
    b.title AS book_title,
    bc.copy_code,
    bs.borrow_date,
    bs.due_date,
    DATEDIFF(CURRENT_DATE, bs.due_date) AS overdue_days
FROM borrow_details bd
JOIN borrow_slips bs ON bs.id = bd.borrow_slip_id
JOIN readers r ON r.id = bs.reader_id
JOIN book_copies bc ON bc.id = bd.book_copy_id
JOIN books b ON b.id = bc.book_id
WHERE bd.status = 'BORROWED'
  AND bs.due_date < CURRENT_DATE;

-- =========================================================
-- SAMPLE QUERIES
-- =========================================================

-- Danh sách sách và số lượng còn sẵn:
-- SELECT * FROM vw_book_inventory ORDER BY title;

-- Danh sách sách quá hạn:
-- SELECT * FROM vw_overdue_borrow_details ORDER BY overdue_days DESC;

-- Tìm sách theo tên:
-- SELECT * FROM books WHERE title LIKE CONCAT('%', 'Java', '%');

-- Top sách được mượn nhiều:
-- SELECT b.id, b.title, COUNT(*) AS borrow_count
-- FROM borrow_details bd
-- JOIN book_copies bc ON bc.id = bd.book_copy_id
-- JOIN books b ON b.id = bc.book_id
-- GROUP BY b.id, b.title
-- ORDER BY borrow_count DESC
-- LIMIT 10;
