import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllShiftsScreen extends StatefulWidget {
  const AllShiftsScreen({super.key});

  @override
  State<AllShiftsScreen> createState() => _AllShiftsScreenState();
}

class _AllShiftsScreenState extends State<AllShiftsScreen> {
  static const marioRed = Color(0xFFC0392B);
  static const marioCream = Color(0xFFF1EFE8);
  static const marioBg = Color(0xFFF5F4EF);
  static const marioCard = Color(0xFFFFFFFF);
  static const marioBorder = Color(0xFFE8E5DF);
  static const marioText = Color(0xFF1E1C1A);
  static const marioSub = Color(0xFF888780);
  static const marioLight = Color(0xFFFAECE7);

  final _db = FirebaseFirestore.instance;

  // Filterlash
  String _filterType = 'all'; // all, morning, night, half, off
  late DateTime _weekStart;
  String? _filterWorkerId;
  String? _filterWorkerName;

  final _months = ['yanvar','fevral','mart','aprel','may','iyun',
    'iyul','avgust','sentabr','oktabr','noyabr','dekabr'];
  final _fullDays = ['Dushanba','Seshanba','Chorshanba',
    'Payshanba','Juma','Shanba','Yakshanba'];
  final _dayNames = ['Du','Se','Ch','Pa','Ju','Sh','Ya'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final ws = now.subtract(Duration(days: now.weekday - 1));
    _weekStart = DateTime(ws.year, ws.month, ws.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: marioBg,
      body: Column(
        children: [
          _buildHeader(),
          _buildBreadStrip(),
          _buildWeekNav(),
          _buildFilterChips(),
          Expanded(child: _buildShiftsList()),
        ],
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: marioRed,
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 12, 20, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Barcha smenalar',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              Text('Hafta bo\'yicha ko\'rish',
                  style: TextStyle(
                      color: Colors.white60, fontSize: 12)),
            ],
          ),
          const Spacer(),
          // Ishchi filter
          GestureDetector(
            onTap: _showWorkerFilter,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _filterWorkerName ?? 'Barchasi',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── BREAD STRIP ──────────────────────────────────────────
  Widget _buildBreadStrip() {
    return SizedBox(
      height: 5,
      child: Row(
        children: List.generate(60,
              (i) => Expanded(
            child: Container(
              color: i.isEven
                  ? const Color(0xFFE8A87C)
                  : const Color(0xFFD4956A),
            ),
          ),
        ),
      ),
    );
  }

  // ── HAFTA NAVIGATSIYA ────────────────────────────────────
  Widget _buildWeekNav() {
    return Container(
      color: marioCard,
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _navBtn(Icons.chevron_left, () {
            setState(() {
              _weekStart =
                  _weekStart.subtract(const Duration(days: 7));
            });
          }),
          Expanded(
            child: Column(
              children: [
                Text(
                  '${_weekStart.day} – '
                      '${_weekStart.add(const Duration(days: 6)).day} '
                      '${_months[_weekStart.month - 1]}',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: marioText),
                  textAlign: TextAlign.center,
                ),
                Text(
                  _isCurrentWeek() ? 'Joriy hafta' :
                  _weekStart.isBefore(DateTime.now())
                      ? 'O\'tgan hafta'
                      : 'Keyingi hafta',
                  style: const TextStyle(
                      fontSize: 11, color: marioSub),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          _navBtn(Icons.chevron_right, () {
            setState(() {
              _weekStart =
                  _weekStart.add(const Duration(days: 7));
            });
          }),
        ],
      ),
    );
  }

  // ── FILTER CHIPS ─────────────────────────────────────────
  Widget _buildFilterChips() {
    final filters = [
      {'key': 'all', 'label': 'Barchasi',
        'color': marioText, 'bg': marioCream},
      {'key': 'morning', 'label': 'Kunduzgi',
        'color': marioRed, 'bg': marioLight},
      {'key': 'night', 'label': 'Tungi',
        'color': const Color(0xFF534AB7),
        'bg': const Color(0xFFEEEDFE)},
      {'key': 'half', 'label': 'Yarim',
        'color': const Color(0xFF3B6D11),
        'bg': const Color(0xFFEAF3DE)},
      {'key': 'off', 'label': 'Dam olish',
        'color': marioSub, 'bg': marioCream},
    ];

    return Container(
      color: marioCard,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final selected = _filterType == f['key'];
            final color = f['color'] as Color;
            final bg = f['bg'] as Color;
            return GestureDetector(
              onTap: () =>
                  setState(() => _filterType = f['key'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? color : bg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? color : marioBorder,
                    width: selected ? 1.5 : 0.5,
                  ),
                ),
                child: Text(
                  f['label'] as String,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : color),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── SMENALAR RO'YXATI ────────────────────────────────────
  Widget _buildShiftsList() {
    final weekStr = _formatDate(_weekStart);

    Query query = _db
        .collection('shifts')
        .where('weekStart', isEqualTo: weekStr);

    if (_filterWorkerId != null) {
      query = query.where('workerId', isEqualTo: _filterWorkerId);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: marioRed));
        }

        var docs = snapshot.data?.docs ?? [];

        // Type filter
        if (_filterType != 'all') {
          docs = docs.where((d) =>
          (d.data() as Map)['type'] == _filterType).toList();
        }

        // Sana bo'yicha sort
        docs.sort((a, b) {
          final aDate = (a.data() as Map)['date'] as String? ?? '';
          final bDate = (b.data() as Map)['date'] as String? ?? '';
          return aDate.compareTo(bDate);
        });

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 52, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                const Text('Smena topilmadi',
                    style: TextStyle(
                        color: marioSub, fontSize: 14)),
              ],
            ),
          );
        }

        // Kunlar bo'yicha guruhlash
        final Map<String, List<QueryDocumentSnapshot>> grouped = {};
        for (final doc in docs) {
          final date =
              (doc.data() as Map)['date'] as String? ?? '';
          grouped.putIfAbsent(date, () => []).add(doc);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: grouped.length,
          itemBuilder: (_, i) {
            final dateStr = grouped.keys.elementAt(i);
            final dayDocs = grouped[dateStr]!;
            return _buildDayGroup(dateStr, dayDocs);
          },
        );
      },
    );
  }

  // ── KUN GURUHI ───────────────────────────────────────────
  Widget _buildDayGroup(
      String dateStr, List<QueryDocumentSnapshot> docs) {
    DateTime? date;
    try {
      final parts = dateStr.split('-');
      date = DateTime(int.parse(parts[0]),
          int.parse(parts[1]), int.parse(parts[2]));
    } catch (_) {}

    final isToday = date != null && _isToday(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kun sarlavhasi
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: isToday ? marioRed : marioCream,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    date != null ? '${date.day}' : '-',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isToday
                            ? Colors.white
                            : marioText),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        date != null
                            ? _fullDays[date.weekday - 1]
                            : dateStr,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isToday
                                ? marioRed
                                : marioText),
                      ),
                      if (isToday) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: marioRed,
                            borderRadius:
                            BorderRadius.circular(20),
                          ),
                          child: const Text('Bugun',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '${docs.length} ta smena',
                    style: const TextStyle(
                        fontSize: 11, color: marioSub),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: marioCream,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${docs.length} ishchi',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: marioSub),
                ),
              ),
            ],
          ),
        ),

        // Smenalar
        ...docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return _buildShiftTile(doc.id, data);
        }),

        const SizedBox(height: 8),
        const Divider(height: 1, thickness: 0.5,
            color: marioBorder),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── SMENA TILE ───────────────────────────────────────────
  Widget _buildShiftTile(
      String docId, Map<String, dynamic> data) {
    final type = data['type'] ?? 'morning';
    final name = data['workerName'] ?? 'Ishchi';
    final start = data['startTime'] ?? '';
    final end = data['endTime'] ?? '';

    Color accentColor;
    Color bgColor;
    String typeLabel;
    IconData typeIcon;

    switch (type) {
      case 'night':
        accentColor = const Color(0xFF534AB7);
        bgColor = const Color(0xFFEEEDFE);
        typeLabel = 'Tungi';
        typeIcon = Icons.nightlight_outlined;
        break;
      case 'off':
        accentColor = marioSub;
        bgColor = marioCream;
        typeLabel = 'Dam olish';
        typeIcon = Icons.weekend_outlined;
        break;
      case 'half':
        accentColor = const Color(0xFF3B6D11);
        bgColor = const Color(0xFFEAF3DE);
        typeLabel = 'Yarim';
        typeIcon = Icons.timelapse_outlined;
        break;
      default:
        accentColor = marioRed;
        bgColor = marioLight;
        typeLabel = 'Kunduzgi';
        typeIcon = Icons.wb_sunny_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: marioCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: marioBorder, width: 0.5),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: bgColor,
                      child: Text(
                        name.isNotEmpty
                            ? name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: marioText)),
                          Text(
                            type == 'off'
                                ? 'Dam olish'
                                : '$start – $end',
                            style: const TextStyle(
                                fontSize: 11,
                                color: marioSub),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(typeIcon,
                              size: 11, color: accentColor),
                          const SizedBox(width: 3),
                          Text(typeLabel,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: accentColor)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tahrirlash
                    GestureDetector(
                      onTap: () => _editShift(docId, data),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: marioLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.edit_outlined,
                            size: 14, color: marioRed),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // O'chirish
                    GestureDetector(
                      onTap: () => _deleteShift(
                          docId, name),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCEBEB),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.delete_outline,
                            size: 14, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ISHCHI FILTER ────────────────────────────────────────
  void _showWorkerFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: marioCard,
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: marioBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Ishchi tanlash',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: marioText)),
            const SizedBox(height: 12),
            // Barchasi
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: _filterWorkerId == null
                    ? marioRed
                    : marioCream,
                child: Icon(Icons.people_outline,
                    color: _filterWorkerId == null
                        ? Colors.white
                        : marioSub,
                    size: 18),
              ),
              title: const Text('Barcha ishchilar',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: marioText)),
              trailing: _filterWorkerId == null
                  ? const Icon(Icons.check_circle_rounded,
                  color: marioRed)
                  : null,
              onTap: () {
                setState(() {
                  _filterWorkerId = null;
                  _filterWorkerName = null;
                });
                Navigator.pop(context);
              },
            ),
            const Divider(color: marioBorder),
            // Ishchilar ro'yxati
            StreamBuilder<QuerySnapshot>(
              stream: _db
                  .collection('users')
                  .where('role', isEqualTo: 'worker')
                  .snapshots(),
              builder: (context, snap) {
                final workers = snap.data?.docs ?? [];
                return SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: workers.length,
                    itemBuilder: (_, i) {
                      final data = workers[i].data()
                      as Map<String, dynamic>;
                      final name = data['name'] ?? 'Ishchi';
                      final uid = workers[i].id;
                      final selected = _filterWorkerId == uid;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: selected
                              ? marioRed
                              : marioLight,
                          child: Text(
                            name[0].toUpperCase(),
                            style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : marioRed,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        title: Text(name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: marioText)),
                        trailing: selected
                            ? const Icon(
                            Icons.check_circle_rounded,
                            color: marioRed)
                            : null,
                        onTap: () {
                          setState(() {
                            _filterWorkerId = uid;
                            _filterWorkerName = name;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── O'CHIRISH ────────────────────────────────────────────
  Future<void> _deleteShift(
      String docId, String workerName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Smenani o\'chirish'),
        content:
        Text('$workerName ning smenasini o\'chirasizmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Bekor',
                style: TextStyle(color: marioSub)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('O\'chirish',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _db.collection('shifts').doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$workerName smenasi o\'chirildi'),
            backgroundColor: marioRed,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  // ── TAHRIRLASH ───────────────────────────────────────────
  void _editShift(String docId, Map<String, dynamic> data) {
    String selectedType = data['type'] ?? 'morning';
    final sp = (data['startTime'] ?? '08:00').split(':');
    final ep = (data['endTime'] ?? '17:00').split(':');
    TimeOfDay startTime = TimeOfDay(
        hour: int.tryParse(sp[0]) ?? 8,
        minute: int.tryParse(sp[1]) ?? 0);
    TimeOfDay endTime = TimeOfDay(
        hour: int.tryParse(ep[0]) ?? 17,
        minute: int.tryParse(ep[1]) ?? 0);
    bool loading = false;

    final types = [
      {'key': 'morning', 'label': 'Kunduzgi',
        'color': marioRed, 'bg': marioLight},
      {'key': 'night', 'label': 'Tungi',
        'color': const Color(0xFF534AB7),
        'bg': const Color(0xFFEEEDFE)},
      {'key': 'half', 'label': 'Yarim',
        'color': const Color(0xFF3B6D11),
        'bg': const Color(0xFFEAF3DE)},
      {'key': 'off', 'label': 'Dam olish',
        'color': marioSub, 'bg': marioCream},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          decoration: const BoxDecoration(
            color: marioCard,
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(
              20, 12, 20,
              MediaQuery.of(ctx).viewInsets.bottom + 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: marioBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Text('Tahrirlash',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: marioText)),
                        Text(data['workerName'] ?? '',
                            style: const TextStyle(
                                fontSize: 13,
                                color: marioSub)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _deleteShift(
                          docId, data['workerName'] ?? '');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCEBEB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_outline,
                          color: Colors.red, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tur
              Row(
                children: types.map((t) {
                  final sel = selectedType == t['key'];
                  final c = t['color'] as Color;
                  final b = t['bg'] as Color;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setSheet(
                              () => selectedType = t['key'] as String),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                            vertical: 9),
                        decoration: BoxDecoration(
                          color: sel ? c : b,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: sel ? c : marioBorder,
                            width: sel ? 1.5 : 0.5,
                          ),
                        ),
                        child: Text(t['label'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color:
                                sel ? Colors.white : c)),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Vaqt
              if (selectedType != 'off') ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final p = await showTimePicker(
                            context: ctx,
                            initialTime: startTime,
                            builder: (c, ch) => Theme(
                              data: Theme.of(c).copyWith(
                                colorScheme:
                                const ColorScheme.light(
                                    primary: marioRed),
                              ),
                              child: ch!,
                            ),
                          );
                          if (p != null) {
                            setSheet(() => startTime = p);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: marioCream,
                            borderRadius:
                            BorderRadius.circular(10),
                            border: Border.all(
                                color: marioBorder),
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Text('Boshlanish',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: marioSub)),
                              const SizedBox(height: 4),
                              Text(
                                '${startTime.hour.toString().padLeft(2, '0')}:'
                                    '${startTime.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: marioText),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10),
                      child: Icon(Icons.arrow_forward,
                          color: marioSub, size: 16),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final p = await showTimePicker(
                            context: ctx,
                            initialTime: endTime,
                            builder: (c, ch) => Theme(
                              data: Theme.of(c).copyWith(
                                colorScheme:
                                const ColorScheme.light(
                                    primary: marioRed),
                              ),
                              child: ch!,
                            ),
                          );
                          if (p != null) {
                            setSheet(() => endTime = p);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: marioCream,
                            borderRadius:
                            BorderRadius.circular(10),
                            border: Border.all(
                                color: marioBorder),
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Text('Tugash',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: marioSub)),
                              const SizedBox(height: 4),
                              Text(
                                '${endTime.hour.toString().padLeft(2, '0')}:'
                                    '${endTime.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: marioText),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: loading
                      ? null
                      : () async {
                    setSheet(() => loading = true);
                    await _db
                        .collection('shifts')
                        .doc(docId)
                        .update({
                      'type': selectedType,
                      'startTime':
                      selectedType == 'off'
                          ? ''
                          : '${startTime.hour.toString().padLeft(2, '0')}:'
                          '${startTime.minute.toString().padLeft(2, '0')}',
                      'endTime':
                      selectedType == 'off'
                          ? ''
                          : '${endTime.hour.toString().padLeft(2, '0')}:'
                          '${endTime.minute.toString().padLeft(2, '0')}',
                    });
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(
                        content: const Text(
                            'Smena yangilandi ✓'),
                        backgroundColor: marioRed,
                        behavior:
                        SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12)),
                      ));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: marioRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: loading
                      ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2))
                      : const Text('Saqlash',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── YORDAMCHI ────────────────────────────────────────────
  Widget _navBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: marioCream,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: marioSub, size: 20),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isCurrentWeek() {
    final now = DateTime.now();
    final ws = now.subtract(Duration(days: now.weekday - 1));
    final cur = DateTime(ws.year, ws.month, ws.day);
    return _weekStart == cur;
  }
}