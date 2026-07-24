# HỆ THỐNG QUẢN LÝ THƯ VIỆN – NHÓM 18

## 1. Giới thiệu đề tài

Đây là dự án cuối kỳ học phần **Lập trình ứng dụng với Java**. Nhóm xây dựng hệ thống quản lý thư viện bằng **Spring Boot RESTful API** và **Microsoft SQL Server 2022** theo kiến trúc phân lớp.

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
- Microsoft JDBC Driver for SQL Server
- Bean Validation
- Microsoft SQL Server 2022
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
            SQL Server Database
```

Vai trò các package:

```text
controller : Nhận HTTP request và trả HTTP response
service    : Xử lý nghiệp vụ và transaction
repository : Truy cập dữ liệu bằng Spring Data JPA
entity     : Ánh xạ đối tượng Java với bảng trong SQL Server
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
│   └── library_management_sqlserver2022.sql
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
database/library_management_sqlserver2022.sql
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

## 7. Khởi tạo SQL Server 2022

### Cách 1: Chạy bằng SQL Server Management Studio

1. Mở **SQL Server Management Studio 2022**.
2. Kết nối vào SQL Server bằng Windows Authentication hoặc SQL Server Authentication.
3. Chọn **File → Open → File**.
4. Mở file:

```text
database/library_management_sqlserver2022.sql
```

5. Nhấn **Ctrl + A**, sau đó nhấn **F5** để chạy toàn bộ script.

Kiểm tra database:

```sql
USE library_management;
GO

SELECT name
FROM sys.tables
ORDER BY name;
GO
```

### Cách 2: Chạy SQL Server bằng Docker

Tại thư mục chứa `docker-compose.yml`, chạy:

```bash
docker compose up -d sqlserver
```

Kiểm tra container:

```bash
docker compose ps
```

Thông tin kết nối phụ thuộc vào cấu hình trong `docker-compose.yml`. Cấu hình Spring Boot được đặt tại:

```text
src/main/resources/application-dev.properties
```

Ví dụ kết nối SQL Server:

```properties
spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=library_management;encrypt=true;trustServerCertificate=true
spring.datasource.username=sa
spring.datasource.password=YOUR_SQL_SERVER_PASSWORD
```

## 8. Chạy Spring Boot

Yêu cầu máy đã cài Java 21, Maven và SQL Server 2022.

Trước khi chạy, mở file:

```text
src/main/resources/application-dev.properties
```

Cập nhật tài khoản và mật khẩu SQL Server:

```properties
spring.datasource.username=sa
spring.datasource.password=MAT_KHAU_SQL_SERVER
```

Sau đó chạy:

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
- Docker Compose cho SQL Server 2022.

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
