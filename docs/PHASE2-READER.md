# Phase 2 - Module Reader

Module `Reader` đã được bổ sung theo kiến trúc phân lớp:

```text
ReaderController
    -> ReaderService / ReaderServiceImpl
        -> ReaderRepository
            -> SQL Server 2022
```

## API

```text
POST   /api/readers
GET    /api/readers
GET    /api/readers/{id}
PUT    /api/readers/{id}
DELETE /api/readers/{id}
```

## Tìm kiếm và phân trang

```text
GET /api/readers?keyword=Nguyen&page=0&size=10&sort=fullName,asc
```

## JSON mẫu

```json
{
  "readerCode": "DG006",
  "fullName": "Nguyen Van An",
  "email": "an@example.com",
  "phone": "0901234567",
  "address": "Ho Chi Minh City",
  "dateOfBirth": "2005-08-15",
  "registeredDate": "2026-07-25",
  "expiredDate": "2027-07-25",
  "status": "ACTIVE"
}
```

Các trạng thái hợp lệ:

```text
ACTIVE
LOCKED
EXPIRED
```
