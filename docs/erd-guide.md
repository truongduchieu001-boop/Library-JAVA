# Hướng dẫn vẽ ERD

## Danh sách bảng

```text
users
readers
categories
publishers
authors
books
book_authors
book_copies
borrow_slips
borrow_details
fines
reservations
```

## Quan hệ

```text
categories     1 ----- N books
publishers     1 ----- N books
books          1 ----- N book_authors
many authors   1 ----- N book_authors
books          1 ----- N book_copies
readers        1 ----- N borrow_slips
users          1 ----- N borrow_slips
borrow_slips   1 ----- N borrow_details
book_copies    1 ----- N borrow_details
borrow_details 1 ----- N fines
readers        1 ----- N reservations
books          1 ----- N reservations
```

Lưu ý: `books` và `authors` có quan hệ N–N thông qua bảng trung gian `book_authors`.

## Ký hiệu

```text
PK: Primary Key
FK: Foreign Key
UQ: Unique
NN: Not Null
```

Tên cột, kiểu dữ liệu và khóa ngoại lấy trực tiếp từ file:

```text
database/library_management_sqlserver2022.sql
```
