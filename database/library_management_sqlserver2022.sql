-- =============================================================
-- DATABASE: Library Management System - Group 18
-- DBMS: Microsoft SQL Server 2022
-- Run with SQL Server Management Studio (SSMS)
-- =============================================================

USE master;
GO

IF DB_ID(N'library_management') IS NOT NULL
BEGIN
    ALTER DATABASE library_management
        SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE library_management;
END;
GO

CREATE DATABASE library_management
COLLATE Vietnamese_CI_AS;
GO

USE library_management;
GO

-- =============================================================
-- 1. USERS
-- =============================================================
CREATE TABLE dbo.users (
    id BIGINT IDENTITY(1,1) NOT NULL,
    username VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NULL,
    phone VARCHAR(20) NULL,
    role VARCHAR(20) NOT NULL
        CONSTRAINT df_users_role DEFAULT ('LIBRARIAN'),
    status VARCHAR(20) NOT NULL
        CONSTRAINT df_users_status DEFAULT ('ACTIVE'),
    created_at DATETIME2(6) NOT NULL
        CONSTRAINT df_users_created_at DEFAULT (SYSDATETIME()),
    updated_at DATETIME2(6) NOT NULL
        CONSTRAINT df_users_updated_at DEFAULT (SYSDATETIME()),

    CONSTRAINT pk_users PRIMARY KEY (id),
    CONSTRAINT uq_users_username UNIQUE (username),
    CONSTRAINT chk_users_role
        CHECK (role IN ('ADMIN', 'LIBRARIAN')),
    CONSTRAINT chk_users_status
        CHECK (status IN ('ACTIVE', 'INACTIVE', 'LOCKED'))
);
GO

CREATE UNIQUE INDEX ux_users_email
ON dbo.users(email)
WHERE email IS NOT NULL;
GO

-- =============================================================
-- 2. READERS
-- =============================================================
CREATE TABLE dbo.readers (
    id BIGINT IDENTITY(1,1) NOT NULL,
    reader_code VARCHAR(30) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NULL,
    phone VARCHAR(20) NULL,
    address VARCHAR(255) NULL,
    date_of_birth DATE NULL,
    registered_date DATE NOT NULL,
    expired_date DATE NULL,
    status VARCHAR(20) NOT NULL
        CONSTRAINT df_readers_status DEFAULT ('ACTIVE'),
    created_at DATETIME2(6) NOT NULL
        CONSTRAINT df_readers_created_at DEFAULT (SYSDATETIME()),
    updated_at DATETIME2(6) NOT NULL
        CONSTRAINT df_readers_updated_at DEFAULT (SYSDATETIME()),

    CONSTRAINT pk_readers PRIMARY KEY (id),
    CONSTRAINT uq_readers_reader_code UNIQUE (reader_code),
    CONSTRAINT chk_readers_status
        CHECK (status IN ('ACTIVE', 'LOCKED', 'EXPIRED')),
    CONSTRAINT chk_reader_expired_date
        CHECK (expired_date IS NULL OR expired_date >= registered_date)
);
GO

CREATE UNIQUE INDEX ux_readers_email
ON dbo.readers(email)
WHERE email IS NOT NULL;
GO

-- =============================================================
-- 3. CATEGORIES
-- =============================================================
CREATE TABLE dbo.categories (
    id BIGINT IDENTITY(1,1) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(500) NULL,
    created_at DATETIME2(6) NOT NULL
        CONSTRAINT df_categories_created_at DEFAULT (SYSDATETIME()),
    updated_at DATETIME2(6) NOT NULL
        CONSTRAINT df_categories_updated_at DEFAULT (SYSDATETIME()),

    CONSTRAINT pk_categories PRIMARY KEY (id),
    CONSTRAINT uq_categories_name UNIQUE (name)
);
GO

-- =============================================================
-- 4. PUBLISHERS
-- =============================================================
CREATE TABLE dbo.publishers (
    id BIGINT IDENTITY(1,1) NOT NULL,
    name VARCHAR(150) NOT NULL,
    address VARCHAR(255) NULL,
    phone VARCHAR(20) NULL,
    email VARCHAR(150) NULL,
    created_at DATETIME2(6) NOT NULL
        CONSTRAINT df_publishers_created_at DEFAULT (SYSDATETIME()),
    updated_at DATETIME2(6) NOT NULL
        CONSTRAINT df_publishers_updated_at DEFAULT (SYSDATETIME()),

    CONSTRAINT pk_publishers PRIMARY KEY (id),
    CONSTRAINT uq_publishers_name UNIQUE (name)
);
GO

-- =============================================================
-- 5. AUTHORS
-- =============================================================
CREATE TABLE dbo.authors (
    id BIGINT IDENTITY(1,1) NOT NULL,
    name VARCHAR(150) NOT NULL,
    biography VARCHAR(MAX) NULL,
    date_of_birth DATE NULL,
    created_at DATETIME2(6) NOT NULL
        CONSTRAINT df_authors_created_at DEFAULT (SYSDATETIME()),
    updated_at DATETIME2(6) NOT NULL
        CONSTRAINT df_authors_updated_at DEFAULT (SYSDATETIME()),

    CONSTRAINT pk_authors PRIMARY KEY (id)
);
GO

CREATE INDEX ix_authors_name ON dbo.authors(name);
GO

-- =============================================================
-- 6. BOOKS
-- =============================================================
CREATE TABLE dbo.books (
    id BIGINT IDENTITY(1,1) NOT NULL,
    isbn VARCHAR(20) NULL,
    title VARCHAR(255) NOT NULL,
    category_id BIGINT NOT NULL,
    publisher_id BIGINT NULL,
    publication_year INT NULL,
    [language] VARCHAR(50) NOT NULL
        CONSTRAINT df_books_language DEFAULT ('Vietnamese'),
    page_count INT NULL,
    description VARCHAR(MAX) NULL,
    created_at DATETIME2(6) NOT NULL
        CONSTRAINT df_books_created_at DEFAULT (SYSDATETIME()),
    updated_at DATETIME2(6) NOT NULL
        CONSTRAINT df_books_updated_at DEFAULT (SYSDATETIME()),

    CONSTRAINT pk_books PRIMARY KEY (id),
    CONSTRAINT fk_books_category
        FOREIGN KEY (category_id)
        REFERENCES dbo.categories(id),
    CONSTRAINT fk_books_publisher
        FOREIGN KEY (publisher_id)
        REFERENCES dbo.publishers(id)
        ON DELETE SET NULL,
    CONSTRAINT chk_books_publication_year
        CHECK (publication_year IS NULL OR publication_year BETWEEN 1000 AND 2100),
    CONSTRAINT chk_books_page_count
        CHECK (page_count IS NULL OR page_count > 0)
);
GO

CREATE UNIQUE INDEX ux_books_isbn
ON dbo.books(isbn)
WHERE isbn IS NOT NULL;
GO

CREATE INDEX ix_books_title ON dbo.books(title);
CREATE INDEX ix_books_category_id ON dbo.books(category_id);
CREATE INDEX ix_books_publisher_id ON dbo.books(publisher_id);
GO

-- =============================================================
-- 7. BOOK_AUTHORS (N-N)
-- =============================================================
CREATE TABLE dbo.book_authors (
    book_id BIGINT NOT NULL,
    author_id BIGINT NOT NULL,

    CONSTRAINT pk_book_authors PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_book_authors_book
        FOREIGN KEY (book_id)
        REFERENCES dbo.books(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_book_authors_author
        FOREIGN KEY (author_id)
        REFERENCES dbo.authors(id)
        ON DELETE CASCADE
);
GO

CREATE INDEX ix_book_authors_author_id
ON dbo.book_authors(author_id);
GO

-- =============================================================
-- 8. BOOK_COPIES
-- =============================================================
CREATE TABLE dbo.book_copies (
    id BIGINT IDENTITY(1,1) NOT NULL,
    book_id BIGINT NOT NULL,
    copy_code VARCHAR(30) NOT NULL,
    shelf_location VARCHAR(100) NULL,
    import_date DATE NULL,
    condition_status VARCHAR(20) NOT NULL
        CONSTRAINT df_book_copies_condition DEFAULT ('GOOD'),
    availability_status VARCHAR(20) NOT NULL
        CONSTRAINT df_book_copies_availability DEFAULT ('AVAILABLE'),
    note VARCHAR(500) NULL,
    created_at DATETIME2(6) NOT NULL
        CONSTRAINT df_book_copies_created_at DEFAULT (SYSDATETIME()),
    updated_at DATETIME2(6) NOT NULL
        CONSTRAINT df_book_copies_updated_at DEFAULT (SYSDATETIME()),

    CONSTRAINT pk_book_copies PRIMARY KEY (id),
    CONSTRAINT uq_book_copies_copy_code UNIQUE (copy_code),
    CONSTRAINT fk_book_copies_book
        FOREIGN KEY (book_id)
        REFERENCES dbo.books(id),
    CONSTRAINT chk_book_copies_condition
        CHECK (condition_status IN ('NEW', 'GOOD', 'FAIR', 'POOR')),
    CONSTRAINT chk_book_copies_availability
        CHECK (
            availability_status IN (
                'AVAILABLE', 'BORROWED', 'LOST', 'DAMAGED', 'MAINTENANCE'
            )
        )
);
GO

CREATE INDEX ix_book_copies_book_id
ON dbo.book_copies(book_id);

CREATE INDEX ix_book_copies_availability
ON dbo.book_copies(availability_status);
GO

-- =============================================================
-- 9. BORROW_SLIPS
-- =============================================================
CREATE TABLE dbo.borrow_slips (
    id BIGINT IDENTITY(1,1) NOT NULL,
    borrow_code VARCHAR(30) NOT NULL,
    reader_id BIGINT NOT NULL,
    staff_id BIGINT NOT NULL,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    completed_date DATE NULL,
    status VARCHAR(20) NOT NULL
        CONSTRAINT df_borrow_slips_status DEFAULT ('BORROWING'),
    note VARCHAR(500) NULL,
    created_at DATETIME2(6) NOT NULL
        CONSTRAINT df_borrow_slips_created_at DEFAULT (SYSDATETIME()),
    updated_at DATETIME2(6) NOT NULL
        CONSTRAINT df_borrow_slips_updated_at DEFAULT (SYSDATETIME()),

    CONSTRAINT pk_borrow_slips PRIMARY KEY (id),
    CONSTRAINT uq_borrow_slips_borrow_code UNIQUE (borrow_code),
    CONSTRAINT fk_borrow_slips_reader
        FOREIGN KEY (reader_id)
        REFERENCES dbo.readers(id),
    CONSTRAINT fk_borrow_slips_staff
        FOREIGN KEY (staff_id)
        REFERENCES dbo.users(id),
    CONSTRAINT chk_borrow_slips_status
        CHECK (status IN ('BORROWING', 'COMPLETED', 'OVERDUE', 'CANCELLED')),
    CONSTRAINT chk_borrow_due_date
        CHECK (due_date >= borrow_date),
    CONSTRAINT chk_borrow_completed_date
        CHECK (completed_date IS NULL OR completed_date >= borrow_date)
);
GO

CREATE INDEX ix_borrow_slips_reader_id
ON dbo.borrow_slips(reader_id);

CREATE INDEX ix_borrow_slips_staff_id
ON dbo.borrow_slips(staff_id);

CREATE INDEX ix_borrow_slips_status
ON dbo.borrow_slips(status);

CREATE INDEX ix_borrow_slips_due_date
ON dbo.borrow_slips(due_date);
GO

-- =============================================================
-- 10. BORROW_DETAILS
-- =============================================================
CREATE TABLE dbo.borrow_details (
    id BIGINT IDENTITY(1,1) NOT NULL,
    borrow_slip_id BIGINT NOT NULL,
    book_copy_id BIGINT NOT NULL,
    returned_date DATE NULL,
    condition_on_borrow VARCHAR(20) NOT NULL,
    condition_on_return VARCHAR(20) NULL,
    status VARCHAR(20) NOT NULL
        CONSTRAINT df_borrow_details_status DEFAULT ('BORROWED'),
    note VARCHAR(500) NULL,
    created_at DATETIME2(6) NOT NULL
        CONSTRAINT df_borrow_details_created_at DEFAULT (SYSDATETIME()),
    updated_at DATETIME2(6) NOT NULL
        CONSTRAINT df_borrow_details_updated_at DEFAULT (SYSDATETIME()),

    CONSTRAINT pk_borrow_details PRIMARY KEY (id),
    CONSTRAINT uq_borrow_detail_copy UNIQUE (borrow_slip_id, book_copy_id),
    CONSTRAINT fk_borrow_details_slip
        FOREIGN KEY (borrow_slip_id)
        REFERENCES dbo.borrow_slips(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_borrow_details_copy
        FOREIGN KEY (book_copy_id)
        REFERENCES dbo.book_copies(id),
    CONSTRAINT chk_borrow_details_condition_borrow
        CHECK (condition_on_borrow IN ('NEW', 'GOOD', 'FAIR', 'POOR')),
    CONSTRAINT chk_borrow_details_condition_return
        CHECK (
            condition_on_return IS NULL
            OR condition_on_return IN ('NEW', 'GOOD', 'FAIR', 'POOR')
        ),
    CONSTRAINT chk_borrow_details_status
        CHECK (status IN ('BORROWED', 'RETURNED', 'LOST', 'DAMAGED'))
);
GO

CREATE INDEX ix_borrow_details_slip_id
ON dbo.borrow_details(borrow_slip_id);

CREATE INDEX ix_borrow_details_copy_id
ON dbo.borrow_details(book_copy_id);

CREATE INDEX ix_borrow_details_status
ON dbo.borrow_details(status);
GO

-- =============================================================
-- 11. FINES
-- =============================================================
CREATE TABLE dbo.fines (
    id BIGINT IDENTITY(1,1) NOT NULL,
    borrow_detail_id BIGINT NOT NULL,
    fine_type VARCHAR(20) NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    reason VARCHAR(500) NULL,
    payment_status VARCHAR(20) NOT NULL
        CONSTRAINT df_fines_payment_status DEFAULT ('UNPAID'),
    paid_date DATETIME2(6) NULL,
    created_at DATETIME2(6) NOT NULL
        CONSTRAINT df_fines_created_at DEFAULT (SYSDATETIME()),
    updated_at DATETIME2(6) NOT NULL
        CONSTRAINT df_fines_updated_at DEFAULT (SYSDATETIME()),

    CONSTRAINT pk_fines PRIMARY KEY (id),
    CONSTRAINT fk_fines_borrow_detail
        FOREIGN KEY (borrow_detail_id)
        REFERENCES dbo.borrow_details(id)
        ON DELETE CASCADE,
    CONSTRAINT chk_fines_type
        CHECK (fine_type IN ('OVERDUE', 'LOST', 'DAMAGED', 'OTHER')),
    CONSTRAINT chk_fines_amount
        CHECK (amount >= 0),
    CONSTRAINT chk_fines_payment_status
        CHECK (payment_status IN ('UNPAID', 'PAID', 'CANCELLED')),
    CONSTRAINT chk_fines_paid_date
        CHECK (
            (payment_status = 'PAID' AND paid_date IS NOT NULL)
            OR payment_status <> 'PAID'
        )
);
GO

CREATE INDEX ix_fines_borrow_detail_id
ON dbo.fines(borrow_detail_id);

CREATE INDEX ix_fines_payment_status
ON dbo.fines(payment_status);
GO

-- =============================================================
-- 12. RESERVATIONS
-- =============================================================
CREATE TABLE dbo.reservations (
    id BIGINT IDENTITY(1,1) NOT NULL,
    reservation_code VARCHAR(30) NOT NULL,
    reader_id BIGINT NOT NULL,
    book_id BIGINT NOT NULL,
    reservation_date DATETIME2(6) NOT NULL
        CONSTRAINT df_reservations_date DEFAULT (SYSDATETIME()),
    expiry_date DATETIME2(6) NULL,
    status VARCHAR(20) NOT NULL
        CONSTRAINT df_reservations_status DEFAULT ('PENDING'),
    note VARCHAR(500) NULL,
    created_at DATETIME2(6) NOT NULL
        CONSTRAINT df_reservations_created_at DEFAULT (SYSDATETIME()),
    updated_at DATETIME2(6) NOT NULL
        CONSTRAINT df_reservations_updated_at DEFAULT (SYSDATETIME()),

    CONSTRAINT pk_reservations PRIMARY KEY (id),
    CONSTRAINT uq_reservations_code UNIQUE (reservation_code),
    CONSTRAINT fk_reservations_reader
        FOREIGN KEY (reader_id)
        REFERENCES dbo.readers(id),
    CONSTRAINT fk_reservations_book
        FOREIGN KEY (book_id)
        REFERENCES dbo.books(id),
    CONSTRAINT chk_reservations_status
        CHECK (
            status IN ('PENDING', 'READY', 'COMPLETED', 'CANCELLED', 'EXPIRED')
        ),
    CONSTRAINT chk_reservation_expiry
        CHECK (expiry_date IS NULL OR expiry_date >= reservation_date)
);
GO

CREATE INDEX ix_reservations_reader_id
ON dbo.reservations(reader_id);

CREATE INDEX ix_reservations_book_id
ON dbo.reservations(book_id);

CREATE INDEX ix_reservations_status
ON dbo.reservations(status);
GO

-- =============================================================
-- SAMPLE DATA
-- Password hashes below are demo strings only.
-- In Spring Boot, use BCrypt before storing real passwords.
-- =============================================================

INSERT INTO dbo.users
    (username, password_hash, full_name, email, phone, role, status)
VALUES
    ('admin', '$2a$10$demo.admin.hash', 'Quản trị viên',
     'admin@library.local', '0900000001', 'ADMIN', 'ACTIVE'),
    ('librarian01', '$2a$10$demo.staff.hash', 'Nguyễn Thị Thủ Thư',
     'staff@library.local', '0900000002', 'LIBRARIAN', 'ACTIVE');
GO

INSERT INTO dbo.readers
    (reader_code, full_name, email, phone, address, date_of_birth,
     registered_date, expired_date, status)
VALUES
    ('DG001', 'Trần Minh Anh', 'minhanh@example.com', '0911000001',
     'TP. Hồ Chí Minh', '2004-03-12', '2026-07-18', '2027-07-18', 'ACTIVE'),
    ('DG002', 'Lê Quốc Bảo', 'quocbao@example.com', '0911000002',
     'Bình Dương', '2003-08-21', '2026-07-18', '2027-07-18', 'ACTIVE'),
    ('DG003', 'Phạm Ngọc Lan', 'ngoclan@example.com', '0911000003',
     'Đồng Nai', '2005-11-05', '2026-07-18', '2027-07-18', 'ACTIVE'),
    ('DG004', 'Võ Thành Đạt', 'thanhdat@example.com', '0911000004',
     'TP. Hồ Chí Minh', '2004-01-30', '2026-07-18', '2027-07-18', 'LOCKED'),
    ('DG005', 'Nguyễn Hoài Nam', 'hoainam@example.com', '0911000005',
     'Long An', '2002-06-17', '2026-07-18', '2027-07-18', 'ACTIVE');
GO

INSERT INTO dbo.categories (name, description)
VALUES
    ('Công nghệ thông tin', 'Sách về lập trình, hệ thống và công nghệ'),
    ('Kinh tế', 'Sách kinh tế và quản trị'),
    ('Văn học', 'Tác phẩm văn học trong và ngoài nước'),
    ('Ngoại ngữ', 'Sách học ngoại ngữ'),
    ('Khoa học', 'Sách khoa học tự nhiên và ứng dụng');
GO

INSERT INTO dbo.publishers (name, address, phone, email)
VALUES
    ('NXB Trẻ', 'TP. Hồ Chí Minh', '0281111111', 'contact@nxbtre.vn'),
    ('NXB Kim Đồng', 'Hà Nội', '0242222222', 'contact@kimdong.vn'),
    ('NXB Thông tin và Truyền thông', 'Hà Nội', '0243333333', 'contact@mic.gov.vn');
GO

INSERT INTO dbo.authors (name, biography, date_of_birth)
VALUES
    ('Robert C. Martin', 'Tác giả nhiều sách về kỹ nghệ phần mềm.', '1952-12-05'),
    ('Joshua Bloch', 'Chuyên gia Java và tác giả Effective Java.', '1961-08-28'),
    ('Nguyễn Nhật Ánh', 'Nhà văn Việt Nam.', '1955-05-07'),
    ('Dale Carnegie', 'Tác giả sách kỹ năng và giao tiếp.', '1888-11-24'),
    ('Eric Freeman', 'Đồng tác giả Head First Design Patterns.', NULL);
GO

INSERT INTO dbo.books
    (isbn, title, category_id, publisher_id, publication_year,
     [language], page_count, description)
VALUES
    ('9780132350884', 'Clean Code', 1, 3, 2008, 'English', 464,
     'Nguyên tắc viết mã sạch.'),
    ('9780134685991', 'Effective Java', 1, 3, 2018, 'English', 416,
     'Thực hành tốt trong Java.'),
    ('9786041123456', 'Tôi thấy hoa vàng trên cỏ xanh', 3, 1, 2010,
     'Vietnamese', 380, 'Tiểu thuyết của Nguyễn Nhật Ánh.'),
    ('9786042234567', 'Đắc nhân tâm', 2, 1, 2019, 'Vietnamese', 320,
     'Sách kỹ năng giao tiếp.'),
    ('9780596007126', 'Head First Design Patterns', 1, 3, 2004,
     'English', 694, 'Các mẫu thiết kế phần mềm.');
GO

INSERT INTO dbo.book_authors (book_id, author_id)
VALUES
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5);
GO

INSERT INTO dbo.book_copies
    (book_id, copy_code, shelf_location, import_date,
     condition_status, availability_status)
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
GO

INSERT INTO dbo.borrow_slips
    (borrow_code, reader_id, staff_id, borrow_date, due_date, status, note)
VALUES
    ('PM001', 1, 2, '2026-07-18', '2026-08-01',
     'BORROWING', 'Phiếu mượn mẫu');
GO

INSERT INTO dbo.borrow_details
    (borrow_slip_id, book_copy_id, condition_on_borrow, status)
VALUES
    (1, 1, 'GOOD', 'BORROWED'),
    (1, 3, 'NEW', 'BORROWED');
GO

UPDATE dbo.book_copies
SET
    availability_status = 'BORROWED',
    updated_at = SYSDATETIME()
WHERE id IN (1, 3);
GO

-- =============================================================
-- VIEWS
-- =============================================================
CREATE OR ALTER VIEW dbo.vw_book_inventory
AS
SELECT
    b.id AS book_id,
    b.isbn,
    b.title,
    COUNT(bc.id) AS total_copies,
    SUM(CASE WHEN bc.availability_status = 'AVAILABLE' THEN 1 ELSE 0 END)
        AS available_copies,
    SUM(CASE WHEN bc.availability_status = 'BORROWED' THEN 1 ELSE 0 END)
        AS borrowed_copies,
    SUM(CASE WHEN bc.availability_status = 'LOST' THEN 1 ELSE 0 END)
        AS lost_copies,
    SUM(CASE WHEN bc.availability_status = 'DAMAGED' THEN 1 ELSE 0 END)
        AS damaged_copies
FROM dbo.books AS b
LEFT JOIN dbo.book_copies AS bc
    ON bc.book_id = b.id
GROUP BY b.id, b.isbn, b.title;
GO

CREATE OR ALTER VIEW dbo.vw_overdue_borrow_details
AS
SELECT
    bs.borrow_code,
    r.reader_code,
    r.full_name AS reader_name,
    b.title AS book_title,
    bc.copy_code,
    bs.borrow_date,
    bs.due_date,
    DATEDIFF(DAY, bs.due_date, CAST(GETDATE() AS DATE)) AS overdue_days
FROM dbo.borrow_details AS bd
JOIN dbo.borrow_slips AS bs
    ON bs.id = bd.borrow_slip_id
JOIN dbo.readers AS r
    ON r.id = bs.reader_id
JOIN dbo.book_copies AS bc
    ON bc.id = bd.book_copy_id
JOIN dbo.books AS b
    ON b.id = bc.book_id
WHERE bd.status = 'BORROWED'
  AND bs.due_date < CAST(GETDATE() AS DATE);
GO

-- =============================================================
-- TEST QUERIES
-- =============================================================

SELECT name
FROM sys.tables
ORDER BY name;
GO

SELECT *
FROM dbo.vw_book_inventory
ORDER BY title;
GO

SELECT *
FROM dbo.vw_overdue_borrow_details
ORDER BY overdue_days DESC;
GO

SELECT TOP (10)
    b.id,
    b.title,
    COUNT(*) AS borrow_count
FROM dbo.borrow_details AS bd
JOIN dbo.book_copies AS bc
    ON bc.id = bd.book_copy_id
JOIN dbo.books AS b
    ON b.id = bc.book_id
GROUP BY b.id, b.title
ORDER BY borrow_count DESC;
GO
