import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Xavfsiz StreamBuilder — error va loading handle qiladi
class SafeStreamBuilder<T> extends StatelessWidget {
  final Stream<T> stream;
  final Widget Function(BuildContext, T) builder;
  final Widget? loading;
  final Widget? empty;

  const SafeStreamBuilder({
    super.key,
    required this.stream,
    required this.builder,
    this.loading,
    this.empty,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('StreamBuilder error: ${snapshot.error}');
          return empty ??
              const Center(
                child: Text('Ma\'lumot yuklanmadi',
                    style: TextStyle(
                        color: Color(0xFF888780))),
              );
        }
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return loading ??
              const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFFC0392B)),
              );
        }
        if (!snapshot.hasData) {
          return empty ??
              const Center(
                child: Text('Ma\'lumot yo\'q',
                    style: TextStyle(
                        color: Color(0xFF888780))),
              );
        }
        return builder(context, snapshot.data as T);
      },
    );
  }
}

// Timestamp ni xavfsiz olish
DateTime? safeTimestamp(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}

// Xavfsiz sort — createdAt null bo'lsa crash qilmaydi
List<QueryDocumentSnapshot> sortByCreatedAt(
    List<QueryDocumentSnapshot> docs,
    {bool descending = true}) {
  final sorted = [...docs];
  sorted.sort((a, b) {
    final aData = a.data() as Map;
    final bData = b.data() as Map;
    final aTime = safeTimestamp(aData['createdAt']);
    final bTime = safeTimestamp(bData['createdAt']);
    if (aTime == null && bTime == null) return 0;
    if (aTime == null) return descending ? 1 : -1;
    if (bTime == null) return descending ? -1 : 1;
    return descending
        ? bTime.compareTo(aTime)
        : aTime.compareTo(bTime);
  });
  return sorted;
}