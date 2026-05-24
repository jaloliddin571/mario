import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../services/excel_service.dart';
import '../../services/notification_service.dart';
import 'add_shift_screen.dart';
import 'all_shifts_screen.dart';
import 'workers_screen.dart';
import 'swap_approval_screen.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  static const marioRed = Color(0xFFC0392B);
  static const marioRedDark = Color(0xFFA82F23);
  static const marioBg = Color(0xFFF6F2EA);
  static const marioCream = Color(0xFFFFFBF5);
  static const marioCard = Color(0xFFFFFFFF);
  static const marioBorder = Color(0xFFE9E1D3);
  static const marioText = Color(0xFF201D1A);
  static const marioSub = Color(0xFF7B746B);
  static const marioLight = Color(0xFFFAE6DE);
  static const marioGold = Color(0xFFF1B94E);

  final _db = FirebaseFirestore.instance;
  final ScrollController _dashboardScrollController = ScrollController();

  int _currentIndex = 0;

  @override
  void dispose() {
    _dashboardScrollController.dispose();
    super.dispose();
  }

  void _setTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: marioBg,
        bottomNavigationBar: _buildNavTabs(),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    _buildDashboard(),
                    const AddShiftScreen(embedded: true),
                    const WorkersScreen(),
                    _buildStatsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final monthNames = [
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
    final dayNames = [
      'Dushanba',
      'Seshanba',
      'Chorshanba',
      'Payshanba',
      'Juma',
      'Shanba',
      'Yakshanba',
    ];

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
                    const Text(
                      'MARIO ADMIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${dayNames[now.weekday - 1]}, ${now.day} ${monthNames[now.month - 1]}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.82),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _headerBtn(
                icon: Icons.notifications_none_rounded,
                label: '3',
                onTap: _showNotifications,
              ),
              const SizedBox(width: 8),
              _headerBtn(
                icon: Icons.account_circle_outlined,
                label: 'Boss',
                onTap: _showProfile,
              ),
            ],
          ),
          const SizedBox(height: 18),
          StreamBuilder<QuerySnapshot>(
            stream: _db
                .collection('shifts')
                .where('date', isEqualTo: _todayStr())
                .snapshots(),
            builder: (context, snapshot) {
              final shiftCount = snapshot.data?.docs.length ?? 0;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.16),
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
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bugungi nazorat markazi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$shiftCount ta smena rejalashtirilgan',
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
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
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

  Widget _headerBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 17),
            const SizedBox(width: 6),
            Text(
              label,
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
  }

  Widget _buildNavTabs() {
    final tabs = [
      (Icons.dashboard_customize_outlined, 'Bosh sahifa'),
      (Icons.edit_calendar_outlined, 'Smena'),
      (Icons.groups_2_outlined, 'Ishchilar'),
      (Icons.query_stats_rounded, 'Statistika'),
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
        children: List.generate(tabs.length, (index) {
          final isActive = _currentIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                _setTab(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? marioLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tabs[index].$1,
                      size: 20,
                      color: isActive ? marioRed : marioSub,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      tabs[index].$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isActive ? marioRed : marioSub,
                        fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.w500,
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

  Widget _buildDashboard() {
    return CustomScrollView(
      controller: _dashboardScrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildSectionTitle(
                  'Bugungi ko\'rsatkichlar',
                  'Asosiy holat bir qarashda',
                ),
                const SizedBox(height: 12),
                _buildStatsGrid(),
                const SizedBox(height: 18),
                _buildWeekCard(),
                const SizedBox(height: 18),
                _buildTodayShiftsCard(),
                const SizedBox(height: 18),
                _buildQuickActions(),
                const SizedBox(height: 18),
                _buildNotificationsCard(),
                const SizedBox(height: 18),
                _buildAddShiftBtn(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: marioText,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: marioSub,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection('shifts')
          .where('date', isEqualTo: _todayStr())
          .snapshots(),
      builder: (context, snapshot) {
        final shifts = snapshot.data?.docs ?? [];
        final morning = shifts
            .where((s) => (s.data() as Map)['type'] == 'morning')
            .length;
        final night = shifts
            .where((s) => (s.data() as Map)['type'] == 'night')
            .length;
        final off =
            shifts.where((s) => (s.data() as Map)['type'] == 'off').length;

        return StreamBuilder<QuerySnapshot>(
          stream: _db
              .collection('users')
              .where('role', isEqualTo: 'worker')
              .snapshots(),
          builder: (context, usersSnap) {
            final total = usersSnap.data?.docs.length ?? 0;
            return GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 138,
              ),
              children: [
                _statCard(
                  value: '$morning',
                  label: 'Kunduzgi smena',
                  icon: Icons.wb_sunny_rounded,
                  accent: marioRed,
                  surface: marioLight,
                ),
                _statCard(
                  value: '$night',
                  label: 'Tungi smena',
                  icon: Icons.nights_stay_rounded,
                  accent: const Color(0xFF534AB7),
                  surface: const Color(0xFFEEEDFE),
                ),
                _statCard(
                  value: '$off',
                  label: 'Dam olishda',
                  icon: Icons.weekend_rounded,
                  accent: marioSub,
                  surface: marioCream,
                ),
                _statCard(
                  value: '$total',
                  label: 'Jami ishchilar',
                  icon: Icons.people_alt_rounded,
                  accent: const Color(0xFF185FA5),
                  surface: const Color(0xFFE6F1FB),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _statCard({
    required String value,
    required String label,
    required IconData icon,
    required Color accent,
    required Color surface,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: marioCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: marioBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1,
              color: accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              height: 1.25,
              color: marioSub,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCard() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final dayNames = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
    final weekStr = _formatDate(weekStart);

    return _card(
      title: 'Haftalik jadval',
      icon: Icons.calendar_month_rounded,
      action: 'Smena +',
      onAction: () => _setTab(1),
      child: StreamBuilder<QuerySnapshot>(
        stream: _db
            .collection('shifts')
            .where('weekStart', isEqualTo: weekStr)
            .snapshots(),
        builder: (context, snapshot) {
          final shifts = snapshot.data?.docs ?? [];
          return Column(
            children: [
              Row(
                children: List.generate(7, (index) {
                  final date = weekStart.add(Duration(days: index));
                  final dateStr = _formatDate(date);
                  final count = shifts
                      .where((s) => (s.data() as Map)['date'] == dateStr)
                      .length;
                  final isToday = _isToday(date);
                  final isWeekend = date.weekday >= 6;

                  return Expanded(
                    child: Column(
                      children: [
                        Text(
                          dayNames[index],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isWeekend
                                ? const Color(0xFFD28A5A)
                                : marioSub,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: isToday ? marioRed : marioCream,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isToday ? Colors.white : marioText,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: count > 0 ? marioRed : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 54,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (index) {
                    final date = weekStart.add(Duration(days: index));
                    final dateStr = _formatDate(date);
                    final count = shifts
                        .where((s) => (s.data() as Map)['date'] == dateStr)
                        .length;
                    final isToday = _isToday(date);
                    const maxHeight = 42.0;
                    final barHeight = count > 0
                        ? (count / 8 * maxHeight).clamp(8.0, maxHeight)
                        : 5.0;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              count > 0 ? '$count' : '',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: isToday ? marioRed : marioSub,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: barHeight,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isToday
                                      ? [marioRed, marioRedDark]
                                      : [
                                    const Color(0xFFF2CEC1),
                                    const Color(0xFFE7B5A4)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTodayShiftsCard() {
    return _card(
      title: 'Bugungi smenalar',
      icon: Icons.access_time_filled_rounded,
      action: 'Barchasi',
      onAction: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AllShiftsScreen()),
        );
      },
      child: StreamBuilder<QuerySnapshot>(
        stream: _db
            .collection('shifts')
            .where('date', isEqualTo: _todayStr())
            .snapshots(),
        builder: (context, snapshot) {
          final shifts = snapshot.data?.docs ?? [];
          if (shifts.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22),
              decoration: BoxDecoration(
                color: marioCream,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'Bugun smena yo‘q',
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
            children: shifts.take(4).map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _miniWorkerRow(data, doc.id);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _miniWorkerRow(Map<String, dynamic> data, String docId) {
    final type = data['type'] ?? 'morning';
    final name = data['workerName'] ?? 'Ishchi';
    final start = data['startTime'] ?? '';
    final end = data['endTime'] ?? '';

    late final Color color;
    late final Color bg;
    late final String label;

    switch (type) {
      case 'night':
        color = const Color(0xFF534AB7);
        bg = const Color(0xFFEEEDFE);
        label = 'Tungi';
        break;
      case 'off':
        color = marioSub;
        bg = marioCream;
        label = 'Dam olish';
        break;
      case 'half':
        color = const Color(0xFF3B6D11);
        bg = const Color(0xFFEAF3DE);
        label = 'Yarim';
        break;
      default:
        color = marioRed;
        bg = marioLight;
        label = 'Kunduzgi';
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
          CircleAvatar(
            radius: 20,
            backgroundColor: bg,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: marioText,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        type == 'off' ? 'Dam olish kuni' : '$start - $end',
                        style: const TextStyle(
                          fontSize: 11,
                          color: marioSub,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _iconAction(
            icon: Icons.edit_outlined,
            color: marioRed,
            background: marioLight,
            onTap: () => _editShift(docId, data),
          ),
          const SizedBox(width: 6),
          _iconAction(
            icon: Icons.delete_outline_rounded,
            color: Colors.red,
            background: const Color(0xFFFCEBEB),
            onTap: () => _deleteShift(docId, name),
          ),
        ],
      ),
    );
  }

  Widget _iconAction({
    required IconData icon,
    required Color color,
    required Color background,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Future<void> _deleteShift(String docId, String workerName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Smenani o‘chirish'),
          content: Text(
            '$workerName ning smenasini o‘chirishni tasdiqlaysizmi?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Bekor',
                style: TextStyle(color: marioSub),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'O‘chirish',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _db.collection('shifts').doc(docId).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$workerName smenasi o‘chirildi'),
          backgroundColor: marioRed,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _editShift(String docId, Map<String, dynamic> data) {
    String selectedType = data['type'] ?? 'morning';

    final startParts = (data['startTime'] ?? '08:00').split(':');
    final endParts = (data['endTime'] ?? '17:00').split(':');

    TimeOfDay startTime = TimeOfDay(
      hour: int.tryParse(startParts[0]) ?? 8,
      minute: int.tryParse(startParts[1]) ?? 0,
    );
    TimeOfDay endTime = TimeOfDay(
      hour: int.tryParse(endParts[0]) ?? 17,
      minute: int.tryParse(endParts[1]) ?? 0,
    );
    bool loading = false;

    final shiftTypes = [
      ('morning', 'Kunduzgi', marioRed, marioLight),
      ('night', 'Tungi', const Color(0xFF534AB7), const Color(0xFFEEEDFE)),
      ('half', 'Yarim', const Color(0xFF3B6D11), const Color(0xFFEAF3DE)),
      ('off', 'Dam olish', marioSub, marioCream),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                18,
                20,
                MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8D1C6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Text(
                        'Smenani tahrirlash',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      _iconAction(
                        icon: Icons.delete_outline_rounded,
                        color: Colors.red,
                        background: const Color(0xFFFCEBEB),
                        onTap: () {
                          Navigator.pop(ctx);
                          _deleteShift(docId, data['workerName'] ?? 'Ishchi');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data['workerName'] ?? '',
                    style: const TextStyle(
                      color: marioSub,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Smena turi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: marioText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: shiftTypes.map((item) {
                      final isSelected = selectedType == item.$1;
                      return GestureDetector(
                        onTap: () => setSheet(() => selectedType = item.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? item.$3 : item.$4,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? item.$3
                                  : const Color(0xFFD7D0C5),
                            ),
                          ),
                          child: Text(
                            item.$2,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : item.$3,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (selectedType != 'off') ...[
                    const SizedBox(height: 18),
                    const Text(
                      'Vaqt',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: marioText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _timeBox(
                            title: 'Boshlanish',
                            time: startTime,
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: ctx,
                                initialTime: startTime,
                                builder: (c, child) {
                                  return Theme(
                                    data: Theme.of(c).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: marioRed,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setSheet(() => startTime = picked);
                              }
                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: Color(0xFFB6AEA3),
                          ),
                        ),
                        Expanded(
                          child: _timeBox(
                            title: 'Tugash',
                            time: endTime,
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: ctx,
                                initialTime: endTime,
                                builder: (c, child) {
                                  return Theme(
                                    data: Theme.of(c).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: marioRed,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setSheet(() => endTime = picked);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: loading
                          ? null
                          : () async {
                        setSheet(() => loading = true);
                        await _db.collection('shifts').doc(docId).update({
                          'type': selectedType,
                          'startTime': selectedType == 'off'
                              ? ''
                              : '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                          'endTime': selectedType == 'off'
                              ? ''
                              : '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                        });
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                        }
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Smena yangilandi'),
                            backgroundColor: marioRed,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: marioRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        'Saqlash',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _timeBox({
    required String title,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: marioCream,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD7D0C5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: marioSub,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: marioText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      (
      Icons.add_circle_outline_rounded,
      'Smena qo‘shish',
      marioRed,
      marioLight,
          () => _setTab(1),
      ),
      (
      Icons.person_add_alt_1_outlined,
      'Ishchi qo‘shish',
      const Color(0xFF185FA5),
      const Color(0xFFE6F1FB),
          () => _setTab(2),
      ),
      (
      Icons.copy_all_rounded,
      'Hafta nusxasi',
      const Color(0xFF3B6D11),
      const Color(0xFFEAF3DE),
      _copyWeekShifts,
      ),
      (
      Icons.swap_horizontal_circle_outlined,
      'Almashtirish',
      const Color(0xFF534AB7),
      const Color(0xFFEEEDFE),
          () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SwapApprovalScreen()),
        );
      },
      ),
      (
      Icons.notifications_active_outlined,
      'Ertangi eslatma',
      const Color(0xFFB8860B),
      const Color(0xFFFFF3CD),
      _sendTomorrowReminder,
      ),
      (
      Icons.download_rounded,
      'Excel export',
      const Color(0xFF0D8B64),
      const Color(0xFFDCF7EC),
      _exportExcel,
      ),
    ];

    return _card(
      title: 'Tezkor amallar',
      icon: Icons.flash_on_rounded,
      child: GridView.builder(
        itemCount: actions.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.45,
        ),
        itemBuilder: (context, index) {
          final item = actions[index];
          return GestureDetector(
            onTap: item.$5,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: item.$4,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.$1, color: item.$3, size: 20),
                  ),
                  const Spacer(),
                  Text(
                    item.$2,
                    style: TextStyle(
                      color: item.$3,
                      fontSize: 13,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _sendTomorrowReminder() async {
    HapticFeedback.lightImpact();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Ertangi eslatma'),
          content: const Text(
            'Barcha ishchilarga ertangi smena haqida bildiruv yuborilsinmi?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Bekor'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Yuborish',
                style: TextStyle(
                  color: marioRed,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 10),
            Text('Eslatmalar yuborilmoqda...'),
          ],
        ),
        backgroundColor: marioRed,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    await NotificationService.sendAllTomorrowReminders();

    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Barcha eslatmalar yuborildi'),
          ],
        ),
        backgroundColor: const Color(0xFF3B6D11),
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return _card(
      title: 'Bildirishnomalar',
      icon: Icons.notifications_outlined,
      action: 'Barchasi',
      onAction: _showNotifications,
      child: Column(
        children: [
          _notifRow(
            'Ali Valiyev smena almashtirish so‘radi',
            '5 daqiqa',
            true,
          ),
          _notifRow('Sardor Umarov qo‘shildi', '1 soat', true),
          _notifRow('Juma smenasi tasdiqlandi', '3 soat', false),
        ],
      ),
    );
  }

  Widget _notifRow(String text, String time, bool unread) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unread ? const Color(0xFFFFF6F1) : marioCream,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: unread ? marioRed : marioBorder,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12,
                    color: marioText,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$time oldin',
                  style: const TextStyle(
                    fontSize: 11,
                    color: marioSub,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddShiftBtn() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _setTab(1);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [marioRed, marioRedDark],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: marioRed.withOpacity(0.28),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.add_circle_rounded, color: Colors.white, size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Yangi smena qo‘shish',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsTab() {
    final now = DateTime.now();
    final monthStart =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
    final monthEnd =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-31';

    return StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection('shifts')
          .where('date', isGreaterThanOrEqualTo: monthStart)
          .where('date', isLessThanOrEqualTo: monthEnd)
          .snapshots(),
      builder: (context, snapshot) {
        final shifts = snapshot.data?.docs ?? [];
        final morning = shifts
            .where((s) => (s.data() as Map)['type'] == 'morning')
            .length;
        final night = shifts
            .where((s) => (s.data() as Map)['type'] == 'night')
            .length;
        final off =
            shifts.where((s) => (s.data() as Map)['type'] == 'off').length;
        final half =
            shifts.where((s) => (s.data() as Map)['type'] == 'half').length;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [marioRed, marioRedDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: marioRed.withOpacity(0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _monthName(now.month).toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.76),
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${shifts.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Jami smenalar',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 138,
                ),
                children: [
                  _statCard(
                    value: '$morning',
                    label: 'Kunduzgi',
                    icon: Icons.wb_sunny_rounded,
                    accent: marioRed,
                    surface: marioLight,
                  ),
                  _statCard(
                    value: '$night',
                    label: 'Tungi',
                    icon: Icons.nightlight_round,
                    accent: const Color(0xFF534AB7),
                    surface: const Color(0xFFEEEDFE),
                  ),
                  _statCard(
                    value: '$half',
                    label: 'Yarim smena',
                    icon: Icons.timelapse_rounded,
                    accent: const Color(0xFF3B6D11),
                    surface: const Color(0xFFEAF3DE),
                  ),
                  _statCard(
                    value: '$off',
                    label: 'Dam olish',
                    icon: Icons.weekend_rounded,
                    accent: marioSub,
                    surface: marioCream,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _card({
    required String title,
    required IconData icon,
    required Widget child,
    String? action,
    VoidCallback? onAction,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: marioCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: marioBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: marioLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 16, color: marioRed),
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
                if (action != null)
                  GestureDetector(
                    onTap: onAction,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: marioCream,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        action,
                        style: const TextStyle(
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

  String _todayStr() => _formatDate(DateTime.now());

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _monthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  void _copyWeekShifts() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.copy_rounded, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('Jadval nusxalanmoqda...'),
          ],
        ),
        backgroundColor: marioRed,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(14),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _exportExcel() async {
    HapticFeedback.lightImpact();

    final now = DateTime.now();
    int selectedMonth = now.month;
    int selectedYear = now.year;

    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialog) {
            return AlertDialog(
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Text(
                'Excel eksport',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Qaysi oyni eksport qilamiz?',
                    style: TextStyle(color: marioSub),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<int>(
                          value: selectedMonth,
                          isExpanded: true,
                          items: List.generate(12, (index) {
                            const names = [
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
                            return DropdownMenuItem(
                              value: index + 1,
                              child: Text(names[index]),
                            );
                          }),
                          onChanged: (value) =>
                              setDialog(() => selectedMonth = value!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButton<int>(
                          value: selectedYear,
                          isExpanded: true,
                          items: [2025, 2026, 2027]
                              .map(
                                (year) => DropdownMenuItem(
                              value: year,
                              child: Text('$year'),
                            ),
                          )
                              .toList(),
                          onChanged: (value) =>
                              setDialog(() => selectedYear = value!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Bekor',
                    style: TextStyle(color: marioSub),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx, {
                      'month': selectedMonth,
                      'year': selectedYear,
                    });
                  },
                  child: const Text(
                    'Eksport',
                    style: TextStyle(
                      color: marioRed,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 10),
            Text('Excel fayli yaratilmoqda...'),
          ],
        ),
        backgroundColor: marioRed,
        duration: const Duration(seconds: 30),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(14),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    final path = await ExcelService.exportMonthlyShifts(
      year: result['year']!,
      month: result['month']!,
      onProgress: (message) => debugPrint(message),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (path != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Excel fayli tayyor! Ochish uchun bosing'),
            ],
          ),
          backgroundColor: const Color(0xFF3B6D11),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(14),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: 'Ochish',
            textColor: Colors.white,
            onPressed: () => ExcelService.openFile(path),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Xatolik yuz berdi'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(14),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: marioCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: marioBorder,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 18),
              const Row(
                children: [
                  Text(
                    'Bildirishnomalar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: marioText,
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Hammasi o‘qildi',
                    style: TextStyle(
                      fontSize: 12,
                      color: marioRed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _notifRow(
                'Ali Valiyev smena almashtirish so‘radi',
                '5 daqiqa',
                true,
              ),
              _notifRow('Sardor Umarov qo‘shildi', '1 soat', true),
              _notifRow('Juma smenasi tasdiqlandi', '3 soat', false),
            ],
          ),
        );
      },
    );
  }

  void _showProfile() {
    final auth = Provider.of<AuthService>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: marioCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: marioBorder,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [marioLight, Color(0xFFFFEEE7)],
                  ),
                  shape: BoxShape.circle,
                  border:
                  Border.all(color: marioRed.withOpacity(0.2), width: 2),
                ),
                child: Center(
                  child: Text(
                    (auth.userName ?? 'A')[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: marioRed,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                auth.userName ?? 'Admin',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: marioText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                auth.user?.email ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  color: marioSub,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await auth.logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: marioRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text(
                    'Chiqish',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}