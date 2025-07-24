
String formatDate(String? dateStr) {
  if (dateStr == null) {
    return '';
  }
  final date = DateTime.tryParse(dateStr);

  if (date == null) {
    return dateStr;
  }

  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} ${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}

String dateBefore(String? dateStr) {
  if (dateStr == null) {
    return '';
  }
  final date = DateTime.tryParse(dateStr);

  if (date == null) {
    return dateStr;
  }

  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays > 0) {
    return '${difference.inDays} days ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} hours ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minutes ago';
  } else {
    return 'just now';
  }
}