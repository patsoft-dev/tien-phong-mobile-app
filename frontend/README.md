# 📊 Dự án Flutter Qrcode QrcodQrcode, Printer

Tài liệu này hướng dẫn chi tiết cách kiểm tra môi trường, vận hành hệ thống phát triển (Development), đóng gói sản phẩm (Build Production) trên nhiều nền tảng, cũng như cấu hình triển khai thực tế (Web Hosting/iOS).

---

## 🚀 Các lệnh phát triển nhanh (Development Commands)

Các câu lệnh dưới đây được thiết kế tối ưu bằng cách gộp chuỗi (`&&`). Bạn chỉ cần sao chép **một dòng duy nhất** cho nền tảng tương ứng, dán vào Terminal và nhấn `Enter`. Hệ thống sẽ tự động dọn dẹp bộ nhớ đệm, tải thư viện mới và khởi chạy ứng dụng.

### 1. Kiểm tra môi trường Flutter

Trước khi chạy ứng dụng trên bất kỳ thiết bị nào, hãy chạy lệnh này để chắc chắn máy tính của bạn đã cài đặt đủ các công cụ cấu hình (như Xcode, Android SDK, CocoaPods...):

```bash
flutter doctor

2. Nền tảng Android (Thiết bị thật / Máy ảo)
Bash
flutter clean && flutter pub get && flutter run -d android

3. Nền tảng Web (Google Chrome)
Bash
flutter clean && flutter pub get && flutter run -d chrome
Chạy bỏ CORS trên chrome
// flutter run -d chrome --web-browser-flag "--disable-web-security"
4. Nền tảng macOS (Ứng dụng Desktop)
Bash
flutter clean && flutter pub get && flutter run -d macos

5. Nền tảng iOS (Điện thoại iPhone / Máy ảo Simulator)
Bash
flutter clean && flutter pub get && cd ios && pod install && cd .. && flutter run -d ios

6. Nền tảng Windows (Ứng dụng Desktop)
Bash
flutter clean && flutter pub get && flutter run -d windows

Đóng gói phiên bản Web (Đưa lên aaPanel Hosting / Vercel):

##Các lệnh đóng gói sản phẩm (Build Production)
1. Đóng gói phiên bản Web (Đưa lên aaPanel Hosting / Vercel):
Bash
flutter build web --release

2. Đóng gói phiên bản Android (File APK cài đặt trực tiếp):
Bash
flutter build apk --release

3. Đóng gói phiên bản iOS (Đưa lên TestFlight / App Store):
Bash
flutter build ios --release

Lệnh đổi tên dự án sau khi clone
flutter pub global run rename setAppName --value "TienPhongApp"

Đổi tên Package ID / Bundle ID (Đổi tên thư mục Xcode /ios)
flutter pub global run rename setBundleId --value "com.tienphong.qcmobileapp"

Lệnh đổi toàn bộ logo, icon app từ file /assets/logo_ps.png
flutter pub run flutter_launcher_icons //Xem ở cuối trang pubspec.yaml


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

```
