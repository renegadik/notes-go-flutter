
String formatDate(String? dateStr) {
  if (dateStr == null) {
    return '';
  }
  final date = DateTime.tryParse(dateStr);

  if (date == null) {
    return dateStr;
  }

  return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}