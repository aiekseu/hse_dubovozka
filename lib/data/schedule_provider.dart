import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Picked date
final pickedDateProvider = StateProvider<DateTime>((ref) {
  DateTime now = DateTime.now();
  DateTime date = DateTime(now.year, now.month, now.day);
  return date;
});

