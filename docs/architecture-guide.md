# Hướng dẫn vẽ sơ đồ kiến trúc

Vẽ các khối theo chiều từ trên xuống:

```text
Client / Frontend / Postman / Swagger
                   |
                   v
Controller - nhận request, kiểm tra DTO
                   |
                   v
Service - xử lý nghiệp vụ, transaction
                   |
                   v
Repository - Spring Data JPA
                   |
                   v
MySQL Database
```

Các thành phần phụ:

```text
Request DTO  ---> Controller
Response DTO <--- Controller
Mapper       <--> Service
Entity       <--> Service và Repository
Validation  ---> Request DTO
GlobalExceptionHandler <--- lỗi từ Controller và Service
OpenAPI/Swagger ---> Controller
```

Các package nên thể hiện trong sơ đồ:

```text
config
controller
dto
entity
exception
mapper
repository
service
```
