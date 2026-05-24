import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkersScreen extends StatefulWidget {
  const WorkersScreen({super.key});

  @override
  State<WorkersScreen> createState() => _WorkersScreenState();
}

class _WorkersScreenState extends State<WorkersScreen> {
  static const marioRed = Color(0xFFC0392B);
  static const marioCream = Color(0xFFF1EFE8);
  static const marioBg = Color(0xFFF5F4EF);

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(child: _buildWorkerList()),
        _buildAddButton(),
      ],
    );
  }

  // ── QIDIRUV ──────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: TextField(
        onChanged: (v) => setState(() => _search = v.toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Ishchi qidirish...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFFB4B2A9)),
          filled: true,
          fillColor: marioCream,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ── ISHCHILAR RO'YXATI ───────────────────────────────────
  Widget _buildWorkerList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection('users')
          .where('role', isEqualTo: 'worker')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: marioRed));
        }

        var workers = snapshot.data?.docs ?? [];

        // Qidiruv filter
        if (_search.isNotEmpty) {
          workers = workers.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['name'] ?? '').toString().toLowerCase();
            final email = (data['email'] ?? '').toString().toLowerCase();
            return name.contains(_search) || email.contains(_search);
          }).toList();
        }

        if (workers.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people_outline,
                    size: 56, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                const Text(
                  'Ishchilar topilmadi',
                  style: TextStyle(color: Color(0xFF888780)),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: workers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final doc = workers[i];
            final data = doc.data() as Map<String, dynamic>;
            return _workerTile(doc.id, data);
          },
        );
      },
    );
  }

  // ── ISHCHI TILE ──────────────────────────────────────────
  Widget _workerTile(String docId, Map<String, dynamic> data) {
    final name = data['name'] ?? 'Ishchi';
    final email = data['email'] ?? '';
    final phone = data['phone'] ?? '';

    final avatarColors = [
      const Color(0xFFFAECE7),
      const Color(0xFFEEEDFE),
      const Color(0xFFEAF3DE),
      const Color(0xFFE6F1FB),
    ];
    final textColors = [
      marioRed,
      const Color(0xFF534AB7),
      const Color(0xFF2E7D32),
      const Color(0xFF185FA5),
    ];
    final idx = name.codeUnitAt(0) % 4;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFFE0DED8), width: 0.5),
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: avatarColors[idx],
          child: Text(
            name[0].toUpperCase(),
            style: TextStyle(
              color: textColors[idx],
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C2C2A),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (email.isNotEmpty)
              Text(email,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF888780))),
            if (phone.isNotEmpty)
              Text(phone,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF888780))),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (val) {
            if (val == 'delete') _deleteWorker(docId, name);
            if (val == 'edit') _editWorker(docId, data);
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(children: [
                Icon(Icons.edit_outlined, size: 18),
                SizedBox(width: 8),
                Text('Tahrirlash'),
              ]),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                Icon(Icons.delete_outline, size: 18, color: Colors.red),
                SizedBox(width: 8),
                Text('O\'chirish',
                    style: TextStyle(color: Colors.red)),
              ]),
            ),
          ],
          child: const Icon(Icons.more_vert,
              color: Color(0xFFB4B2A9)),
        ),
      ),
    );
  }

  // ── ISHCHI QO'SHISH TUGMASI ──────────────────────────────
  Widget _buildAddButton() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _showAddWorkerSheet,
          style: ElevatedButton.styleFrom(
            backgroundColor: marioRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          icon: const Icon(Icons.person_add_outlined),
          label: const Text('Yangi ishchi qo\'shish',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  // ── ISHCHI QO'SHISH SHEET ────────────────────────────────
  void _showAddWorkerSheet() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    bool loading = false;
    String? error;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD3D1C7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Yangi ishchi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C2C2A),
                ),
              ),
              const SizedBox(height: 16),

              // Ism
              _sheetField(
                ctrl: nameCtrl,
                hint: 'To\'liq ism',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 10),

              // Email
              _sheetField(
                ctrl: emailCtrl,
                hint: 'Email',
                icon: Icons.mail_outline,
                keyboard: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),

              // Telefon
              _sheetField(
                ctrl: phoneCtrl,
                hint: 'Telefon (ixtiyoriy)',
                icon: Icons.phone_outlined,
                keyboard: TextInputType.phone,
              ),
              const SizedBox(height: 10),

              // Parol
              _sheetField(
                ctrl: passCtrl,
                hint: 'Parol (kamida 6 belgi)',
                icon: Icons.lock_outline,
                obscure: true,
              ),

              // Xato
              if (error != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(error!,
                      style: const TextStyle(color: Colors.red)),
                ),
              ],

              const SizedBox(height: 16),

              // Saqlash
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: loading
                      ? null
                      : () async {
                    if (nameCtrl.text.isEmpty ||
                        emailCtrl.text.isEmpty ||
                        passCtrl.text.isEmpty) {
                      setSheet(
                              () => error = 'Barcha maydonlarni to\'ldiring');
                      return;
                    }
                    setSheet(() {
                      loading = true;
                      error = null;
                    });
                    try {
                      // Firebase Auth da foydalanuvchi yaratish
                      final cred = await _auth
                          .createUserWithEmailAndPassword(
                        email: emailCtrl.text.trim(),
                        password: passCtrl.text,
                      );

                      // Firestoreda saqlash
                      await _db
                          .collection('users')
                          .doc(cred.user!.uid)
                          .set({
                        'name': nameCtrl.text.trim(),
                        'email': emailCtrl.text.trim(),
                        'phone': phoneCtrl.text.trim(),
                        'role': 'worker',
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      if (ctx.mounted) Navigator.pop(ctx);
                    } on FirebaseAuthException catch (e) {
                      setSheet(() {
                        loading = false;
                        error = _authError(e.code);
                      });
                    } catch (e) {
                      setSheet(() {
                        loading = false;
                        error = 'Xatolik: $e';
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: marioRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: loading
                      ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : const Text('Saqlash',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── TAHRIRLASH ───────────────────────────────────────────
  void _editWorker(String docId, Map<String, dynamic> data) {
    final nameCtrl = TextEditingController(text: data['name']);
    final phoneCtrl = TextEditingController(text: data['phone'] ?? '');
    bool loading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD3D1C7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Tahrirlash',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C2C2A))),
              const SizedBox(height: 16),
              _sheetField(
                  ctrl: nameCtrl,
                  hint: 'To\'liq ism',
                  icon: Icons.person_outline),
              const SizedBox(height: 10),
              _sheetField(
                  ctrl: phoneCtrl,
                  hint: 'Telefon',
                  icon: Icons.phone_outlined,
                  keyboard: TextInputType.phone),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: loading
                      ? null
                      : () async {
                    setSheet(() => loading = true);
                    await _db
                        .collection('users')
                        .doc(docId)
                        .update({
                      'name': nameCtrl.text.trim(),
                      'phone': phoneCtrl.text.trim(),
                    });
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: marioRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: loading
                      ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : const Text('Saqlash',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── O'CHIRISH ────────────────────────────────────────────
  Future<void> _deleteWorker(String docId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Ishchini o\'chirish'),
        content: Text(
            '$name ni o\'chirishni tasdiqlaysizmi?\nUning barcha smenalari ham o\'chadi.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Bekor')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('O\'chirish',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    // Ishchi smenalarini o'chirish
    final shifts = await _db
        .collection('shifts')
        .where('workerId', isEqualTo: docId)
        .get();
    final batch = _db.batch();
    for (final doc in shifts.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_db.collection('users').doc(docId));
    await batch.commit();
  }

  // ── YORDAMCHI ────────────────────────────────────────────
  Widget _sheetField({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: marioRed, size: 20),
        filled: true,
        fillColor: marioCream,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: marioRed),
        ),
      ),
    );
  }

  String _authError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Bu email allaqachon ro\'yxatdan o\'tgan';
      case 'weak-password':
        return 'Parol kamida 6 belgi bo\'lishi kerak';
      case 'invalid-email':
        return 'Email noto\'g\'ri formatda';
      default:
        return 'Xatolik yuz berdi: $code';
    }
  }
}