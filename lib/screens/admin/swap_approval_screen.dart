import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/swap_service.dart';

class SwapApprovalScreen extends StatelessWidget {
  const SwapApprovalScreen({super.key});

  static const marioRed = Color(0xFFC0392B);
  static const marioCream = Color(0xFFF1EFE8);
  static const marioCard = Color(0xFFFFFFFF);
  static const marioBorder = Color(0xFFE8E5DF);
  static const marioText = Color(0xFF1E1C1A);
  static const marioSub = Color(0xFF888780);
  static const marioLight = Color(0xFFFAECE7);

  final _months = const [
    'yanvar','fevral','mart','aprel','may','iyun',
    'iyul','avgust','sentabr','oktabr','noyabr','dekabr'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4EF),
      body: Column(
        children: [
          _buildHeader(context),
          _buildBreadStrip(),
          Expanded(child: _buildSwapList(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: marioRed,
      padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.of(context).padding.top + 12,
          20, 14),
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
              Text('Almashtirish so\'rovlari',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              Text('Tasdiqlash yoki rad etish',
                  style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12)),
            ],
          ),
          const Spacer(),
          StreamBuilder<QuerySnapshot>(
            stream: SwapService.getPendingSwaps(),
            builder: (context, snapshot) {
              final count =
                  snapshot.data?.docs.length ?? 0;
              if (count == 0) return const SizedBox();
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$count ta kutilmoqda',
                    style: const TextStyle(
                        color: marioRed,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              );
            },
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

  Widget _buildSwapList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('swap_requests')
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        // Error handle
        if (snapshot.hasError) {
          print('SwapApproval error: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                const Text('Ma\'lumot yuklanmadi',
                    style: TextStyle(color: marioSub)),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {},
                  child: const Text('Qayta urinish',
                      style: TextStyle(color: marioRed)),
                ),
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
            aT = (a.data() as Map)['createdAt'] as Timestamp?;
          } catch (_) {}
          try {
            bT = (b.data() as Map)['createdAt'] as Timestamp?;
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
                Icon(Icons.check_circle_outline,
                    size: 56, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                const Text('Kutilayotgan so\'rovlar yo\'q',
                    style: TextStyle(
                        color: marioSub, fontSize: 14)),
                const SizedBox(height: 4),
                const Text(
                    'Barcha so\'rovlar ko\'rib chiqildi',
                    style: TextStyle(
                        color: marioSub, fontSize: 12)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(14),
          itemCount: swaps.length,
          separatorBuilder: (_, __) =>
          const SizedBox(height: 10),
          itemBuilder: (_, i) {
            Map<String, dynamic> data = {};
            try {
              data = swaps[i].data() as Map<String, dynamic>;
            } catch (_) {
              return const SizedBox.shrink();
            }
            return _swapCard(context, swaps[i].id, data);
          },
        );
      },
    );
  }

  Widget _swapCard(BuildContext context,
      String docId, Map<String, dynamic> data) {
    final requesterName = data['requesterName'] ?? '';
    final targetName = data['targetName'] ?? '';
    final requesterDate = data['requesterDate'] ?? '';
    final targetDate = data['targetDate'] ?? '';
    final requesterTime = data['requesterTime'] ?? '';
    final targetTime = data['targetTime'] ?? '';
    final requesterType = data['requesterType'] ?? '';
    final targetType = data['targetType'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: marioCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: marioBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFFFAECE7),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.swap_horiz_rounded,
                    color: marioRed, size: 18),
                const SizedBox(width: 8),
                Text(
                  '$requesterName ↔ $targetName',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: marioRed),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFFB8860B),
                        width: 0.5),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.hourglass_empty_rounded,
                          size: 11,
                          color: Color(0xFFB8860B)),
                      SizedBox(width: 3),
                      Text('Kutilmoqda',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFB8860B))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Smenalar
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Requester smena
                Expanded(
                  child: _shiftPreviewBox(
                    requesterName,
                    requesterDate,
                    requesterTime,
                    requesterType,
                    marioRed,
                    marioLight,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10),
                  child: Icon(Icons.swap_horiz_rounded,
                      color: marioSub, size: 22),
                ),
                // Target smena
                Expanded(
                  child: _shiftPreviewBox(
                    targetName,
                    targetDate,
                    targetTime,
                    targetType,
                    const Color(0xFF534AB7),
                    const Color(0xFFEEEDFE),
                  ),
                ),
              ],
            ),
          ),

          // Tugmalar
          Padding(
            padding: const EdgeInsets.fromLTRB(
                14, 0, 14, 14),
            child: Row(
              children: [
                // Rad etish
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        _showRejectDialog(context, docId,
                            requesterName),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCEBEB),
                        borderRadius:
                        BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.red.shade200,
                            width: 0.5),
                      ),
                      child: const Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close_rounded,
                              color: Colors.red, size: 16),
                          SizedBox(width: 6),
                          Text('Rad etish',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                  fontWeight:
                                  FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Tasdiqlash
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        _approveSwap(context, docId,
                            requesterName, targetName),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12),
                      decoration: BoxDecoration(
                        color: marioRed,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_rounded,
                              color: Colors.white,
                              size: 16),
                          SizedBox(width: 6),
                          Text('Tasdiqlash',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight:
                                  FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shiftPreviewBox(String name, String date,
      String time, String type,
      Color textColor, Color bgColor) {
    String typeLabel;
    switch (type) {
      case 'night': typeLabel = '🌙 Tungi'; break;
      case 'off': typeLabel = '🌿 Dam olish'; break;
      case 'half': typeLabel = '⏱ Yarim'; break;
      default: typeLabel = '🌅 Kunduzgi';
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textColor)),
          const SizedBox(height: 4),
          Text(date,
              style: const TextStyle(
                  fontSize: 10, color: marioSub)),
          Text(
            type == 'off' ? 'Dam olish' : time,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor),
          ),
          const SizedBox(height: 4),
          Text(typeLabel,
              style: const TextStyle(
                  fontSize: 10, color: marioSub)),
        ],
      ),
    );
  }

  Future<void> _approveSwap(BuildContext context,
      String docId, String requester,
      String target) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Tasdiqlash'),
        content: Text(
          '$requester va $target smenalarini '
              'almashtirishni tasdiqlaysizmi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Bekor',
                style: TextStyle(color: marioSub)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tasdiqlash',
                style: TextStyle(
                    color: marioRed,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SwapService.approveSwap(docId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Smena almashtirish tasdiqlandi! ✓'),
            ]),
            backgroundColor: const Color(0xFF3B6D11),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _showRejectDialog(BuildContext context,
      String docId, String requesterName) {
    final reasonCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: marioCard,
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(
            20, 12, 20,
            MediaQuery.of(ctx).viewInsets.bottom + 24),
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
            const Text('Rad etish sababi',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: marioText)),
            const SizedBox(height: 4),
            Text('$requesterName ning so\'rovi rad etiladi',
                style: const TextStyle(
                    fontSize: 13, color: marioSub)),
            const SizedBox(height: 16),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                'Sabab yozing (ixtiyoriy)...',
                filled: true,
                fillColor: marioCream,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                  const BorderSide(color: marioRed),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await SwapService.rejectSwap(
                      docId, reasonCtrl.text.trim());
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: const Text(
                            'So\'rov rad etildi'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12)),
                ),
                child: const Text('Rad etish',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}