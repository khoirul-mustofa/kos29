import 'package:get/get.dart';

String timeAgoHelper(String dateStr) {
  final date = DateTime.parse(dateStr);
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inDays > 8) return '${date.day}/${date.month}/${date.year}';
  if (diff.inDays >= 1) return '${diff.inDays} ${'days_ago'.tr}';
  if (diff.inHours >= 1) return '${diff.inHours} ${'hours_ago'.tr}';
  if (diff.inMinutes >= 1) return '${diff.inMinutes} ${'minutes_ago'.tr}';
  if (diff.inSeconds >= 1) return '${diff.inSeconds} ${'seconds_ago'.tr}';
  return 'just_now'.tr;
}
