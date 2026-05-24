import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import 'my_work_screen.dart';
import 'swap_request_screen.dart';

class WorkerHome extends StatefulWidget {
  const WorkerHome({super.key});

  @override
  State<WorkerHome> createState() => _WorkerHomeState();
}

class _WorkerHomeState extends State<WorkerHome> {
  static const marioRed = Color(0xFFC0392B);
  static const marioRedDark = Color(0xFFA82F23);
  static const marioCream = Color(0xFFFFFBF5);
  static const marioBg = Color(0xFFF6F2EA);
  static const marioCard = Color(0xFFFFFFFF);
  static const marioBorder = Color(0xFFE9E1D3);
  static const marioText = Color(0xFF201D1A);
  static const marioSub = Color(0xFF7B746B);
  static const marioLight = Color(0xFFFAE6DE);
  static const marioGold = Color(0xFFF1B94E);

  final _db = FirebaseFirestore.instance;
  int _currentIndex = 0;
  late DateTime _weekStart;

  final _dayNames = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
  final _months = [
    'yanvar',
    'fevral',
    'mart',
    'aprel',
    'may',
    'iyun',
    'iyul',
    'avgust',
    'sentabr',
    'oktabr',
    'noyabr',
    'dekabr',
  ];
  final _fullDays = [
    'Dushanba',
    'Seshanba',
    'Chorshanba',
    'Payshanba',
    'Juma',
    'Shanba',
    'Yakshanba',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _weekStart = now.subtract(Duration(days: now.weekday - 1));
    _weekStart = DateTime(_weekStart.year, _weekStart.month, _weekStart.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: marioBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  _buildScheduleTab(),
                  const SizedBox(),
                  _buildNotifTab(),
                  _buildProfileTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    final auth = Provider.of<AuthService>(context, listen: false);
    final name = auth.userName ?? 'Ishchi';
    final now = DateTime.now();
    final userId = auth.user?.uid ?? '';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [marioRed, marioRedDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Salom, $name',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_fullDays[now.weekday - 1]}, ${now.day} ${_months[now.month - 1]}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.82),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _db
                    .collection('notifications')
                    .where('workerId', isEqualTo: userId)
                    .where('read', isEqualTo: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.docs.length ?? 0;
                  return GestureDetector(
                    onTap: () => setState(() => _currentIndex = 2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.14),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            count > 9 ? '9+' : '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          StreamBuilder<QuerySnapshot>(
            stream: _db
                .collection('shifts')
                .where('workerId', isEqualTo: userId)
                .where('date', isEqualTo: _formatDate(now))
                .snapshots(),
            builder: (context, snapshot) {
              final shifts = snapshot.data?.docs ?? [];
              if (shifts.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.14),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.event_busy_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Bugun uchun smena yo‘q',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final data = shifts.first.data() as Map<String, dynamic>;
              final type = data['type'] ?? 'morning';
              final start = data['startTime'] ?? '';
              final end = data['endTime'] ?? '';

              IconData typeIcon;
              String typeLabel;

              switch (type) {
                case 'night':
                  typeIcon = Icons.nights_stay_rounded;
                  typeLabel = 'Tungi';
                  break;
                case 'off':
                  typeIcon = Icons.weekend_rounded;
                  typeLabel = 'Dam olish';
                  break;
                case 'half':
                  typeIcon = Icons.timelapse_rounded;
                  typeLabel = 'Yarim';
                  break;
                default:
                  typeIcon = Icons.wb_sunny_rounded;
                  typeLabel = 'Kunduzgi';
              }

              String duration = '';
              if (type != 'off' && start.isNotEmpty && end.isNotEmpty) {
                try {
                  final sp = start.split(':');
                  final ep = end.split(':');
                  var s = int.parse(sp[0]) * 60 + int.parse(sp[1]);
                  var e = int.parse(ep[0]) * 60 + int.parse(ep[1]);
                  if (e < s) e += 24 * 60;
                  final h = (e - s) ~/ 60;
                  duration = '$h soat ishlash vaqti';
                } catch (_) {}
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.14),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(typeIcon, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type == 'off' ? 'Dam olish kuni' : '$start - $end',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            type == 'off' ? 'Bugun ishlanmaydi' : duration,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.82),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: marioGold,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        typeLabel,
                        style: const TextStyle(
                          color: marioText,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    final auth = Provider.of<AuthService>(context, listen: false);
    final userId = auth.user?.uid ?? '';
    final weekStr = _formatDate(_weekStart);

    return Column(
      children: [
        Container(
          color: Colors.transparent,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: _card(
            child: Row(
              children: [
                _navBtn(Icons.chevron_left_rounded, () {
                  setState(() {
                    _weekStart = _weekStart.subtract(const Duration(days: 7));
                  });
                }),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${_weekStart.day} - ${_weekStart.add(const Duration(days: 6)).day} ${_months[_weekStart.month - 1]}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: marioText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isCurrentWeek()
                            ? 'Joriy hafta'
                            : _weekStart.isBefore(DateTime.now())
                            ? 'O‘tgan hafta'
                            : 'Keyingi hafta',
                        style: const TextStyle(
                          fontSize: 11,
                          color: marioSub,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                _navBtn(Icons.chevron_right_rounded, () {
                  setState(() {
                    _weekStart = _weekStart.add(const Duration(days: 7));
                  });
                }),
              ],
            ),
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: _db
              .collection('shifts')
              .where('workerId', isEqualTo: userId)
              .where('weekStart', isEqualTo: weekStr)
              .snapshots(),
          builder: (context, snapshot) {
            final shifts = snapshot.data?.docs ?? [];
            return Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: _card(
                child: Row(
                  children: List.generate(7, (i) {
                    final date = _weekStart.add(Duration(days: i));
                    final dateStr = _formatDate(date);
                    final hasShift = shifts.any(
                          (s) => (s.data() as Map)['date'] == dateStr,
                    );
                    final isToday = _isToday(date);

                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isToday
                              ? marioRed
                              : hasShift
                              ? marioLight
                              : marioCream,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _dayNames[i],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isToday
                                    ? Colors.white70
                                    : const Color(0xFF8B8378),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isToday ? Colors.white : marioText,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: hasShift
                                    ? (isToday ? Colors.white : marioRed)
                                    : Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            );
          },
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _db
                .collection('shifts')
                .where('workerId', isEqualTo: userId)
                .where('weekStart', isEqualTo: weekStr)
                .orderBy('date')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: marioRed),
                );
              }

              final shifts = snapshot.data?.docs ?? [];
              if (shifts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 56,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Bu hafta smena yo‘q',
                        style: TextStyle(
                          color: marioSub,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                itemCount: shifts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final data = shifts[i].data() as Map<String, dynamic>;
                  return _buildShiftCard(data);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShiftCard(Map<String, dynamic> data) {
    final type = data['type'] ?? 'morning';
    final dateStr = data['date'] ?? '';
    final start = data['startTime'] ?? '';
    final end = data['endTime'] ?? '';

    DateTime? date;
    try {
      final parts = dateStr.split('-');
      date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (_) {}

    final isToday = date != null && _isToday(date);

    late final Color accentColor;
    late final Color bgColor;
    late final Color textColor;
    late final String typeLabel;
    late final IconData typeIcon;

    switch (type) {
      case 'night':
        accentColor = const Color(0xFF534AB7);
        bgColor = const Color(0xFFEEEDFE);
        textColor = const Color(0xFF3C3489);
        typeLabel = 'Tungi';
        typeIcon = Icons.nights_stay_rounded;
        break;
      case 'off':
        accentColor = const Color(0xFF8E8A83);
        bgColor = marioCream;
        textColor = const Color(0xFF5F5E5A);
        typeLabel = 'Dam olish';
        typeIcon = Icons.weekend_rounded;
        break;
      case 'half':
        accentColor = const Color(0xFF3B6D11);
        bgColor = const Color(0xFFEAF3DE);
        textColor = const Color(0xFF2E7D32);
        typeLabel = 'Yarim';
        typeIcon = Icons.timelapse_rounded;
        break;
      default:
        accentColor = marioRed;
        bgColor = const Color(0xFFFAECE7);
        textColor = const Color(0xFF993C1D);
        typeLabel = 'Kunduzgi';
        typeIcon = Icons.wb_sunny_rounded;
    }

    String duration = '';
    if (type != 'off' && start.isNotEmpty && end.isNotEmpty) {
      try {
        final sp = start.split(':');
        final ep = end.split(':');
        var s = int.parse(sp[0]) * 60 + int.parse(sp[1]);
        var e = int.parse(ep[0]) * 60 + int.parse(ep[1]);
        if (e < s) e += 24 * 60;
        final h = (e - s) ~/ 60;
        final m = (e - s) % 60;
        duration = '$h soat${m > 0 ? ' $m daqiqa' : ''}';
      } catch (_) {}
    }

    return Container(
      decoration: BoxDecoration(
        color: marioCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isToday ? accentColor : marioBorder,
          width: isToday ? 1.3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            date != null
                                ? '${_fullDays[date.weekday - 1]}, ${date.day} ${_months[date.month - 1]}'
                                : dateStr,
                            style: TextStyle(
                              fontSize: 12,
                              color: isToday ? accentColor : marioSub,
                              fontWeight: isToday
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isToday)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Bugun',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(typeIcon, size: 12, color: textColor),
                              const SizedBox(width: 4),
                              Text(
                                typeLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      type == 'off' ? 'Dam olish kuni' : '$start - $end',
                      style: TextStyle(
                        fontSize: type == 'off' ? 18 : 24,
                        fontWeight: FontWeight.w800,
                        color: type == 'off' ? textColor : marioText,
                      ),
                    ),
                    if (duration.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        duration,
                        style: const TextStyle(
                          fontSize: 12,
                          color: marioSub,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifTab() {
    final auth = Provider.of<AuthService>(context, listen: false);
    final userId = auth.user?.uid ?? '';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: _card(
            child: Row(
              children: [
                const Text(
                  'Bildirishnomalar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: marioText,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    try {
                      final snap = await _db
                          .collection('notifications')
                          .where('workerId', isEqualTo: userId)
                          .where('read', isEqualTo: false)
                          .get();
                      final batch = _db.batch();
                      for (final doc in snap.docs) {
                        batch.update(doc.reference, {'read': true});
                      }
                      await batch.commit();
                    } catch (_) {}
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: marioLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Hammasini o‘qi',
                      style: TextStyle(
                        fontSize: 11,
                        color: marioRed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _db
                .collection('notifications')
                .where('workerId', isEqualTo: userId)
                .limit(30)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.wifi_off_outlined,
                        size: 50,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Bildirishnomalar yuklanmadi',
                        style: TextStyle(color: marioSub),
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: marioRed,
                    strokeWidth: 2,
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];
              final sorted = [...docs];
              sorted.sort((a, b) {
                final aData = a.data() as Map;
                final bData = b.data() as Map;
                Timestamp? aT;
                Timestamp? bT;
                try {
                  aT = aData['createdAt'] as Timestamp?;
                } catch (_) {}
                try {
                  bT = bData['createdAt'] as Timestamp?;
                } catch (_) {}
                if (aT == null && bT == null) return 0;
                if (aT == null) return 1;
                if (bT == null) return -1;
                return bT.compareTo(aT);
              });

              if (sorted.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_none_outlined,
                        size: 56,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Hozircha bildirishnoma yo‘q',
                        style: TextStyle(
                          color: marioSub,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Yangi smena qo‘shilganda bildiruv keladi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFB4B2A9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                itemCount: sorted.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  Map<String, dynamic> data = {};
                  try {
                    data = sorted[i].data() as Map<String, dynamic>;
                  } catch (_) {
                    return const SizedBox.shrink();
                  }

                  final read = data['read'] as bool? ?? false;
                  final title = data['title'] as String? ?? '';
                  final body = data['body'] as String? ?? '';
                  final type = data['type'] as String? ?? '';

                  DateTime? createdAt;
                  try {
                    final ts = data['createdAt'] as Timestamp?;
                    createdAt = ts?.toDate();
                  } catch (_) {}

                  late final Color accentColor;
                  late final IconData notifIcon;

                  switch (type) {
                    case 'new_shift':
                      accentColor = marioRed;
                      notifIcon = Icons.calendar_month_outlined;
                      break;
                    case 'shift_updated':
                      accentColor = const Color(0xFF534AB7);
                      notifIcon = Icons.edit_calendar_outlined;
                      break;
                    case 'tomorrow_reminder':
                      accentColor = const Color(0xFFB8860B);
                      notifIcon = Icons.alarm_outlined;
                      break;
                    case 'swap_request':
                    case 'swap_approved':
                      accentColor = const Color(0xFF3B6D11);
                      notifIcon = Icons.swap_horiz_outlined;
                      break;
                    case 'swap_rejected':
                      accentColor = Colors.red;
                      notifIcon = Icons.cancel_outlined;
                      break;
                    default:
                      accentColor = marioRed;
                      notifIcon = Icons.notifications_outlined;
                  }

                  return GestureDetector(
                    onTap: () async {
                      try {
                        await _db
                            .collection('notifications')
                            .doc(sorted[i].id)
                            .update({'read': true});
                      } catch (_) {}
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: read ? marioCard : accentColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: read
                              ? marioBorder
                              : accentColor.withOpacity(0.25),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              notifIcon,
                              color: accentColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: read
                                              ? FontWeight.w600
                                              : FontWeight.w800,
                                          color: marioText,
                                        ),
                                      ),
                                    ),
                                    if (!read)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: accentColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                if (body.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    body,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: marioSub,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                                if (createdAt != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    _timeAgo(createdAt),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFFB4B2A9),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    final auth = Provider.of<AuthService>(context, listen: false);
    final name = auth.userName ?? 'Ishchi';
    final email = auth.user?.email ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      child: Column(
        children: [
          _card(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: marioLight,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: marioRed,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: marioText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: marioSub,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: marioLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Ishchi',
                    style: TextStyle(
                      color: Color(0xFF993C1D),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _card(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _profileTile(
                  Icons.calendar_month_outlined,
                  'Mening jadvalim',
                      () => setState(() => _currentIndex = 0),
                ),
                const Divider(height: 1, thickness: 1, color: marioBorder),
                _profileTile(
                  Icons.access_time_outlined,
                  'Ish soatlarim',
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyWorkScreen()),
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: marioBorder),
                _profileTile(
                  Icons.swap_horiz_outlined,
                  'Smena almashtirish so‘rovi',
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SwapRequestScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: marioBorder),
                _profileTile(
                  Icons.logout_rounded,
                  'Chiqish',
                      () async => await auth.logout(),
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileTile(
      IconData icon,
      String label,
      VoidCallback onTap, {
        Color? color,
      }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(icon, color: color ?? marioRed, size: 20),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color ?? marioText,
        ),
      ),
      trailing: color == null
          ? const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Color(0xFFB4B2A9),
      )
          : null,
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.calendar_month_outlined, 'label': 'Jadval'},
      {'icon': Icons.access_time_outlined, 'label': 'Soatlar'},
      {'icon': Icons.notifications_outlined, 'label': 'Bildiruv'},
      {'icon': Icons.person_outline, 'label': 'Profil'},
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: marioCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = _currentIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (i == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyWorkScreen()),
                  );
                } else {
                  setState(() => _currentIndex = i);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? marioLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[i]['icon'] as IconData,
                      color: active ? marioRed : const Color(0xFF9F988F),
                      size: 21,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      items[i]['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: active ? marioRed : const Color(0xFF9F988F),
                        fontWeight:
                        active ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(14),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: marioCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: marioBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: marioCream,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: marioSub, size: 20),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'Hozir';
    if (diff.inMinutes < 60) return '${diff.inMinutes} daqiqa oldin';
    if (diff.inHours < 24) return '${diff.inHours} soat oldin';
    if (diff.inDays < 7) return '${diff.inDays} kun oldin';
    return '${date.day}-${date.month}-${date.year}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isCurrentWeek() {
    final now = DateTime.now();
    final cur = now.subtract(Duration(days: now.weekday - 1));
    final curStart = DateTime(cur.year, cur.month, cur.day);
    return _weekStart == curStart;
  }
}