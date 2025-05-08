String timeAgoHelper(String dateStr) {
  final date = DateTime.parse(dateStr);
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inDays > 8) return '${date.day}/${date.month}/${date.year}';
  if (diff.inDays >= 1) return '${diff.inDays} hari yang lalu';
  if (diff.inHours >= 1) return '${diff.inHours} jam yang lalu';
  if (diff.inMinutes >= 1) return '${diff.inMinutes} menit yang lalu';
  if (diff.inSeconds >= 1) return '${diff.inSeconds} detik yang lalu';
  return 'Baru saja';
}
