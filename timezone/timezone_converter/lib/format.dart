const _months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
const _days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];

String two(int n) => n.toString().padLeft(2, '0');

String formatTime(DateTime d, bool use24h) {
  if (use24h) return '${two(d.hour)}:${two(d.minute)}';
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final suffix = d.hour < 12 ? 'AM' : 'PM';
  return '$h:${two(d.minute)} $suffix';
}

String formatDate(DateTime d) =>
    '${_days[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}';

String formatOffset(int minutes) {
  final sign = minutes < 0 ? '-' : '+';
  final abs = minutes.abs();
  return 'UTC$sign${two(abs ~/ 60)}:${two(abs % 60)}';
}

String formatDiff(int minutes) {
  if (minutes == 0) return 'same time';
  final sign = minutes < 0 ? '-' : '+';
  final abs = minutes.abs();
  final h = abs ~/ 60;
  final m = abs % 60;
  final mm = m == 0 ? '' : ':${two(m)}';
  return '$sign$h$mm h';
}
