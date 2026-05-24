import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';

class MyWorkScreen extends StatefulWidget {
  const MyWorkScreen({super.key});

  @override
  State<MyWorkScreen> createState() => _MyWorkScreenState();
}

class _MyWorkScreenState extends State<MyWorkScreen> {
  static const marioRed = Color(0xFFC0392B);
  static const marioRedDark = Color(0xFFA82F23);
  static const marioCream = Color(0xFFFFFBF5);
  static const marioCard = Color(0xFFFFFFFF);
  static const marioBorder = Color(0xFFE9E1D3);
  static const marioText = Color(0xFF201D1A);
  static const marioSub = Color(0xFF7B746B);
  static const marioLight = Color(0xFFFAE6DE);
  static const marioBg = Color(0xFFF6F2EA);
  static const marioGold = Color(0xFFF1B94E);

  final _db = FirebaseFirestore.instance;

  late int _selectedMonth;
  late int _selectedYear;

  final _months = [
    'Yanvar',
    'Fevral',
    'Mart',
    'Aprel',
    'May',
    'Iyun',
    'Iyul',
    'Avgust',
    'Sentabr',
    'Oktabr',
    'Noyabr',
    'Dekabr',
  ];

  final _dayNames = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];

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
    _selectedMonth = now.month;
    _selectedYear = now.year;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final userId = auth.user?.uid ?? '';
    final userName = auth.userName ?? 'Ishchi';

    final monthStart =
        '$_selectedYear-${_selectedMonth.toString().padLeft(2, '0')}-01';
    final monthEnd =
        '$_selectedYear-${_selectedMonth.toString().padLeft(2, '0')}-31';

    return Scaffold(
      backgroundColor: marioBg,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<QuerySnapshot>(
          stream: _db
              .collection('shifts')
              .where('workerId', isEqualTo: userId)
              .where('date', isGreaterThanOrEqualTo: monthStart)
              .where('date', isLessThanOrEqualTo: monthEnd)
              .snapshots(),
          builder: (context, snapshot) {
            final shifts = snapshot.data?.docs ?? [];
            final stats = _calcStats(shifts);

            return Column(
              children: [
                _buildHeader(userName, stats),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
                    child: Column(
                      children: [
                        _buildSummaryCard(userName, stats),
                        const SizedBox(height: 14),
                        _buildWeeklyView(userId),
                        const SizedBox(height: 14),
                        _buildUpcomingShifts(userId),
                        const SizedBox(height: 14),
                        _buildMonthlyProgress(stats),
                        const SizedBox(height: 14),
                        _buildWorkInfo(stats),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(String userName, Map<String, int> stats) {
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
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.14),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mening ishim',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Oy bo‘yicha ish ma’lumotlari',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: marioGold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${stats['workDays'] ?? 0} kun',
                  style: const TextStyle(
                    color: marioText,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _months.length,
              itemBuilder: (_, i) {
                final selected = i + 1 == _selectedMonth;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMonth = i + 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white
                          : Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: selected
                            ? Colors.white
                            : Colors.white.withOpacity(0.18),
                      ),
                    ),
                    child: Text(
                      _months[i],
                      style: TextStyle(
                        color: selected ? marioRed : Colors.white,
                        fontSize: 12,
                        fontWeight:
                        selected ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String userName, Map<String, int> stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [marioRed, marioRedDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: marioRed.withOpacity(0.24),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.16),
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ishchi · ${_months[_selectedMonth - 1]} $_selectedYear',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.78),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _summaryStatItem('${stats['totalHours'] ?? 0}', 'Ish soati'),
              _summaryDivider(),
              _summaryStatItem('${stats['workDays'] ?? 0}', 'Ish kuni'),
              _summaryDivider(),
              _summaryStatItem('${stats['offDays'] ?? 0}', 'Dam olish'),
              _summaryDivider(),
              _summaryStatItem('${stats['nightDays'] ?? 0}', 'Tungi'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryStatItem(String val, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            val,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.76),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryDivider() {
    return Container(
      width: 1,
      height: 34,
      color: Colors.white.withOpacity(0.18),
    );
  }

  Widget _buildWeeklyView(String userId) {
    final now = DateTime.now();
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final thisWeekClean = DateTime(
      thisWeekStart.year,
      thisWeekStart.month,
      thisWeekStart.day,
    );
    final nextWeekStart = thisWeekClean.add(const Duration(days: 7));

    return _card(
      title: 'Haftalik jadval',
      icon: Icons.calendar_month_rounded,
      child: StreamBuilder<QuerySnapshot>(
        stream: _db
            .collection('shifts')
            .where('workerId', isEqualTo: userId)
            .where('weekStart', whereIn: [
          _formatDate(thisWeekClean),
          _formatDate(nextWeekStart),
        ]).snapshots(),
        builder: (context, snapshot) {
          final shifts = snapshot.data?.docs ?? [];
          return Column(
            children: [
              _weekRow(
                'Joriy hafta · ${thisWeekClean.day}-${thisWeekClean.add(const Duration(days: 6)).day} ${_months[thisWeekClean.month - 1]}',
                thisWeekClean,
                shifts,
              ),
              const SizedBox(height: 14),
              _weekRow(
                'Keyingi hafta · ${nextWeekStart.day}-${nextWeekStart.add(const Duration(days: 6)).day} ${_months[nextWeekStart.month - 1]}',
                nextWeekStart,
                shifts,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _legendItem(const Color(0xFFFAECE7), 'Kunduzgi'),
                  _legendItem(const Color(0xFFEEEDFE), 'Tungi'),
                  _legendItem(const Color(0xFFEAF3DE), 'Yarim'),
                  _legendItem(marioCream, 'Dam olish'),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _weekRow(
      String label,
      DateTime weekStart,
      List<QueryDocumentSnapshot> allShifts,
      ) {
    final weekStr = _formatDate(weekStart);
    final weekShifts = allShifts
        .where((s) => (s.data() as Map)['weekStart'] == weekStr)
        .toList();

    final workCount = weekShifts
        .where((s) => (s.data() as Map)['type'] != 'off')
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: marioSub,
                ),
              ),
            ),
            Text(
              '$workCount ish kuni',
              style: const TextStyle(
                fontSize: 11,
                color: marioRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(7, (i) {
            final date = weekStart.add(Duration(days: i));
            final dateStr = _formatDate(date);
            final matchingShifts = weekShifts
                .where((s) => (s.data() as Map)['date'] == dateStr)
                .toList();

            final hasShift = matchingShifts.isNotEmpty;
            final type = hasShift
                ? (matchingShifts.first.data() as Map)['type'] ?? ''
                : '';
            final isToday = _isToday(date);

            Color bg;
            Color textColor;

            switch (type) {
              case 'morning':
                bg = const Color(0xFFFAECE7);
                textColor = const Color(0xFF993C1D);
                break;
              case 'half':
                bg = const Color(0xFFEAF3DE);
                textColor = const Color(0xFF3B6D11);
                break;
              case 'night':
                bg = const Color(0xFFEEEDFE);
                textColor = const Color(0xFF534AB7);
                break;
              case 'off':
                bg = marioCream;
                textColor = marioSub;
                break;
              default:
                bg = const Color(0xFFF4F1EA);
                textColor = marioSub;
            }

            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(10),
                  border: isToday
                      ? Border.all(color: marioRed, width: 1.4)
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      _dayNames[i],
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: marioBorder),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: marioSub,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingShifts(String userId) {
    final now = DateTime.now();
    final todayStr = _formatDate(now);
    final futureStr = _formatDate(now.add(const Duration(days: 7)));

    return _card(
      title: 'Yaqinlashayotgan smenalar',
      icon: Icons.schedule_rounded,
      child: StreamBuilder<QuerySnapshot>(
        stream: _db
            .collection('shifts')
            .where('workerId', isEqualTo: userId)
            .where('date', isGreaterThanOrEqualTo: todayStr)
            .where('date', isLessThanOrEqualTo: futureStr)
            .orderBy('date')
            .snapshots(),
        builder: (context, snapshot) {
          final shifts = snapshot.data?.docs ?? [];
          if (shifts.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text(
                  'Yaqin smenalar yo‘q',
                  style: TextStyle(
                    color: marioSub,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }

          return Column(
            children: shifts.take(5).map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _upcomingShiftRow(data);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _upcomingShiftRow(Map<String, dynamic> data) {
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
    late final String typeLabel;

    switch (type) {
      case 'night':
        accentColor = const Color(0xFF534AB7);
        bgColor = const Color(0xFFEEEDFE);
        typeLabel = 'Tungi';
        break;
      case 'off':
        accentColor = marioSub;
        bgColor = marioCream;
        typeLabel = 'Dam olish';
        break;
      case 'half':
        accentColor = const Color(0xFF3B6D11);
        bgColor = const Color(0xFFEAF3DE);
        typeLabel = 'Yarim';
        break;
      default:
        accentColor = marioRed;
        bgColor = marioLight;
        typeLabel = 'Kunduzgi';
    }

    String dayLabel = '';
    if (date != null) {
      if (isToday) {
        dayLabel = 'Bugun';
      } else if (date.difference(DateTime.now()).inDays <= 1) {
        dayLabel = 'Ertaga';
      } else {
        dayLabel = _fullDays[date.weekday - 1];
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: marioCream,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 42,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(999),
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
                        date != null
                            ? '$dayLabel, ${date.day} ${_months[date.month - 1].toLowerCase()}'
                            : dateStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: isToday ? accentColor : marioSub,
                          fontWeight:
                          isToday ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isToday)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: marioRed,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Bugun',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  type == 'off' ? 'Dam olish kuni' : '$start - $end',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: type == 'off' ? marioSub : marioText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              typeLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyProgress(Map<String, int> stats) {
    final totalHours = stats['totalHours'] ?? 0;
    final workDays = stats['workDays'] ?? 0;
    final offDays = stats['offDays'] ?? 0;

    const targetHours = 176;
    const targetWorkDays = 22;
    const targetOffDays = 9;

    return _card(
      title: 'Oylik progress',
      icon: Icons.query_stats_rounded,
      child: Column(
        children: [
          _progressRow(
            'Ish soatlari',
            '$totalHours / $targetHours soat',
            totalHours / targetHours,
            marioRed,
          ),
          const SizedBox(height: 12),
          _progressRow(
            'Ish kunlari',
            '$workDays / $targetWorkDays kun',
            workDays / targetWorkDays,
            const Color(0xFF534AB7),
          ),
          const SizedBox(height: 12),
          _progressRow(
            'Dam olish kunlari',
            '$offDays / $targetOffDays kun',
            offDays / targetOffDays,
            marioSub,
          ),
        ],
      ),
    );
  }

  Widget _progressRow(
      String label,
      String val,
      double progress,
      Color color,
      ) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: marioSub,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              val,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: marioText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: const Color(0xFFF0EAE0),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkInfo(Map<String, int> stats) {
    final morning = stats['morningDays'] ?? 0;
    final night = stats['nightDays'] ?? 0;
    final half = stats['halfDays'] ?? 0;
    final off = stats['offDays'] ?? 0;
    final totalH = stats['totalHours'] ?? 0;
    final workDays = stats['workDays'] ?? 0;
    final avgHours =
    workDays > 0 ? (totalH / workDays).toStringAsFixed(1) : '0';

    return _card(
      title: 'Ish ma\'lumotlari',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          _infoRow(
            Icons.wb_sunny_rounded,
            marioRed,
            marioLight,
            'Kunduzgi smenalar',
            '$morning ta',
          ),
          _infoRow(
            Icons.nights_stay_rounded,
            const Color(0xFF534AB7),
            const Color(0xFFEEEDFE),
            'Tungi smenalar',
            '$night ta',
          ),
          _infoRow(
            Icons.timelapse_rounded,
            const Color(0xFF3B6D11),
            const Color(0xFFEAF3DE),
            'Yarim smenalar',
            '$half ta',
          ),
          _infoRow(
            Icons.weekend_rounded,
            marioSub,
            marioCream,
            'Dam olish kunlari',
            '$off ta',
          ),
          _infoRow(
            Icons.access_time_rounded,
            marioRed,
            marioLight,
            'O‘rtacha kunlik soat',
            '$avgHours soat',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
      IconData icon,
      Color color,
      Color bg,
      String label,
      String val,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: marioSub,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            val,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: marioText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: marioCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: marioBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: marioLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 17, color: marioRed),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: marioText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 14),
            child: Divider(height: 1, thickness: 1, color: marioBorder),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }

  Map<String, int> _calcStats(List<QueryDocumentSnapshot> shifts) {
    int totalMinutes = 0;
    int workDays = 0;
    int offDays = 0;
    int morningDays = 0;
    int nightDays = 0;
    int halfDays = 0;

    for (final doc in shifts) {
      final data = doc.data() as Map<String, dynamic>;
      final type = data['type'] ?? '';

      if (type == 'off') {
        offDays++;
        continue;
      }

      workDays++;
      if (type == 'morning') morningDays++;
      if (type == 'night') nightDays++;
      if (type == 'half') halfDays++;

      final s = data['startTime'] ?? '';
      final e = data['endTime'] ?? '';

      if (s.isNotEmpty && e.isNotEmpty) {
        try {
          final sp = s.split(':');
          final ep = e.split(':');
          var start = int.parse(sp[0]) * 60 + int.parse(sp[1]);
          var end = int.parse(ep[0]) * 60 + int.parse(ep[1]);
          if (end < start) end += 24 * 60;
          totalMinutes += end - start;
        } catch (_) {}
      }
    }

    return {
      'totalHours': totalMinutes ~/ 60,
      'workDays': workDays,
      'offDays': offDays,
      'morningDays': morningDays,
      'nightDays': nightDays,
      'halfDays': halfDays,
    };
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
}