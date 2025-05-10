import 'package:get/get.dart';

class AppTranslation extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'hello': 'Hello',

      // profile
      'edit_profile': 'Edit Profile',
      'language': 'Language',
      'location': 'Location',
      'manage_kost': 'Manage Kost',
      'clear_history': 'Clear History',
      'logout': 'Logout',
      'app_version': 'App Version',
      'manage_review': 'Manage Review',

      // home
      'home_title': 'Home',
      'home_welcome': 'Welcome',
      'home_search': 'Search',
      'home_categories': 'Categories',
      'home_recommended': 'Recommended',
      'home_nearby': 'Nearby',
      'home_cheapest': 'Cheapest',
      'home_expensive': 'Expensive',
      'home_best': 'Best',
      'home_search_sub': 'Find the nearest kos!',
      'home_search_title': '#Get Easy',
      'home_last_visit': 'Last Visit',
      'home_language_title': 'Choose Language',
      'home_language_indonesia': 'Indonesia',
      'home_language_english': 'English',

      // bottom nav
      'exit_app_no': 'No',
      'exit_app_yes': 'Yes',

      // bottom nav
      'exit_app_title': 'Exit App',
      'exit_app_content': 'Are you sure you want to exit the app?',
      'bottom_nav_home': 'Home',
      'bottom_nav_history': 'History',
      'bottom_nav_profile': 'Profile',
      'bottom_nav_login': 'Login',

      // detail page
      'write_review': 'Write Review',
      'fasilitas': 'Facilities',
      'deskripsi': 'Description',
      'tap_alamat_for_visit': 'Tap address to visit the kos',
      'distance_from_your_location': ' from your location',
      'room_available': 'Room Available',
      'no_review': 'No Review',
      'owner_response': 'Owner Response: ',
      'lihat_semua': 'View All',
      'sembunyikan': 'Hide',

      // favorite
      'favorite_add_success': 'Added to favorites',
      'favorite_remove_success': 'Removed from favorites',
      'favorite_login_required': 'Please login to add favorites',
      'favorite_error': 'Error',

      // comment
      'comment': 'Comment',
      'write_your_review': 'Write your review...',
      'write_review_kost_and_star': 'Write Review Kost & Star',

      // rating
      'bad': 'Bad',
      'okay': 'Okay',
      'good': 'Good',
      'excellent': 'Excellent',

      // send
      'send': 'Send',
      'cancel': 'Cancel',

      // month
      'month': 'Month',

      // ulasan
      'ulasan': 'Review',

      // history visit
      'history_visit': 'History Visit',
      'no_history_visit': 'No history visit',
      'visited_at': 'Visited at',

      // time ago
      'just_now': 'Just now',
      'seconds_ago': 'seconds ago',
      'minutes_ago': 'minutes ago',
      'hours_ago': 'hours ago',
      'days_ago': 'days ago',

      // search page
      'search_kost': 'Search Kost',
      'no_data_kos': 'No data kos',
      'semua': 'All',
      'putra': 'Putra',
      'putri': 'Putri',
      'campur': 'Campur',
    },
    'id_ID': {
      'hello': 'Halo',

      // profile
      'edit_profile': 'Ubah Profil',
      'language': 'Bahasa',
      'location': 'Lokasi',
      'manage_kost': 'Pengelolaan Kost',
      'clear_history': 'Hapus Riwayat',
      'logout': 'Keluar',
      'app_version': 'Versi Aplikasi',
      'manage_review': 'Pengelolaan Ulasan',

      // home
      'home_title': 'Beranda',
      'home_welcome': 'Selamat Datang',
      'home_search': 'Cari',
      'home_categories': 'Kategori',
      'home_recommended': 'Direkomendasikan',
      'home_nearby': 'Terdekat',
      'home_cheapest': 'Termurah',
      'home_expensive': 'Termahal',
      'home_best': 'Terbaik',
      'home_search_sub': 'Temukan kost terdekat!',
      'home_search_title': '#Dapatkan Kemudahan',
      'home_last_visit': 'Kunjungan Terakhir',
      'home_language_title': 'Pilih Bahasa',
      'home_language_indonesia': 'Indonesia',
      'home_language_english': 'English',

      // bottom nav
      'exit_app_no': 'Tidak',
      'exit_app_yes': 'Ya',

      // bottom nav
      'exit_app_title': 'Keluar Aplikasi',
      'exit_app_content': 'Apakah Anda yakin ingin keluar dari aplikasi?',
      'bottom_nav_home': 'Beranda',
      'bottom_nav_history': 'Riwayat',
      'bottom_nav_profile': 'Profil',
      'bottom_nav_login': 'Masuk',

      // detail page
      'write_review': 'Tulis Ulasan',
      'fasilitas': 'Fasilitas',
      'deskripsi': 'Deskripsi',
      'tap_alamat_for_visit': 'Ketuk alamat untuk mengunjungi kost',
      'distance_from_your_location': ' dari lokasi Anda',
      'room_available': 'Kamar Tersedia',
      'no_review': 'Belum Ada Ulasan',
      'owner_response': 'Respon Pemilik: ',
      'lihat_semua': 'Lihat Semua',
      'sembunyikan': 'Sembunyikan',

      // favorite
      'favorite_add_success': 'Ditambahkan ke favorit',
      'favorite_remove_success': 'Dihapus dari favorit',
      'favorite_login_required': 'Silakan login untuk menambahkan favorit',
      'favorite_error': 'Error',

      // comment
      'comment': 'Komentar',
      'write_your_review': 'Tulis ulasan Anda...',
      'write_review_kost_and_star': 'Tulis Ulasan Kost & Bintang',

      // rating
      'bad': 'Buruk',
      'okay': 'Lumayan',
      'good': 'Bagus',
      'excellent': 'Sangat Bagus',

      // send
      'send': 'Kirim',
      'cancel': 'Batal',

      // month
      'month': 'Bulan',

      // ulasan
      'ulasan': 'Ulasan',

      // history visit
      'history_visit': 'Riwayat Kunjungan',
      'no_history_visit': 'Belum ada riwayat kunjungan',
      'visited_at': 'Dikunjungi ',

      // time ago
      'just_now': 'Baru saja',
      'seconds_ago': 'detik yang lalu',
      'minutes_ago': 'menit yang lalu',
      'hours_ago': 'jam yang lalu',
      'days_ago': 'hari yang lalu',

      // search page
      'search_kost': 'Cari Kost',
      'no_data_kos': 'Tidak ada data kos',
      'semua': 'Semua',
      'putra': 'Putra',
      'putri': 'Putri',
      'campur': 'Campur',
    },
  };
}
