import 'package:intl/intl.dart';

class FormatterHelper {
  static String formatHarga(int harga) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(harga);
  }
}
