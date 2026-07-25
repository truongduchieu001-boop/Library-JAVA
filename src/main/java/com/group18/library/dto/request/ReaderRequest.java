package com.group18.library.dto.request;

import com.group18.library.entity.enums.ReaderStatus;
import jakarta.validation.constraints.*;

import java.time.LocalDate;

public record ReaderRequest(
    @NotBlank(message = "Mã độc giả không được để trống")
    @Size(max = 30, message = "Mã độc giả tối đa 30 ký tự")
    String readerCode,

    @NotBlank(message = "Họ tên không được để trống")
    @Size(max = 150, message = "Họ tên tối đa 150 ký tự")
    String fullName,

    @Email(message = "Email không đúng định dạng")
    @Size(max = 150, message = "Email tối đa 150 ký tự")
    String email,

    @Size(max = 20, message = "Số điện thoại tối đa 20 ký tự")
    String phone,

    @Size(max = 255, message = "Địa chỉ tối đa 255 ký tự")
    String address,

    @Past(message = "Ngày sinh phải nhỏ hơn ngày hiện tại")
    LocalDate dateOfBirth,

    @NotNull(message = "Ngày đăng ký không được để trống")
    LocalDate registeredDate,

    LocalDate expiredDate,

    @NotNull(message = "Trạng thái không được để trống")
    ReaderStatus status
) {}
