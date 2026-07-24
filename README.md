# HỆ THỐNG QUẢN LÝ THƯ VIỆN – NHÓM 18

## 1. Giới thiệu đề tài

Đây là dự án cuối kỳ học phần **Lập trình ứng dụng với Java**. Nhóm xây dựng hệ thống quản lý thư viện bằng **Spring Boot RESTful API** và **MySQL** theo kiến trúc phân lớp.

Hệ thống hướng đến việc hỗ trợ thư viện quản lý đầu sách, bản sao sách, độc giả, nhân viên, phiếu mượn – trả, tiền phạt và đặt trước sách.

## 2. Chức năng dự kiến

- Quản lý sách, tác giả, thể loại và nhà xuất bản.
- Quản lý từng bản sao vật lý của sách.
- Quản lý độc giả và nhân viên thư viện.
- Lập phiếu mượn và xử lý trả sách.
- Theo dõi sách đang mượn và sách quá hạn.
- Quản lý tiền phạt do quá hạn, mất hoặc hỏng sách.
- Đặt trước sách.
- Tìm kiếm, phân trang và sắp xếp dữ liệu.
- Tài liệu REST API bằng Swagger/OpenAPI.

## 3. Công nghệ sử dụng

- Java 21
- Spring Boot
- Spring Web
- Spring Data JPA
- Bean Validation
- MySQL 8+
- Maven
- Lombok
- Springdoc OpenAPI / Swagger
- Docker Compose

## 4. Kiến trúc dự án

Dự án áp dụng **Layered Architecture**:

```text
Client / Frontend / Postman / Swagger
                   |
                   v
              Controller
                   |
                   v
                Service
                   |
                   v
              Repository
                   |
                   v
            MySQL Database
```

Vai trò các package:

```text
controller : Nhận HTTP request và trả HTTP response
service    : Xử lý nghiệp vụ và transaction
repository : Truy cập dữ liệu bằng Spring Data JPA
entity     : Ánh xạ đối tượng Java với bảng trong MySQL
dto        : Dữ liệu request và response của API
mapper     : Chuyển đổi giữa Entity và DTO
exception  : Xử lý lỗi tập trung
config     : Cấu hình Swagger và các thành phần dùng chung
```

## 5. Cấu trúc thư mục

```text
Library-cuoi-ky-JAVA/
├── README.md
├── pom.xml
├── Dockerfile
├── docker-compose.yml
├── .gitignore
├── database/
│   └── library_management_group18.sql
├── docs/
│   ├── README.md
│   ├── erd-guide.md
│   └── architecture-guide.md
└── src/
    ├── main/
    │   ├── java/com/group18/library/
    │   │   ├── config/
    │   │   ├── controller/
    │   │   ├── dto/
    │   │   ├── entity/
    │   │   ├── exception/
    │   │   ├── mapper/
    │   │   ├── repository/
    │   │   ├── service/
    │   │   └── LibraryApplication.java
    │   └── resources/
    └── test/
```

## 6. Cơ sở dữ liệu

File tạo cơ sở dữ liệu:

```text
database/library_management_group18.sql
```

Các bảng:

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

Quan hệ chính:

```text
categories    1 ----- N books
publishers    1 ----- N books
books         N ----- N authors       (qua book_authors)
books         1 ----- N book_copies
readers       1 ----- N borrow_slips
users         1 ----- N borrow_slips
borrow_slips  1 ----- N borrow_details
book_copies   1 ----- N borrow_details
borrow_details 1 ---- N fines
readers       1 ----- N reservations
books         1 ----- N reservations
```

## 7. Chạy MySQL bằng Docker

Tại thư mục chứa `docker-compose.yml`, chạy:

```bash
docker compose up -d mysql
```

Thông tin kết nối mặc định:

```text
Host: localhost
Port: 3307
Database: library_management
Username: library_user
Password: library_password
```

Kiểm tra container:

```bash
docker compose ps
```

## 8. Chạy Spring Boot

Yêu cầu máy đã cài Java 21 và Maven.

```bash
mvn spring-boot:run
```

Swagger UI:

```text
http://localhost:8080/swagger-ui.html
```

API lấy danh sách sách:

```text
GET http://localhost:8080/api/books
```

## 9. API đã có trong source khung

```text
POST   /api/books
GET    /api/books
GET    /api/books/{id}
PUT    /api/books/{id}
DELETE /api/books/{id}
```

API danh sách hỗ trợ tìm kiếm và phân trang:

```text
GET /api/books?keyword=Java&page=0&size=10&sort=title,asc
```

## 10. Trạng thái hiện tại

Đã hoàn thành cho Phase 1:

- Database schema và dữ liệu mẫu.
- Source Spring Boot đặt đúng tại thư mục gốc repository.
- Kiến trúc Controller – Service – Repository.
- Entity, DTO, Mapper, Validation và Global Exception Handler.
- CRUD REST API mẫu cho `Book`.
- Swagger/OpenAPI.
- Docker Compose cho MySQL.

Đang phát triển:

- CRUD Category, Author, Publisher và BookCopy.
- Quản lý Reader và User.
- Nghiệp vụ Borrow/Return dùng `@Transactional`.
- Fine, Reservation và phân quyền.
- Kiểm thử và giao diện.

## 11. Sơ đồ Draw.io

Hướng dẫn vẽ ERD và sơ đồ kiến trúc nằm trong thư mục `docs`.

Sau khi vẽ, lưu thêm các file:

```text
docs/erd-library.drawio
docs/erd-library.png
docs/architecture.drawio
docs/architecture.png
```

## 12. Thành viên nhóm

| STT | Họ và tên | MSSV | Công việc |
|---:|---|---|---|
| 1 | Cập nhật sau | Cập nhật sau | Database và Entity |
| 2 | Cập nhật sau | Cập nhật sau | Service và REST API |
| 3 | Cập nhật sau | Cập nhật sau | Kiểm thử, tài liệu và báo cáo |
