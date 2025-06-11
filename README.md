<<<<<<< HEAD
# breakshotapp
=======
# BreakShot Billiard House App
>>>>>>> a67087b (commit malem)

Aplikasi Flutter modern untuk rumah billiard, dengan dua peran utama: Customer dan Pengusaha. Dirancang dengan UI/UX kekinian, modular, dan mudah dikembangkan.

---

## Fitur Utama

### Untuk Customer
- **Dashboard Home**: Info saldo, kata penyemangat, dan konversi mata uang.
- **Shop**: Belanja barang, tambah ke keranjang, checkout, dan top up saldo.
- **Map**: Lihat lokasi rumah billiard, marker interaktif, fitur "Kunjungi" (arah ke marker), dan polyline jalur ke tujuan.
- **Profile**: Lihat profil, logout, tampilkan password.

### Untuk Pengusaha
- **Dashboard**: Statistik transaksi, barang terjual, dan pendapatan.
- **Inventory**: Kelola barang (tambah, edit, hapus) dengan gambar.
- **Order History**: Lihat riwayat pesanan.
- **Profile**: Lihat profil dan logout.

---

## Struktur Folder
- `lib/`
  - `main.dart` : Entry point aplikasi, setup theme, dan routing.
  - `home.dart` : Logic & state utama customer.
  - `ui.dart` : Semua widget tree UI customer (modular, clean separation).
  - `map.dart` : Komponen peta, marker interaktif, polyline jalur.
  - `homepengusaha.dart` : Logic & UI dashboard pengusaha.
  - `login.dart`, `register.dart`, `profile.dart` : Autentikasi & profil.
  - `widgets/` : Komponen UI modular (HomeContent, ShopDashboard, dsb).
  - `models/` : Model data (InventoryItem, Order, User, dsb).
  - `services/` : Service untuk Firestore, user, inventory, order.
  - `utils/` : Helper & utilitas (format, konversi, dsb).

---

## Teknologi
- **Flutter** (Material 3, Google Fonts, Responsive UI)
- **Firebase** (Firestore, Auth)
- **flutter_map** (OpenStreetMap)
- **SharedPreferences** (state lokal)

---

## Catatan Developer
- Semua UI utama customer sudah dipisah ke `ui.dart` (best practice separation).
- Komentar warna sudah diterapkan di seluruh file agar mudah customisasi.
- Marker map dan notifikasi "nearest" sudah sinkron.
- Untuk routing jalan sebenarnya di map, bisa integrasi OpenRouteService/Google Directions API.
- Untuk web, state tab terakhir bisa disimpan di localStorage agar user tetap di tab yang sama setelah refresh.

---

## Cara Menjalankan
1. Pastikan sudah install Flutter & dependencies (`flutter pub get`).
2. Jalankan di device/emulator/web:
   ```sh
   flutter run
   ```
3. Untuk web, buka di Chrome/Edge/Firefox.

---

## Kontribusi & Lisensi
- Silakan fork, modifikasi, dan kembangkan sesuai kebutuhan.
- Lisensi: MIT (bebas digunakan, mohon tetap cantumkan kredit jika open source).

---

## Kontak
- Developer: [Nama Kamu]
- Email: [email@email.com]
- WhatsApp: [nomor kamu]

---

> "Break your limit!" — BreakShot Team
