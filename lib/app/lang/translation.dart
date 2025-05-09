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
    },
  };
}
