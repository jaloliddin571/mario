import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/swap_service.dart';

class SwapRequestScreen extends StatefulWidget {
  const SwapRequestScreen({super.key});

  @override
  State<SwapRequestScreen> createState() =>
      _SwapRequestScreenState();
}

class _SwapRequestScreenState extends State<SwapRequestScreen>
    with SingleTickerProviderStateMixin {
  static const marioRed = Color(0xFFC0392B);
  static const marioCream = Color(0xFFF1EFE8);
  static const marioCard = Color(0xFFFFFFFF);
  static const marioBorder = Color(0xFFE8E5DF);
  static const marioText = Color(0xFF1E1C1A);
  static const marioSub = Color(0xFF888780);
  static const marioLight = Color(0xFFFAECE7);

  final _db = FirebaseFirestore.instance;
  late TabController _tabController;

  // Tanlangan smenalar
  String? _myShiftId;
  Map<String, dynamic>? _myShiftData;
  String? _targetShiftId;
  Map<String, dynamic>? _targetShiftData;
  String? _targetWorkerId;
  String? _targetWorkerName;

  bool _loading = false;

  final _months = [
    'yanvar','fevral','mart','aprel','may','iyun',
    'iyul','avgust','sentabr','oktabr','noyabr','dekabr'
  ];
  final _fullDays = [
    'Dushanba','Seshanba','Chorshanba',
    'Payshanba','Juma','Shanba','Yakshanba'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4EF),
      body: Column(
        children: [
          _buildHeader(),
          _buildBreadStrip(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNewRequestTab(),
                _buildMyRequestsTab(),
              ],
            ),
          ),
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
              Text('Smena almashtirish',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              Text('So\'rov yuborish va kuzatish',
                  style: TextStyle(
                      color: Colors.white60, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

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

  Widget _buildTabBar() {
    return Container(
      color: marioCard,
      child: TabBar(
        controller: _tabController,
        labelColor: marioRed,
        unselectedLabelColor: marioSub,
        indicatorColor: marioRed,
        indicatorWeight: 2,
        labelStyle: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Yangi so\'rov'),
          Tab(text: 'Mening so\'rovlarim'),
        ],
      ),
    );
  }

  // ── YANGI SO'ROV TAB ────────────────────────────────────
  Widget _buildNewRequestTab() {
    final auth = Provider.of<AuthService>(context, listen: false);
    final userId = auth.user?.uid ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // 1. Mening smenaim
          _card(
            title: '1. Mening smenamni tanlash',
            icon: Icons.person_outline,
            child: _buildMyShiftPicker(userId),
          ),
          const SizedBox(height: 12),

          // 2. Ishchi va smena tanlash
          _card(
            title: '2. Almashtiradigan ishchi va smena',
            icon: Icons.swap_horiz_outlined,
            child: _buildTargetShiftPicker(userId),
          ),
          const SizedBox(height: 12),

          // 3. Preview
          if (_myShiftData != null && _targetShiftData != null)
            _buildPreview(auth),

          const SizedBox(height: 12),

          // Yuborish tugmasi
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: (_myShiftId != null &&
                  _targetShiftId != null &&
                  !_loading)
                  ? () => _sendRequest(auth)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: marioRed,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                const Color(0xFFD3D1C7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: _loading
                  ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2))
                  : const Icon(Icons.send_outlined, size: 18),
              label: Text(
                _myShiftId == null || _targetShiftId == null
                    ? 'Smenalarni tanlang'
                    : 'So\'rov yuborish',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── MENING SMENAM PICKER ─────────────────────────────────
  Widget _buildMyShiftPicker(String userId) {
    final now = DateTime.now();
    final todayStr = _formatDate(now);
    final futureStr =
    _formatDate(now.add(const Duration(days: 14)));

    return StreamBuilder<QuerySnapshot>(
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
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Yaqin smenalar topilmadi',
                style: TextStyle(color: marioSub)),
          );
        }
        return Column(
          children: shifts.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final selected = _myShiftId == doc.id;
            return _shiftSelectTile(
              doc.id, data, selected,
              onTap: () {
                setState(() {
                  _myShiftId = doc.id;
                  _myShiftData = data;
                });
              },
            );
          }).toList(),
        );
      },
    );
  }

  // ── TARGET PICKER ────────────────────────────────────────
  Widget _buildTargetShiftPicker(String myUserId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection('users')
          .where('role', isEqualTo: 'worker')
          .snapshots(),
      builder: (context, snapshot) {
        final workers = (snapshot.data?.docs ?? [])
            .where((d) => d.id != myUserId)
            .toList();

        if (workers.isEmpty) {
          return const Text('Boshqa ishchilar topilmadi',
              style: TextStyle(color: marioSub));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ishchi tanlash
            const Text('Ishchi:',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: marioSub)),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: workers.map((doc) {
                  final data =
                  doc.data() as Map<String, dynamic>;
                  final name = data['name'] ?? 'Ishchi';
                  final selected = _targetWorkerId == doc.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _targetWorkerId = doc.id;
                        _targetWorkerName = name;
                        _targetShiftId = null;
                        _targetShiftData = null;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(
                          milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color:
                        selected ? marioRed : marioLight,
                        borderRadius:
                        BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? marioRed
                              : marioBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: selected
                                ? Colors.white24
                                : const Color(0xFFFAECE7),
                            child: Text(
                              name[0].toUpperCase(),
                              style: TextStyle(
                                  fontSize: 10,
                                  color: selected
                                      ? Colors.white
                                      : marioRed),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(name,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: selected
                                      ? Colors.white
                                      : marioText)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Tanlangan ishchining smenalari
            if (_targetWorkerId != null) ...[
              const SizedBox(height: 12),
              const Text('Smena:',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: marioSub)),
              const SizedBox(height: 6),
              _buildTargetWorkerShifts(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTargetWorkerShifts() {
    final now = DateTime.now();
    final todayStr = _formatDate(now);
    final futureStr =
    _formatDate(now.add(const Duration(days: 14)));

    return StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection('shifts')
          .where('workerId', isEqualTo: _targetWorkerId)
          .where('date', isGreaterThanOrEqualTo: todayStr)
          .where('date', isLessThanOrEqualTo: futureStr)
          .orderBy('date')
          .snapshots(),
      builder: (context, snapshot) {
        final shifts = snapshot.data?.docs ?? [];
        if (shifts.isEmpty) {
          return const Text(
            'Bu ishchida yaqin smenalar yo\'q',
            style: TextStyle(color: marioSub, fontSize: 12),
          );
        }
        return Column(
          children: shifts.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final selected = _targetShiftId == doc.id;
            return _shiftSelectTile(
              doc.id, data, selected,
              onTap: () {
                setState(() {
                  _targetShiftId = doc.id;
                  _targetShiftData = data;
                });
              },
            );
          }).toList(),
        );
      },
    );
  }

  // ── SMENA TILE ───────────────────────────────────────────
  Widget _shiftSelectTile(
      String docId,
      Map<String, dynamic> data,
      bool selected, {
        required VoidCallback onTap,
      }) {
    final type = data['type'] ?? 'morning';
    final dateStr = data['date'] ?? '';
    final start = data['startTime'] ?? '';
    final end = data['endTime'] ?? '';

    DateTime? date;
    try {
      final parts = dateStr.split('-');
      date = DateTime(int.parse(parts[0]),
          int.parse(parts[1]), int.parse(parts[2]));
    } catch (_) {}

    Color accentColor;
    Color bgColor;
    String typeLabel;

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

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? accentColor.withOpacity(0.08) : marioCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? accentColor : marioBorder,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date != null
                        ? '${_fullDays[date.weekday - 1]}, '
                        '${date.day}-${_months[date.month - 1]}'
                        : dateStr,
                    style: const TextStyle(
                        fontSize: 12, color: marioSub),
                  ),
                  Text(
                    type == 'off'
                        ? 'Dam olish kuni'
                        : '$start — $end',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: marioText),
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
              child: Text(typeLabel,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: accentColor)),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: selected ? accentColor : marioBorder,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ── PREVIEW ──────────────────────────────────────────────
  Widget _buildPreview(AuthService auth) {
    return _card(
      title: 'Tekshirish',
      icon: Icons.swap_horiz_outlined,
      child: Column(
        children: [
          // Mening smenaim
          _previewRow(
            auth.userName ?? 'Men',
            _myShiftData!['date'] ?? '',
            _myShiftData!['startTime'] ?? '',
            _myShiftData!['endTime'] ?? '',
            _myShiftData!['type'] ?? '',
            isLeft: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                    child: Divider(color: Color(0xFFE0DED8))),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.swap_vert_rounded,
                      color: Color(0xFFC0392B), size: 24),
                ),
                Expanded(
                    child: Divider(color: Color(0xFFE0DED8))),
              ],
            ),
          ),
          // Maqsad smenasi
          _previewRow(
            _targetWorkerName ?? '',
            _targetShiftData!['date'] ?? '',
            _targetShiftData!['startTime'] ?? '',
            _targetShiftData!['endTime'] ?? '',
            _targetShiftData!['type'] ?? '',
            isLeft: false,
          ),
        ],
      ),
    );
  }

  Widget _previewRow(String name, String date,
      String start, String end, String type,
      {required bool isLeft}) {
    DateTime? d;
    try {
      final parts = date.split('-');
      d = DateTime(int.parse(parts[0]),
          int.parse(parts[1]), int.parse(parts[2]));
    } catch (_) {}

    Color color;
    switch (type) {
      case 'night': color = const Color(0xFF534AB7); break;
      case 'off': color = marioSub; break;
      case 'half': color = const Color(0xFF3B6D11); break;
      default: color = marioRed;
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: marioLight,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(
                color: marioRed,
                fontWeight: FontWeight.w700,
                fontSize: 13),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: marioText)),
              Text(
                d != null
                    ? '${_fullDays[d.weekday - 1]}, '
                    '${d.day}-${_months[d.month - 1]}'
                    : date,
                style: const TextStyle(
                    fontSize: 11, color: marioSub),
              ),
              Text(
                type == 'off' ? 'Dam olish' : '$start–$end',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── MENING SO'ROVLARIM TAB ───────────────────────────────
  Widget _buildMyRequestsTab() {
    final auth = Provider.of<AuthService>(context, listen: false);
    final userId = auth.user?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('swap_requests')
          .where('requesterId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('MyRequests error: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text('Xato: ${snapshot.error}',
                    style: const TextStyle(
                        color: marioSub, fontSize: 12)),
              ],
            ),
          );
        }

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
                color: marioRed, strokeWidth: 2),
          );
        }

        var swaps = snapshot.data?.docs ?? [];

        // Kodda sort
        swaps.sort((a, b) {
          Timestamp? aT, bT;
          try {
            aT = (a.data() as Map)['createdAt']
            as Timestamp?;
          } catch (_) {}
          try {
            bT = (b.data() as Map)['createdAt']
            as Timestamp?;
          } catch (_) {}
          if (aT == null && bT == null) return 0;
          if (aT == null) return 1;
          if (bT == null) return -1;
          return bT.compareTo(aT);
        });

        if (swaps.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.swap_horiz_outlined,
                    size: 52, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                const Text('Hali so\'rov yubormagansiz',
                    style: TextStyle(
                        color: marioSub, fontSize: 14)),
                const SizedBox(height: 4),
                const Text(
                    '"Yangi so\'rov" tabidan\nso\'rov yuboring',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFFB4B2A9),
                        fontSize: 12)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(14),
          itemCount: swaps.length,
          separatorBuilder: (_, __) =>
          const SizedBox(height: 8),
          itemBuilder: (_, i) {
            Map<String, dynamic> data = {};
            try {
              data = swaps[i].data()
              as Map<String, dynamic>;
            } catch (_) {
              return const SizedBox.shrink();
            }
            return _swapRequestTile(data, swaps[i].id);
          },
        );
      },
    );
  }

  Widget _swapRequestTile(
      Map<String, dynamic> data, String docId) {
    final status = data['status'] ?? 'pending';
    final targetName = data['targetName'] ?? '';
    final myDate = data['requesterDate'] ?? '';
    final targetDate = data['targetDate'] ?? '';

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (status) {
      case 'approved':
        statusColor = const Color(0xFF3B6D11);
        statusLabel = 'Tasdiqlandi';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusLabel = 'Rad etildi';
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = const Color(0xFFB8860B);
        statusLabel = 'Kutilmoqda';
        statusIcon = Icons.hourglass_empty_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: marioCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: marioBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.swap_horiz_outlined,
                  color: marioRed, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$targetName bilan almashtirish',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: marioText),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                  statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon,
                        size: 11, color: statusColor),
                    const SizedBox(width: 3),
                    Text(statusLabel,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: statusColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: marioLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text('Mening smenam',
                          style: TextStyle(
                              fontSize: 10, color: marioSub)),
                      const SizedBox(height: 2),
                      Text(myDate,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: marioRed)),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.swap_horiz_rounded,
                    color: marioSub, size: 18),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEDFE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text('$targetName smenasi',
                          style: const TextStyle(
                              fontSize: 10, color: marioSub)),
                      const SizedBox(height: 2),
                      Text(targetDate,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF534AB7))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (status == 'rejected' &&
              data['rejectReason'] != null &&
              (data['rejectReason'] as String).isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 14, color: Colors.red),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Sabab: ${data['rejectReason']}',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── SO'ROV YUBORISH ──────────────────────────────────────
  Future<void> _sendRequest(AuthService auth) async {
    setState(() => _loading = true);

    try {
      await SwapService.sendSwapRequest(
        requesterId: auth.user!.uid,
        requesterName: auth.userName ?? '',
        requesterShiftId: _myShiftId!,
        requesterDate: _myShiftData!['date'] ?? '',
        requesterTime:
        '${_myShiftData!['startTime']}–${_myShiftData!['endTime']}',
        requesterType: _myShiftData!['type'] ?? '',
        targetId: _targetWorkerId!,
        targetName: _targetWorkerName ?? '',
        targetShiftId: _targetShiftId!,
        targetDate: _targetShiftData!['date'] ?? '',
        targetTime:
        '${_targetShiftData!['startTime']}–${_targetShiftData!['endTime']}',
        targetType: _targetShiftData!['type'] ?? '',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('So\'rov yuborildi! Admin tasdiqlashini kuting'),
            ]),
            backgroundColor: const Color(0xFF3B6D11),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
        // Mening so'rovlarim tabiga o'tish
        _tabController.animateTo(1);
        setState(() {
          _myShiftId = null;
          _myShiftData = null;
          _targetShiftId = null;
          _targetShiftData = null;
          _targetWorkerId = null;
          _targetWorkerName = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── CARD WIDGET ──────────────────────────────────────────
  Widget _card({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: marioCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: marioBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: marioLight,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(icon, size: 14, color: marioRed),
                ),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: marioText)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Divider(
                height: 0.5,
                thickness: 0.5,
                color: marioBorder),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: child,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}