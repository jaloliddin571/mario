class SwapRequest {
  final String id;
  final String requesterId;      // So'rov yuborgan ishchi
  final String requesterName;
  final String targetId;         // Almashtirilmoqchi ishchi
  final String targetName;
  final String requesterShiftId; // So'rovchi smenasi
  final String targetShiftId;    // Maqsad smenasi
  final String requesterDate;
  final String targetDate;
  final String requesterTime;    // 08:00–17:00
  final String targetTime;
  final String requesterType;    // morning/night/off/half
  final String targetType;
  final String status;           // pending/approved/rejected
  final DateTime? createdAt;

  const SwapRequest({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.targetId,
    required this.targetName,
    required this.requesterShiftId,
    required this.targetShiftId,
    required this.requesterDate,
    required this.targetDate,
    required this.requesterTime,
    required this.targetTime,
    required this.requesterType,
    required this.targetType,
    required this.status,
    this.createdAt,
  });

  factory SwapRequest.fromMap(String id, Map<String, dynamic> map) {
    return SwapRequest(
      id: id,
      requesterId: map['requesterId'] ?? '',
      requesterName: map['requesterName'] ?? '',
      targetId: map['targetId'] ?? '',
      targetName: map['targetName'] ?? '',
      requesterShiftId: map['requesterShiftId'] ?? '',
      targetShiftId: map['targetShiftId'] ?? '',
      requesterDate: map['requesterDate'] ?? '',
      targetDate: map['targetDate'] ?? '',
      requesterTime: map['requesterTime'] ?? '',
      targetTime: map['targetTime'] ?? '',
      requesterType: map['requesterType'] ?? '',
      targetType: map['targetType'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requesterId': requesterId,
      'requesterName': requesterName,
      'targetId': targetId,
      'targetName': targetName,
      'requesterShiftId': requesterShiftId,
      'targetShiftId': targetShiftId,
      'requesterDate': requesterDate,
      'targetDate': targetDate,
      'requesterTime': requesterTime,
      'targetTime': targetTime,
      'requesterType': requesterType,
      'targetType': targetType,
      'status': 'pending',
      'createdAt': DateTime.now(),
    };
  }
}