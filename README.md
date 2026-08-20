# Tạp hóa App — Khung dự án Flutter

## Cách chạy
```
flutter pub get
flutter run
```

## Cấu trúc thư mục
```
lib/
  core/theme/          # Bảng màu (app_colors.dart) và ThemeData (app_theme.dart)
  models/               # Product, Customer, Invoice — khớp với schema CSDL
  data/
    services/            # database_service.dart — khởi tạo SQLite, tạo bảng
    repositories/        # (sẽ thêm) nơi viết hàm CRUD: thêm/sửa/xóa/truy vấn
  screens/
    pos/                 # Bán hàng
    products/            # Danh sách & quản lý sản phẩm
    customers/           # Khách hàng & công nợ
    invoices/            # Lịch sử hóa đơn (chưa có màn hình, sẽ thêm sau)
    dashboard/           # Tổng quan
  widgets/              # Component dùng chung (nút, thẻ sản phẩm, ô nhập liệu...)
  main.dart             # Điều hướng chính (thanh tab dưới cùng)
```

## Kiến trúc dữ liệu: Mock → Local → Firebase
App được thiết kế để sau này chạy **song song Local (SQLite) + Firebase**
(offline-first, tự đồng bộ khi có mạng), nhưng bước hiện tại **chưa nối
CSDL thật** — chỉ dùng dữ liệu giả (Mock) để dựng và chạy thử giao diện.

```
lib/data/repositories/
  product_repository.dart      # interface (hợp đồng) — màn hình chỉ biết cái này
  customer_repository.dart
  invoice_repository.dart
  mock/                        # ĐANG DÙNG — dữ liệu giả trong bộ nhớ
    mock_product_repository.dart
    mock_customer_repository.dart
    mock_invoice_repository.dart
  local/                       # (trống, làm sau) — cài đặt bằng SQLite
  firebase/                    # (trống, làm sau) — cài đặt bằng Firestore
```

**Cách hoạt động:** màn hình (`ProductListScreen`...) chỉ gọi các hàm khai
báo trong `product_repository.dart` (ví dụ `getAll()`, `decreaseStock()`),
không biết dữ liệu đến từ đâu. Nơi "cắm" nguồn dữ liệu thật là ở
`lib/main.dart`, trong khối `MultiProvider` — hiện đang trỏ vào Mock.

**Khi sẵn sàng dùng CSDL thật**, chỉ cần:
1. Viết `local/local_product_repository.dart` implement `ProductRepository`,
   dùng lại `database_service.dart` đã có sẵn schema (không đổi gì ở đây).
2. Viết `firebase/firebase_product_repository.dart` implement tương tự,
   dùng Firestore (cần chạy `flutterfire configure` trước).
3. (Tùy chọn) viết `HybridProductRepository` — đọc/ghi Local trước, đồng
   bộ lên Firebase khi có mạng (dùng gói `connectivity_plus` đã khai báo
   sẵn trong `pubspec.yaml`).
4. Đổi 1 dòng trong `main.dart`: `MockProductRepository()` →
   `HybridProductRepository(...)`. Không sửa bất kỳ màn hình nào.

## Trạng thái hiện tại — đã hoàn thành Giai đoạn 1 (cốt lõi)
- Bán hàng (POS): chọn sản phẩm (khóa khi hết hàng), giỏ hàng, chọn/thêm
  khách hàng, thanh toán tiền mặt hoặc ghi nợ, tự trừ tồn kho + cộng công nợ.
- Quản lý sản phẩm: danh sách (tìm kiếm, sắp theo tồn kho thấp), thêm/sửa,
  ngừng bán.
- Nhập thêm hàng vào kho (`stock_in_screen.dart`) — cộng dồn tồn kho, không
  tạo sản phẩm trùng.
- Khách hàng: danh sách (tổng công nợ, sắp theo nợ nhiều nhất), thêm mới,
  chi tiết (công nợ, ghi nhận trả nợ, lịch sử hóa đơn của khách đó).
- Lịch sử hóa đơn tổng (`invoice_list_screen.dart`) — lọc theo trạng thái
  đã trả / còn nợ, xem chi tiết từng hóa đơn.
- Tổng quan (Dashboard) — doanh thu hôm nay, tổng công nợ, số hóa đơn hôm
  nay, cảnh báo sản phẩm sắp hết hàng (tồn kho ≤ 5), lối tắt sang Nhập hàng
  và Lịch sử hóa đơn.

Toàn bộ đang chạy trên **dữ liệu Mock** (bộ nhớ tạm) — đúng như kiến trúc
đã thống nhất, sẵn sàng đổi sang Local/Firebase mà không cần sửa màn hình.

## Đã hoàn thành Giai đoạn 2
- Kiểm kho (`stock_audit_screen.dart`) — nhập số đếm thực tế cho từng sản
  phẩm, tự tính chênh lệch so với sổ sách, xác nhận để điều chỉnh lại tồn kho.
- Báo cáo doanh thu & lời lỗ (`report_screen.dart`) — lọc theo Hôm nay / 7
  ngày qua / Tháng này, tính lợi nhuận ước tính (giá bán − giá nhập hiện
  tại) × số lượng, top 5 sản phẩm bán chạy trong kỳ.
- Cả hai đều truy cập nhanh từ Dashboard qua khu "Thao tác nhanh".

## Đã hoàn thành Giai đoạn 3 — Đăng nhập & phân quyền
- Màn Đăng nhập chặn trước khi vào app. Tài khoản mặc định: `admin` / `admin123`.
- 2 vai trò: **Chủ tiệm (admin)** toàn quyền, **Nhân viên (staff)** giới hạn:
  - Nhân viên KHÔNG thấy tab "Tổng quan" (doanh thu, báo cáo, kiểm kho).
  - Nhân viên KHÔNG thấy/sửa được giá nhập (giá vốn) sản phẩm, cũng không
    thêm/sửa/ngừng bán sản phẩm — chỉ xem danh sách.
  - Nhân viên vẫn bán hàng, ghi nợ, thêm khách hàng bình thường.
  - Mỗi hóa đơn lưu lại `createdByUserId`/`createdByName` — biết ai đã bán.
- Màn "Cài đặt" (`settings_screen.dart`) — chủ tiệm thấy thêm mục "Quản lý
  tài khoản nhân viên" (thêm/xóa tài khoản), có nút Đăng xuất.

## Chưa làm
- Form thông tin tiệm để in hóa đơn, mẫu in, sao lưu dữ liệu (đang TODO
  trong `settings_screen.dart`).
- Quét mã vạch thật (đã có nút giao diện + thư viện `mobile_scanner` trong
  pubspec, nhưng chưa nối logic quét).

## Cách đổi mật khẩu / thêm tài khoản khi thử app
Vào Cài đặt → "Quản lý tài khoản nhân viên" (chỉ chủ tiệm thấy mục này) để
thêm tài khoản nhân viên mới. Mật khẩu tài khoản `admin` hiện hardcode
trong `mock_user_repository.dart` — đổi trực tiếp trong file này khi cần.

## Bảng màu (xem chi tiết ở `lib/core/theme/app_colors.dart`)
- Primary (xanh lá): #1D9E75 — thương hiệu, nút chính
- Accent (cam): #EF9F27 — giá tiền, điểm nhấn
- Success / Warning / Danger — dùng cho trạng thái thanh toán, công nợ, tồn kho

## Bước tiếp theo gợi ý
1. Viết `repositories/product_repository.dart` — hàm CRUD sản phẩm nối với `database_service.dart`
2. Ghép giao diện thật vào `pos_screen.dart` (thanh tìm kiếm + lưới sản phẩm)
3. Làm tương tự cho các màn còn lại
# grocery_app
