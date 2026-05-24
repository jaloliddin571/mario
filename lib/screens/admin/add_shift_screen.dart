import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/notification_service.dart';

// ─────────────────────────────────────────────
//  ENUMS
// ─────────────────────────────────────────────

enum ShiftType { morning, night, half, off }

extension ShiftTypeExt on ShiftType {
  String get label {
    switch (this) {
      case ShiftType.morning: return 'Kunduzgi';
      case ShiftType.night:   return 'Tungi';
      case ShiftType.half:    return 'Yarim';
      case ShiftType.off:     return 'Dam olish';
    }
  }
  String get emoji {
    switch (this) {
      case ShiftType.morning: return '🌅';
      case ShiftType.night:   return '🌙';
      case ShiftType.half:    return '⏱';
      case ShiftType.off:     return '🌿';
    }
  }
  String get startTime {
    switch (this) {
      case ShiftType.morning: return '08:00';
      case ShiftType.night:   return '22:00';
      case ShiftType.half:    return '08:00';
      case ShiftType.off:     return '—';
    }
  }
  String get endTime {
    switch (this) {
      case ShiftType.morning: return '17:00';
      case ShiftType.night:   return '06:00';
      case ShiftType.half:    return '13:00';
      case ShiftType.off:     return '—';
    }
  }
  String get firestoreKey {
    switch (this) {
      case ShiftType.morning: return 'morning';
      case ShiftType.night:   return 'night';
      case ShiftType.half:    return 'half';
      case ShiftType.off:     return 'off';
    }
  }
  Color get color {
    switch (this) {
      case ShiftType.morning: return const Color(0xFFC0392B);
      case ShiftType.night:   return const Color(0xFF534AB7);
      case ShiftType.half:    return const Color(0xFF3B6D11);
      case ShiftType.off:     return const Color(0xFF5F5E5A);
    }
  }
  Color get badgeBg {
    switch (this) {
      case ShiftType.morning: return const Color(0xFFFAECE7);
      case ShiftType.night:   return const Color(0xFFEEEDFE);
      case ShiftType.half:    return const Color(0xFFEAF3DE);
      case ShiftType.off:     return const Color(0xFFF1EFE8);
    }
  }
  Color get badgeText {
    switch (this) {
      case ShiftType.morning: return const Color(0xFF993C1D);
      case ShiftType.night:   return const Color(0xFF3C3489);
      case ShiftType.half:    return const Color(0xFF27500A);
      case ShiftType.off:     return const Color(0xFF444441);
    }
  }
  String get duration {
    switch (this) {
      case ShiftType.morning: return '9 soat ishlash vaqti';
      case ShiftType.night:   return '8 soat ishlash vaqti';
      case ShiftType.half:    return '5 soat ishlash vaqti';
      case ShiftType.off:     return 'Dam olish kuni';
    }
  }
  static ShiftType fromString(String s) {
    switch (s) {
      case 'night': return ShiftType.night;
      case 'half':  return ShiftType.half;
      case 'off':   return ShiftType.off;
      default:      return ShiftType.morning;
    }
  }
}

// ─────────────────────────────────────────────
//  MODELS
// ─────────────────────────────────────────────

class WorkerModel {
  final String id;
  final String name;
  final String initials;

  WorkerModel({required this.id, required this.name, required this.initials});

  factory WorkerModel.fromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = (data['name'] ?? data['displayName'] ?? 'Ishchi') as String;
    final raw = name.trim();
    final parts = raw.split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : raw.substring(0, raw.length >= 2 ? 2 : raw.length).toUpperCase();
    return WorkerModel(id: doc.id, name: raw, initials: initials);
  }
}

class ConflictInfo {
  final WorkerModel worker;
  final DateTime date;
  final ShiftType existingType;
  final String existingStart;
  final String existingEnd;

  ConflictInfo({
    required this.worker,
    required this.date,
    required this.existingType,
    required this.existingStart,
    required this.existingEnd,
  });
}

// ─────────────────────────────────────────────
//  COLORS
// ─────────────────────────────────────────────

const kRed      = Color(0xFFC0392B);
const kRedLight = Color(0xFFFAECE7);
const kRedMid   = Color(0xFFF5C4B3);
const kRedDark  = Color(0xFF993C1D);

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────

class AddShiftScreen extends StatefulWidget {
  final bool embedded;
  const AddShiftScreen({super.key, this.embedded = false});

  @override
  State<AddShiftScreen> createState() => _AddShiftScreenState();
}

class _AddShiftScreenState extends State<AddShiftScreen> {
  final _db = FirebaseFirestore.instance;

  List<WorkerModel> _workers = [];
  bool _loadingWorkers = true;
  WorkerModel? _selectedWorker;
  ShiftType _selectedType = ShiftType.morning;
  final Set<DateTime> _selectedDays = {};
  DateTime _viewMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  bool _saving = false;

  List<ConflictInfo> _conflicts = [];
  // key = 'workerId_YYYY-MM-DD', value = 'skip' | 'replace'
  final Map<String, String> _resolutions = {};

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  // ── Firestore ─────────────────────────────

  Future<void> _loadWorkers() async {
    try {
      final snap = await _db
          .collection('users')
          .where('role', isEqualTo: 'worker')
          .get();
      if (!mounted) return;
      setState(() {
        _workers = snap.docs.map((d) => WorkerModel.fromDoc(d)).toList();
        _loadingWorkers = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingWorkers = false);
    }
  }

  Future<void> _checkConflicts() async {
    if (_selectedWorker == null || _selectedDays.isEmpty) {
      setState(() => _conflicts = []);
      return;
    }
    final found = <ConflictInfo>[];
    for (final day in _selectedDays) {
      final dateStr = _fmt(day);
      final key = '${_selectedWorker!.id}_$dateStr';
      if (_resolutions.containsKey(key)) continue;
      final snap = await _db
          .collection('shifts')
          .where('workerId', isEqualTo: _selectedWorker!.id)
          .where('date', isEqualTo: dateStr)
          .get();
      for (final doc in snap.docs) {
        final data = doc.data();
        found.add(ConflictInfo(
          worker: _selectedWorker!,
          date: day,
          existingType: ShiftTypeExt.fromString(data['type'] ?? ''),
          existingStart: data['startTime'] ?? '',
          existingEnd: data['endTime'] ?? '',
        ));
      }
    }
    if (mounted) setState(() => _conflicts = found);
  }

  Future<void> _saveShifts() async {
    if (_selectedWorker == null || _selectedDays.isEmpty) return;
    setState(() => _saving = true);

    try {
      final batch = _db.batch();
      int saved = 0;
      final now = DateTime.now();
      final ws = now.subtract(Duration(days: now.weekday - 1));
      final weekStartStr = _fmt(ws);

      for (final day in _selectedDays.toList()..sort()) {
        final dateStr = _fmt(day);
        final key = '${_selectedWorker!.id}_$dateStr';

        if (_resolutions[key] == 'skip') continue;

        // Replace: eski smenani o'chirish
        if (_resolutions[key] == 'replace') {
          final oldSnap = await _db
              .collection('shifts')
              .where('workerId', isEqualTo: _selectedWorker!.id)
              .where('date', isEqualTo: dateStr)
              .get();
          for (final old in oldSnap.docs) {
            batch.delete(old.reference);
          }
        }

        final ref = _db.collection('shifts').doc();
        batch.set(ref, {
          'workerId':   _selectedWorker!.id,
          'workerName': _selectedWorker!.name,
          'date':       dateStr,
          'weekStart':  weekStartStr,
          'type':       _selectedType.firestoreKey,
          'startTime':  _selectedType == ShiftType.off ? '' : _selectedType.startTime,
          'endTime':    _selectedType == ShiftType.off ? '' : _selectedType.endTime,
          'createdAt':  FieldValue.serverTimestamp(),
        });
        saved++;
      }

      await batch.commit();
      // 🔥 BILDIRUV YUBORISH
      for (final day in _selectedDays) {

        final dateStr = _fmt(day);

        await NotificationService.sendNewShiftNotification(
          workerId: _selectedWorker!.id,
          workerName: _selectedWorker!.name,
          shiftType: _selectedType.firestoreKey,
          date: dateStr,

          startTime:
          _selectedType == ShiftType.off
              ? ''
              : _selectedType.startTime,

          endTime:
          _selectedType == ShiftType.off
              ? ''
              : _selectedType.endTime,
        );
      }

      if (!mounted) return;
      setState(() {
        _saving = false;
        _selectedDays.clear();
        _resolutions.clear();
        _conflicts.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$saved ta smena saqlandi ✓'),
        backgroundColor: kRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Xatolik: $e'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  // ── Helpers ───────────────────────────────

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int get _effectiveCount {
    int c = _selectedDays.length;
    for (final v in _resolutions.values) {
      if (v == 'skip') c--;
    }
    return c;
  }

  bool get _hasUnresolved => _conflicts.isNotEmpty;

  void _toggleDay(DateTime day) {
    final now = DateTime.now();
    if (day.isBefore(DateTime(now.year, now.month, now.day))) return;
    setState(() {
      if (_selectedDays.any((d) => _sameDay(d, day))) {
        _selectedDays.removeWhere((d) => _sameDay(d, day));
        if (_selectedWorker != null) {
          final k = '${_selectedWorker!.id}_${_fmt(day)}';
          _resolutions.remove(k);
          _conflicts.removeWhere((c) => _sameDay(c.date, day));
        }
      } else {
        _selectedDays.add(day);
      }
    });
    _checkConflicts();
  }

  void _resolveConflict(ConflictInfo c, String resolution) {
    final key = '${c.worker.id}_${_fmt(c.date)}';
    setState(() {
      _resolutions[key] = resolution;
      _conflicts.removeWhere(
              (x) => x.worker.id == c.worker.id && _sameDay(x.date, c.date));
    });
  }

  void _addDays(Iterable<DateTime> days) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    setState(() {
      for (final d in days) {
        if (!d.isBefore(today)) _selectedDays.add(d);
      }
    });
    _checkConflicts();
  }

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1EC),
      body: Column(
        children: [
          if (!widget.embedded) _buildHeader(),
          if (!widget.embedded) _buildBreadcrumb(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(14),
              children: [
                _sectionWorker(),
                const SizedBox(height: 12),
                _sectionShiftType(),
                const SizedBox(height: 12),
                _sectionTime(),
                const SizedBox(height: 12),
                _sectionCalendar(),
                if (_conflicts.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _sectionConflict(),
                ],
                const SizedBox(height: 12),
                _sectionPreview(),
                const SizedBox(height: 12),
                _buildSaveBtn(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Container(
        color: kRed,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Smena qo'shish",
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500)),
                Text('Mario fabrika smena tizimi',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumb() {
    return SizedBox(
      height: 5,
      child: Row(
        children: List.generate(20, (i) => Expanded(
          child: Container(
            color: i.isEven ? const Color(0xFFE8A87C) : const Color(0xFFD4956A),
          ),
        )),
      ),
    );
  }

  // ── Card wrapper ──────────────────────────

  Widget _card({
    required IconData icon,
    required String title,
    String? badge,
    required Widget body,
    EdgeInsets padding = const EdgeInsets.all(14),
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.08), width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.08), width: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(color: kRedLight, borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: kRed, size: 15),
                ),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A))),
                if (badge != null) ...[
                  const Spacer(),
                  Text(badge, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kRed)),
                ],
              ],
            ),
          ),
          Padding(padding: padding, child: body),
        ],
      ),
    );
  }

  // ── 1. Worker ─────────────────────────────

  Widget _sectionWorker() {
    return _card(
      icon: Icons.person_outline,
      title: 'Ishchi tanlash',
      badge: _selectedWorker != null ? '1 tanlangan' : '0 tanlangan',
      body: _loadingWorkers
          ? const Center(child: Padding(
        padding: EdgeInsets.all(8),
        child: CircularProgressIndicator(color: kRed, strokeWidth: 2),
      ))
          : _workers.isEmpty
          ? const Text('Ishchilar topilmadi',
          style: TextStyle(fontSize: 12, color: Color(0xFF888888)))
          : Wrap(
        spacing: 6,
        runSpacing: 6,
        children: _workers.map((w) {
          final sel = _selectedWorker?.id == w.id;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedWorker = sel ? null : w;
                _resolutions.clear();
                _conflicts.clear();
              });
              _checkConflicts();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: sel ? kRed : const Color(0xFFF6F4F0),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sel ? kRed : Colors.black.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      color: sel ? Colors.white.withOpacity(0.2) : kRedLight,
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text(w.initials,
                        style: TextStyle(
                            fontSize: 9, fontWeight: FontWeight.w500,
                            color: sel ? Colors.white : kRedDark))),
                  ),
                  const SizedBox(width: 6),
                  Text(w.name,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                          color: sel ? Colors.white : const Color(0xFF1A1A1A))),
                  if (sel) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.check, size: 11, color: Colors.white),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── 2. Shift type ─────────────────────────

  Widget _sectionShiftType() {
    return _card(
      icon: Icons.category_outlined,
      title: 'Smena turi',
      body: Row(
        children: ShiftType.values.map((t) {
          final active = _selectedType == t;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: t == ShiftType.values.first ? 0 : 3,
                right: t == ShiftType.values.last ? 0 : 3,
              ),
              child: GestureDetector(
                onTap: () => setState(() => _selectedType = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                  decoration: BoxDecoration(
                    color: active ? t.color : const Color(0xFFF6F4F0),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: active ? t.color : Colors.black.withOpacity(0.08), width: 0.5),
                  ),
                  child: Column(
                    children: [
                      Text(t.emoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 4),
                      Text(t.label, textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500,
                              color: active ? Colors.white : const Color(0xFF666666))),
                      const SizedBox(height: 2),
                      Text('${t.startTime}–${t.endTime}', textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 9,
                              color: active ? Colors.white.withOpacity(0.7) : const Color(0xFF999999))),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── 3. Time ───────────────────────────────

  Widget _sectionTime() {
    return _card(
      icon: Icons.access_time_outlined,
      title: 'Ish vaqti',
      body: Column(
        children: [
          Row(
            children: [
              _timeBox('Boshlanish', _selectedType.startTime),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.arrow_forward, color: Color(0xFFAAAAAA), size: 16),
              ),
              _timeBox('Tugash', _selectedType.endTime),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(color: kRedLight, borderRadius: BorderRadius.circular(20)),
            child: Text(_selectedType.duration,
                style: const TextStyle(fontSize: 11, color: kRedDark, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _timeBox(String label, String time) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4F0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.08), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF888888))),
          const SizedBox(height: 4),
          Text(time, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
        ],
      ),
    ),
  );

  // ── 4. Calendar ───────────────────────────

  Widget _sectionCalendar() {
    return _card(
      icon: Icons.calendar_today_outlined,
      title: 'Kunlarni tanlang',
      badge: '${_selectedDays.length} kun',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tez tanlash', style: TextStyle(fontSize: 11, color: Color(0xFF888888))),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 4, children: [
            _qChip('Bu hafta', _addThisWeek),
            _qChip('Keyingi hafta', _addNextWeek),
            _qChip('Dush-Juma', _addWeekdays),
            _qChip('Dam olish kunlari', _addWeekend),
          ]),
          const SizedBox(height: 12),
          Row(
            children: [
              _navBtn(Icons.chevron_left, () => setState(() =>
              _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1))),
              const Spacer(),
              Text(_monthStr(_viewMonth),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const Spacer(),
              _navBtn(Icons.chevron_right, () => setState(() =>
              _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1))),
            ],
          ),
          const SizedBox(height: 8),
          _calGrid(),
          const SizedBox(height: 8),
          _selectedText(),
        ],
      ),
    );
  }

  Widget _qChip(String label, VoidCallback fn) => GestureDetector(
    onTap: fn,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4F0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.5),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF444444))),
    ),
  );

  Widget _navBtn(IconData icon, VoidCallback fn) => GestureDetector(
    onTap: fn,
    child: Container(
      width: 26, height: 26,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4F0),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black.withOpacity(0.08), width: 0.5),
      ),
      child: Icon(icon, size: 16, color: const Color(0xFF666666)),
    ),
  );

  void _addThisWeek() {
    final now = DateTime.now();
    final s = now.subtract(Duration(days: now.weekday - 1));
    _addDays(List.generate(7, (i) => DateTime(s.year, s.month, s.day + i)));
  }

  void _addNextWeek() {
    final now = DateTime.now();
    final s = now.subtract(Duration(days: now.weekday - 1)).add(const Duration(days: 7));
    _addDays(List.generate(7, (i) => DateTime(s.year, s.month, s.day + i)));
  }

  void _addWeekdays() {
    final now = DateTime.now();
    final s = now.subtract(Duration(days: now.weekday - 1));
    _addDays(List.generate(5, (i) => DateTime(s.year, s.month, s.day + i)));
  }

  void _addWeekend() {
    final now = DateTime.now();
    final s = now.subtract(Duration(days: now.weekday - 1));
    _addDays([
      DateTime(s.year, s.month, s.day + 5),
      DateTime(s.year, s.month, s.day + 6),
    ]);
  }

  Widget _calGrid() {
    const dn = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
    final first = DateTime(_viewMonth.year, _viewMonth.month, 1);
    final offset = (first.weekday - 1) % 7;
    final dim = DateTime(_viewMonth.year, _viewMonth.month + 1, 0).day;
    final today = DateTime.now();

    return Column(
      children: [
        Row(children: dn.map((n) => Expanded(
          child: Center(child: Text(n,
              style: const TextStyle(fontSize: 9, color: Color(0xFF999999), fontWeight: FontWeight.w500))),
        )).toList()),
        const SizedBox(height: 3),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, childAspectRatio: 1.1, crossAxisSpacing: 3, mainAxisSpacing: 3,
          ),
          itemCount: offset + dim,
          itemBuilder: (_, idx) {
            if (idx < offset) return const SizedBox();
            final day = idx - offset + 1;
            final date = DateTime(_viewMonth.year, _viewMonth.month, day);
            final isPast = date.isBefore(DateTime(today.year, today.month, today.day));
            final isToday = _sameDay(date, today);
            final isSel = _selectedDays.any((d) => _sameDay(d, date));
            final hasConflict = _conflicts.any((c) => _sameDay(c.date, date));

            return GestureDetector(
              onTap: isPast ? null : () => _toggleDay(date),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: isSel
                      ? (hasConflict ? const Color(0xFFF0997B) : kRed)
                      : const Color(0xFFF6F4F0),
                  borderRadius: BorderRadius.circular(6),
                  border: isToday && !isSel ? Border.all(color: kRed, width: 1.5) : null,
                ),
                child: Center(child: Text('$day',
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w500,
                        color: isSel ? Colors.white
                            : isToday ? kRed
                            : isPast ? const Color(0xFFCCCCCC)
                            : const Color(0xFF1A1A1A)))),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _selectedText() {
    final sorted = _selectedDays.toList()..sort();
    if (sorted.isEmpty) {
      return const Text('Hech qanday kun tanlanmagan',
          style: TextStyle(fontSize: 11, color: Color(0xFF999999)));
    }
    const ms = ['', 'yan', 'fev', 'mar', 'apr', 'may', 'iyn', 'iyl', 'avg', 'sen', 'okt', 'noy', 'dek'];
    final labels = sorted.map((d) => '${d.day}-${ms[d.month]}').join(', ');
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
        children: [
          const TextSpan(text: 'Tanlangan: '),
          TextSpan(text: labels, style: const TextStyle(color: kRed, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── 5. Conflict ───────────────────────────

  Widget _sectionConflict() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kRedMid, width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF5C4B3), width: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(color: kRedLight, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.warning_amber_rounded, color: kRed, size: 15),
                ),
                const SizedBox(width: 8),
                const Text('Jadval konflikti aniqlandi',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: kRedMid, borderRadius: BorderRadius.circular(10)),
                  child: Text('${_conflicts.length} ta',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF712B13))),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: _conflicts.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _conflictCard(c),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _conflictCard(ConflictInfo c) {
    const wd = ['', 'Dushanba', 'Seshanba', 'Chorshanba', 'Payshanba', 'Juma', 'Shanba', 'Yakshanba'];
    const ms = ['', 'yan', 'fev', 'mar', 'apr', 'may', 'iyn', 'iyl', 'avg', 'sen', 'okt', 'noy', 'dek'];
    final lbl = '${wd[c.date.weekday]}, ${c.date.day}-${ms[c.date.month]}';

    return Container(
      decoration: BoxDecoration(
        color: kRedLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kRedMid, width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF0997B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
            ),
            child: Row(children: [
              const Icon(Icons.person_off_outlined, size: 14, color: Color(0xFF4A1B0C)),
              const SizedBox(width: 6),
              Text('${c.worker.name} — $lbl',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF4A1B0C))),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mavjud smena:', style: TextStyle(fontSize: 10, color: kRedDark, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                _shiftRow(c.worker.initials, c.worker.name,
                    '${c.existingType.label} — ${c.existingStart} – ${c.existingEnd}',
                    c.existingType.label, c.existingType.badgeBg, c.existingType.badgeText),
                const SizedBox(height: 8),
                const Text("Yangi qo'shilmoqda:", style: TextStyle(fontSize: 10, color: kRedDark, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                _shiftRow(c.worker.initials, c.worker.name,
                    '${_selectedType.label} — ${_selectedType.startTime} – ${_selectedType.endTime}',
                    'Yangi', const Color(0xFFEEEDFE), const Color(0xFF3C3489)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _resolveConflict(c, 'skip'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.5),
                        ),
                        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.close, size: 13, color: Color(0xFF666666)),
                          SizedBox(width: 4),
                          Text("O'tkazib yuborish",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF666666))),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _resolveConflict(c, 'replace'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(color: kRed, borderRadius: BorderRadius.circular(8)),
                        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.swap_horiz, size: 13, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Almashtirish',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white)),
                        ]),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shiftRow(String init, String name, String detail,
      String badgeLabel, Color badgeBg, Color badgeText) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kRedMid, width: 0.5),
      ),
      child: Row(children: [
        Container(width: 28, height: 28,
            decoration: const BoxDecoration(color: Color(0xFFF5C4B3), shape: BoxShape.circle),
            child: Center(child: Text(init,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF712B13))))),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          Text(detail, style: const TextStyle(fontSize: 10, color: kRedDark)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(20)),
          child: Text(badgeLabel,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: badgeText)),
        ),
      ]),
    );
  }

  // ── 6. Preview ────────────────────────────

  Widget _sectionPreview() {
    final sorted = _selectedDays.toList()..sort();
    return _card(
      icon: Icons.remove_red_eye_outlined,
      title: 'Tekshirish',
      body: sorted.isEmpty
          ? const Center(child: Text('Kun tanlanmagan',
          style: TextStyle(fontSize: 12, color: Color(0xFF999999))))
          : Column(
        children: sorted.map((day) {
          final dateStr = _fmt(day);
          final key = _selectedWorker != null ? '${_selectedWorker!.id}_$dateStr' : '';
          final isSkip = _resolutions[key] == 'skip';
          final isReplace = _resolutions[key] == 'replace';
          final hasConflict = _conflicts.any((c) => _sameDay(c.date, day));
          const wd = ['', 'Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
          const ms = ['', 'yan', 'fev', 'mar', 'apr', 'may', 'iyn', 'iyl', 'avg', 'sen', 'okt', 'noy', 'dek'];
          final lbl = '${wd[day.weekday]}, ${day.day}-${ms[day.month]}';

          return Opacity(
            opacity: isSkip ? 0.4 : 1.0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0x14000000), width: 0.5))),
              child: Row(children: [
                const Icon(Icons.account_circle_outlined, size: 15, color: Color(0xFFAAAAAA)),
                const SizedBox(width: 8),
                Expanded(child: Text(lbl,
                    style: TextStyle(fontSize: 11, color: const Color(0xFF888888),
                        decoration: isSkip ? TextDecoration.lineThrough : null))),
                Text('${_selectedType.startTime} – ${_selectedType.endTime}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                const SizedBox(width: 6),
                if (isReplace)
                  _badge('Almashtirildi', const Color(0xFFC0DD97), const Color(0xFF27500A))
                else if (hasConflict)
                  _badge('Konflikt', const Color(0xFFF5C4B3), const Color(0xFF712B13))
                else
                  _badge(_selectedType.label, _selectedType.badgeBg, _selectedType.badgeText),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _badge(String label, Color bg, Color text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
    child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: text)),
  );

  // ── 7. Save ───────────────────────────────

  Widget _buildSaveBtn() {
    final canSave = _selectedWorker != null &&
        _selectedDays.isNotEmpty &&
        !_hasUnresolved &&
        !_saving;

    return GestureDetector(
      onTap: canSave ? _saveShifts : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: canSave ? kRed : const Color(0xFFCCCCCC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (_saving)
            const SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          else
            const Icon(Icons.check, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            _saving ? 'Saqlanmoqda...' : '$_effectiveCount ta smena saqlash',
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          if (!_saving && _selectedWorker != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: Text(_selectedWorker!.name,
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        ]),
      ),
    );
  }

  // ── Month label ───────────────────────────
  String _monthStr(DateTime d) {
    const ms = ['', 'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'];
    return '${ms[d.month]} ${d.year}';
  }
}