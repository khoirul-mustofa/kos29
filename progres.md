# ✅ Progres Aplikasi Kost

## Fitur yang Sudah Selesai

- ✅ **Add Kost**
  - Menyimpan data ke Firestore dengan struktur:
    ```
    Collection: kostan
      └── Document: [UID Firebase Auth]
            └── Subcollection: kost
                  └── Document: [auto ID]
                        └── Field: informasi_kost
    ```
- ✅ **Menampilkan Peta**
  - Menggunakan `latitude` dan `longitude` dari lokasi pengguna saat ini.
- ✅ **Get List Data Berdasarkan UID**
  - Menampilkan hanya data kost yang dimiliki oleh user yang sedang login.
- ✅ **Menampilkan List Kosan**
  - Data diambil dari Firestore dan ditampilkan menggunakan `ListView`.

---

## Fitur Dalam Proses / Belum Implementasi

- 🔄 **Implementasi Algoritma Haversine**
  - Menghitung jarak antara lokasi pengguna dan setiap kost.
- 🔄 **Implementasi Algoritma K-Nearest Neighbor (KNN)**
  - Merekomendasikan kostan terdekat berdasarkan hasil perhitungan jarak.
- 🔄 **Edit Profile**
  - Mengizinkan pengguna memperbarui data pribadinya.
- 🔄 **History Pencarian**
  - Menyimpan riwayat pencarian lokasi atau preferensi kos sebelumnya.
- 🔄 **Onboarding**
  - Menampilkan panduan singkat saat pertama kali aplikasi dijalankan.

---

## Fitur Selanjutnya (Rekomendasi)

- 🔄 **Edit & Hapus Data Kost**
- 📸 **Upload & Tampilkan Gambar Kost**
- 🔍 **Pencarian atau Filter Kosan**
- 🗺️ **Tampilkan Semua Kosan di Peta (Mode Admin/User)**
- 💬 **Chat antara Pencari Kos & Pemilik Kos**
