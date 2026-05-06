# 💰 Saldoku - Financial Management App

Saldoku adalah aplikasi manajemen keuangan pribadi yang dirancang dengan estetika modern **Glassmorphism**. Aplikasi ini membantu pengguna mencatat pendapatan, pengeluaran, serta menganalisis kesehatan finansial secara real-time.

## 🚀 Fitur Utama

### 1. Dashboard Interaktif
- **Ringkasan Saldo**: Menampilkan total pemasukan dan pengeluaran secara akumulatif.
- **Monthly Summary**: Ringkasan otomatis pendapatan dan pengeluaran khusus bulan berjalan.
- **Quick Actions**: Akses cepat ke fitur kalkulator, tabungan, dan split bill.

### 2. Statistik & Analisis Finansial
- **Financial Health Score**: Skor kesehatan keuangan (0-100) yang dihitung berdasarkan rasio pengeluaran vs pendapatan.
- **Distribusi Keuangan**: Visualisasi perbandingan antara uang masuk dan uang keluar.
- **Cash Flow Analysis**: Analisis sisa anggaran dan kapasitas menabung bulanan.

### 3. Pencatatan Transaksi
- **Input Transaksi**: Form pencatatan yang mudah dengan kategori ikonik (Gaji, Makanan, Belanja, dll).
- **Notes & Struk**: Fitur khusus untuk mencatat pengeluaran dengan lampiran foto struk menggunakan kamera atau galeri.
- **Riwayat Transaksi**: Daftar lengkap transaksi yang bisa dikelola (view & delete).

### 4. Fitur Andalan Lainnya
- **Calculator**: Kalkulator terintegrasi untuk perhitungan cepat.
- **Split Bill**: Memudahkan pembagian tagihan saat makan bersama teman.
- **Aset & Tabungan**: Manajemen target tabungan dan aset masa depan.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Localization**: [intl](https://pub.dev/packages/intl) (Formatting Rupiah & Tanggal)
- **Media**: [image_picker](https://pub.dev/packages/image_picker) (Capture Struk)

## 📂 Struktur Proyek (Blueprint)

```text
lib/
├── logic/
│   ├── transaction_model.dart     # Model data transaksi & kategori
│   ├── transaction_provider.dart  # State management & logika perhitungan
│   └── split_bill_logic.dart      # Logika perhitungan bagi tagihan
├── screens/
│   ├── main.dart                  # Dashboard & Navigasi Utama
│   ├── statistik_screen.dart      # Analisis & Grafik Keuangan
│   ├── notes_screen.dart          # Pencatatan struk & foto
│   ├── split_bill_screen.dart     # Fitur bagi tagihan
│   ├── calculator_sheet.dart      # Bottom sheet kalkulator
│   ├── add_transaction_sheet.dart # Form input transaksi baru
│   ├── transaction_detail_screen.dart # Daftar rincian transaksi
│   └── akun_screen.dart           # Profil & Pengaturan
└── main.dart                      # Entry point aplikasi
```

## 📈 Logika Bisnis (Financial Health)

Aplikasi menggunakan algoritma sederhana untuk menghitung kesehatan finansial:
- **Expense Ratio**: `Total Pengeluaran / Total Pendapatan`. Target ideal `< 70%`.
- **Saving Capacity**: `(Pendapatan - Pengeluaran) / Pendapatan`. Target ideal `> 20%`.
- **Health Score**: Kombinasi dari kedua rasio di atas untuk memberikan feedback instan kepada pengguna.

## 🏁 Cara Menjalankan

1. Pastikan Flutter SDK sudah terinstall.
2. Clone repository ini.
3. Jalankan `flutter pub get` untuk menginstall dependencies.
4. Jalankan aplikasi dengan `flutter run`.

---
*Dibuat untuk tugas Semester 4 - Fokus pada UI/UX Premium & Fungsionalitas Data.*
