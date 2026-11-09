/// Format waktu ringkas untuk UI (jam:menit:detik, waktu lokal perangkat).
String formatClock(DateTime value) {
  final String hour = value.hour.toString().padLeft(2, '0');
  final String minute = value.minute.toString().padLeft(2, '0');
  final String second = value.second.toString().padLeft(2, '0');
  return '$hour:$minute:$second';
}

/// Format tanggal dan waktu ringkas: `dd/MM/yyyy HH:mm:ss`.
String formatDateTime(DateTime value) {
  final String day = value.day.toString().padLeft(2, '0');
  final String month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year} ${formatClock(value)}';
}
