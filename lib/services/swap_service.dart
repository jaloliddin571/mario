import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/swap_request_model.dart';

class SwapService {
  static final _db = FirebaseFirestore.instance;

  // ── SO'ROV YUBORISH ────────────────────────────────────
  static Future<void> sendSwapRequest({
    required String requesterId,
    required String requesterName,
    required String requesterShiftId,
    required String requesterDate,
    required String requesterTime,
    required String requesterType,
    required String targetId,
    required String targetName,
    required String targetShiftId,
    required String targetDate,
    required String targetTime,
    required String targetType,
  }) async {
    await _db.collection('swap_requests').add({
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requesterShiftId': requesterShiftId,
      'requesterDate': requesterDate,
      'requesterTime': requesterTime,
      'requesterType': requesterType,
      'targetId': targetId,
      'targetName': targetName,
      'targetShiftId': targetShiftId,
      'targetDate': targetDate,
      'targetTime': targetTime,
      'targetType': targetType,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Bildiruv saqlash — target ishchiga
    await _db.collection('notifications').add({
      'workerId': targetId,
      'workerName': targetName,
      'title': '🔄 Smena almashtirish so\'rovi',
      'body': '$requesterName siz bilan smenasini '
          'almashtirishni so\'ramoqda\n'
          '$requesterDate ↔ $targetDate',
      'type': 'swap_request',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Admin ga ham bildiruv
    await _db.collection('notifications').add({
      'workerId': 'admin',
      'title': '🔄 Smena almashtirish so\'rovi',
      'body': '$requesterName → $targetName\n'
          '$requesterDate ↔ $targetDate',
      'type': 'swap_request',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── ADMIN TASDIQLASH ───────────────────────────────────
  static Future<void> approveSwap(String swapId) async {
    final doc = await _db
        .collection('swap_requests')
        .doc(swapId)
        .get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final batch = _db.batch();

    // Smenalarni almashtirish
    batch.update(
      _db.collection('shifts').doc(data['requesterShiftId']),
      {
        'workerId': data['targetId'],
        'workerName': data['targetName'],
      },
    );

    batch.update(
      _db.collection('shifts').doc(data['targetShiftId']),
      {
        'workerId': data['requesterId'],
        'workerName': data['requesterName'],
      },
    );

    // Status yangilash
    batch.update(
      _db.collection('swap_requests').doc(swapId),
      {'status': 'approved'},
    );

    await batch.commit();

    // Ikkalasiga bildiruv
    await _db.collection('notifications').add({
      'workerId': data['requesterId'],
      'title': '✅ Smena almashtirish tasdiqlandi',
      'body': '${data['requesterDate']} smenangiz '
          '${data['targetName']} bilan almashtirildi',
      'type': 'swap_approved',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('notifications').add({
      'workerId': data['targetId'],
      'title': '✅ Smena almashtirish tasdiqlandi',
      'body': '${data['targetDate']} smenangiz '
          '${data['requesterName']} bilan almashtirildi',
      'type': 'swap_approved',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── ADMIN RAD ETISH ────────────────────────────────────
  static Future<void> rejectSwap(
      String swapId, String reason) async {
    final doc = await _db
        .collection('swap_requests')
        .doc(swapId)
        .get();
    if (!doc.exists) return;

    final data = doc.data()!;

    await _db
        .collection('swap_requests')
        .doc(swapId)
        .update({
      'status': 'rejected',
      'rejectReason': reason,
    });

    // So'rov yuborganga bildiruv
    await _db.collection('notifications').add({
      'workerId': data['requesterId'],
      'title': '❌ Smena almashtirish rad etildi',
      'body': reason.isNotEmpty
          ? 'Sabab: $reason'
          : '${data['requesterDate']} ↔ ${data['targetDate']} '
          'so\'rovi rad etildi',
      'type': 'swap_rejected',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── PENDING SO'ROVLAR ──────────────────────────────────
  static Stream<QuerySnapshot> getPendingSwaps() {
    return FirebaseFirestore.instance
        .collection('swap_requests')
        .where('status', isEqualTo: 'pending')
    // orderBy YO'Q — kodda sort qilamiz
        .snapshots();
  }

  // ── ISHCHI SO'ROVLARI ──────────────────────────────────
  static Stream<QuerySnapshot> getWorkerSwaps(
      String workerId) {
    return FirebaseFirestore.instance
        .collection('swap_requests')
        .where('requesterId', isEqualTo: workerId)
    // orderBy YO'Q
        .snapshots();
  }

  // ── MENGA KELGAN SO'ROVLAR ─────────────────────────────
  static Stream<QuerySnapshot> getIncomingSwaps(
      String workerId) {
    return _db
        .collection('swap_requests')
        .where('targetId', isEqualTo: workerId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}