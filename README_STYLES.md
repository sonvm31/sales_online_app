#  Hướng Dẫn Sử Dụng Hệ Thống Styles Dùng Chung (App Styles)

Để đảm bảo giao diện ứng dụng đồng bộ, dễ bảo trì và hỗ trợ tốt **Light/Dark Mode**, toàn bộ dự án sẽ tuân thủ hệ thống quy chuẩn được định nghĩa tại file:
 **`lib/core/theme/app_styles.dart`**

Tuyệt đối **không gán cứng (hardcode)** mã màu ngẫu nhiên hoặc kích thước (FontSize, Padding, BorderRadius) trong quá trình code UI.

---

## 1. Hệ Thống Màu Sắc (`AppColors`)

Khi sử dụng màu sắc, hãy phân biệt rõ các màu hệ thống (Primary, Placeholder) và các màu phụ thuộc vào Giao diện Sáng/Tối.

* **Màu chủ đạo:** `AppColors.primary` (Xanh dương `#2F76F6`)
* **Placeholder đặc biệt:** `AppColors.whitePlaceholder`

###  Giao diện Sáng (Light Mode)
* Nền ứng dụng: `AppColors.backgroundLight`
* Nền Card/Bề mặt: `AppColors.surfaceLight`
* Chữ chính: `AppColors.textDark`
* Chữ phụ/Mờ: `AppColors.textMutedLight`
* Đường viền: `AppColors.borderLight`

###  Giao diện Tối (Dark Mode)
* Nền ứng dụng: `AppColors.backgroundDark`
* Nền Card/Bề mặt: `AppColors.surfaceDark`
* Chữ chính: `AppColors.textLight`
* Chữ phụ/Mờ: `AppColors.textMutedDark`
* Đường viền: `AppColors.borderDark`

---

## 2. Khoảng Cách và Bo Góc (`AppSpacing` & `AppRadius`)

### Khoảng cách (Spacing / Padding / Margin)
Thay vì gõ số tự do, hãy sử dụng các hằng số hoặc `SizedBox` được định nghĩa sẵn để các khoảng cách trên UI đồng đều:
* `AppSpacing.xs` (4.0) | `AppSpacing.sm` (8.0) | `AppSpacing.md` (16.0) | `AppSpacing.lg` (24.0)
* **Tiện ích khoảng cách nhanh (SizedBox):** `AppSpacing.h4`, `AppSpacing.h8`, `AppSpacing.h16`, `AppSpacing.w4`, `AppSpacing.w8`, `AppSpacing.w16`...

### Bo góc (Border Radius)
* `AppRadius.small` (Bo nhẹ - 4.0)
* `AppRadius.medium` (Mặc định cho Card/Button - 8.0)
* `AppRadius.large` (Bo tròn nhiều - 12.0)
* `AppRadius.circular` (Hình tròn - 99.0)

---

## 3. Kiểu Chữ (`AppTextStyles`)

Các kiểu chữ đã được cấu hình sẵn kích thước (`fontSize`) và độ đậm (`fontWeight`).
>  **Lưu ý quan trọng:** Không gán cứng màu chữ trong `AppTextStyles` để chữ tự động đổi màu theo Light/Dark Theme của hệ thống. Nếu muốn tùy biến màu riêng biệt, sử dụng hàm `.copyWith()`.

* `AppTextStyles.display` (Size 32, Bold)
* `AppTextStyles.headingLarge` (Size 24, Bold)
* `AppTextStyles.headingMedium` (Size 20, SemiBold)
* `AppTextStyles.bodyLarge` (Size 16, Regular)
* `AppTextStyles.bodyMedium` (Size 14, Regular)
* `AppTextStyles.caption` (Size 12, Regular)

---
