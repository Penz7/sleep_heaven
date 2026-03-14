# IAP Setup Guide – Sleep Heaven

Hướng dẫn này dành cho developer thực hiện các tác vụ **ngoài code** để tích hợp IAP non-consumable hoạt động trên cả hai store. Tất cả thay đổi code đã được implement sẵn.

---

## Mục lục

1. [Android – Google Play Console](#android--google-play-console)
2. [iOS – App Store Connect & Xcode](#ios--app-store-connect--xcode)
3. [Đổi App ID](#đổi-app-id)
4. [Android – Signing Release Build](#android--signing-release-build)
5. [Test Sandbox](#test-sandbox)
6. [Deploy lên Store](#deploy-lên-store)
7. [Deadlines quan trọng 2026](#deadlines-quan-trọng-2026)

---

## Android – Google Play Console

### 1. Tạo app

1. Vào [play.google.com/console](https://play.google.com/console)
2. **Create app** → chọn App, Free, khai báo nội dung

### 2. Tạo sản phẩm IAP

1. **Monetize → Products → In-app products → Create product**
2. Product ID: `premium_unlock` ← **phải khớp chính xác với code**
3. Type: **Managed product (non-consumable)**
4. Đặt giá, Status: **Active**

### 3. Upload AAB lên Internal Testing (bắt buộc trước khi test IAP)

Google Play Billing chỉ hoạt động khi app đã được upload lên store track. Build bằng:

```bash
fvm flutter build appbundle --release
```

Sau đó upload file `.aab` lên **Internal Testing track**.

### 4. Thêm License Test Account

**Setup → License testing** → Add email tài khoản Google dùng để test. Account này sẽ không bị tính tiền thật khi mua IAP.

---

## iOS – App Store Connect & Xcode

### 1. Tạo app trên App Store Connect

1. Vào [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. **My Apps → "+" → New App**
3. Điền Bundle ID khớp với Xcode project

### 2. Tạo sản phẩm IAP

1. **Features → In-App Purchases → "+" → Non-Consumable**
2. Reference name: `Premium Unlock`
3. Product ID: `premium_unlock` ← **phải khớp chính xác với code**
4. Thêm screenshot + review notes (bắt buộc để submit review)

### 3. Ký Paid Applications Agreement

**Agreements → Paid Applications** → Ký + điền đầy đủ bank/tax info. Nếu chưa ký, IAP sẽ không hoạt động dù code đúng.

### 4. Thêm In-App Purchase capability trong Xcode

File `Runner.entitlements` đã được tạo sẵn trong code. Cần link trong Xcode:

**Cách 1 – Tự động (khuyên dùng):**
1. Mở Xcode → chọn **Runner target**
2. Tab **Signing & Capabilities → "+ Capability" → In-App Purchase**
3. Xcode tự link entitlements

**Cách 2 – Thủ công (nếu Cách 1 bị lỗi):**
1. Runner target → **Build Settings** → tìm `CODE_SIGN_ENTITLEMENTS`
2. Set giá trị: `Runner/Runner.entitlements`

> File `Runner.entitlements` đã có sẵn tại `ios/Runner/Runner.entitlements` và đã được link trong `project.pbxproj`.

### 5. Thêm Sandbox Tester

**Users & Access → Sandbox Testers → "+"** → Thêm email mới (khác Apple ID thật) dùng để test IAP mà không tốn tiền.

---

## Đổi App ID

**Đã áp dụng trong project:** App ID **`dat.c.sleepheaven`** (Android `namespace`/`applicationId`, iOS/macOS Bundle Identifier, Linux `APPLICATION_ID`, package `dat.c.sleepheaven`). Nếu cần đổi sang ID khác, làm ngược lại các bước dưới.

### Android

1. **`android/app/build.gradle.kts`** – đổi 2 dòng:
   ```kotlin
   namespace = "dat.c.sleepheaven"
   applicationId = "dat.c.sleepheaven"
   ```

2. **Rename package folder** (theo từng phần của package name):
   ```
   android/app/src/main/kotlin/com/example/sleep_heaven/
   → android/app/src/main/kotlin/dat/c/sleepheaven/
   ```

3. **`MainActivity.kt`** – đổi dòng đầu:
   ```kotlin
   package dat.c.sleepheaven
   ```

4. **`AndroidManifest.xml`** – thay test AdMob ID bằng ID thật:
   ```xml
   <meta-data
       android:name="com.google.android.gms.ads.APPLICATION_ID"
       android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX" />
   ```

### iOS

1. Mở Xcode → **Runner target → General → Bundle Identifier**
2. Đổi thành ID thật, ví dụ: `dat.c.sleepheaven`
3. **`ios/Runner/Info.plist`** – thay test AdMob ID bằng ID thật:
   ```xml
   <key>GADApplicationIdentifier</key>
   <string>ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX</string>
   ```

---

## Android – Signing Release Build

### Bước 1: Tạo Keystore

```bash
keytool -genkey -v -keystore ~/keys/sleep_heaven.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias sleep_heaven
```

> **Lưu file `.jks` ở nơi an toàn, KHÔNG commit vào git.**

### Bước 2: Tạo `android/key.properties`

```properties
storePassword=<mật khẩu keystore>
keyPassword=<mật khẩu key>
keyAlias=sleep_heaven
storeFile=<đường dẫn tuyệt đối đến file .jks>
```

File này đã được gitignore (`.gitignore` của Flutter bao gồm `key.properties`).

### Bước 3: Build release

```bash
fvm flutter build appbundle --release
```

---

## Test Sandbox

### Android

- Dùng **license test account** (thêm ở bước Google Play Console)
- Test trên device thật cài AAB từ **Internal Testing track**
- IAP không hoạt động trên emulator không có Google Play

### iOS

- Đăng xuất Apple ID thật trên device/simulator
- Đăng nhập bằng **Sandbox Tester account**
- Test trên device thật hoặc simulator (iOS 13+)
- Test restore: Xóa app → reinstall → đăng nhập Sandbox Tester → mở app

### Test offline

1. Mua thành công khi có mạng
2. Bật Airplane mode
3. Mở lại app → premium vẫn unlock (từ `flutter_secure_storage` cache)

---

## Deploy lên Store

### Android

```
Internal Testing → Closed Testing (Alpha/Beta) → Open Testing → Production
```

Mỗi bước cần review và approve trước khi promote.

### iOS

1. Build archive: `fvm flutter build ipa --release`
2. Upload lên App Store Connect qua Xcode Organizer hoặc Transporter
3. Submit for App Review
4. **Bắt buộc:** Kèm screenshot của màn hình IAP khi submit review
5. **Nút "Restore Purchases" đã có sẵn trong `PremiumView`** ✓ (Apple guideline yêu cầu)

---

## Deadlines quan trọng 2026

| Deadline | Yêu cầu | Hành động |
|----------|---------|-----------|
| 31/8/2025 (đã qua) | Google Play: new apps phải target API 35+ | ✅ Đã fix (`targetSdk = 35`) |
| **28/4/2026** | Apple: phải build bằng **iOS 26 SDK (Xcode 17+)** | Cập nhật Xcode lên phiên bản 17+ trước ngày này |
| ~Q3 2026 (dự kiến) | Google Play: new apps phải target API 36+ | Nâng `targetSdk = 36` khi Android 16 requirement có hiệu lực |

> **Lưu ý:** Yêu cầu iOS 26 SDK (28/4/2026) chỉ ảnh hưởng đến **Xcode version dùng để build/archive**, không ảnh hưởng `IPHONEOS_DEPLOYMENT_TARGET`. App vẫn chạy được trên iOS 13+.
