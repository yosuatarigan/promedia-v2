import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:promedia_v2/admin/add_user_dialog.dart';
import 'package:promedia_v2/admin/admin_session.dart';
import 'package:promedia_v2/admin/admin_ui.dart';
import 'package:promedia_v2/admin/notifications/user_notifications.dart';
import 'package:promedia_v2/admin/pasien/edit_user_dialog.dart';
import 'package:promedia_v2/admin/pasien/pasien_manage_screen.dart';
import 'package:promedia_v2/admin/manage_admin_screen.dart';
import 'package:promedia_v2/message_framing_screen.dart';
import 'utils/file_downloader.dart';

class AdminDashboardScreen extends StatefulWidget {
  final AdminProfile admin;
  const AdminDashboardScreen({super.key, required this.admin});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _firestore = FirebaseFirestore.instance;
  String _selectedRole = 'all';
  String _searchQuery = '';
  int _selectedIndex = 0;
  final Set<String> _revealedPasswords = {};
  bool _isExportingExcel = false;

  // Jumlah notifikasi belum dibaca per user (kolom NOTIFIKASI di Manage Users).
  UnreadNotifIndex _unread = UnreadNotifIndex.empty;
  StreamSubscription<UnreadNotifIndex>? _unreadSub;

  // Satu listener koleksi `users` untuk seluruh sesi admin. Sebelumnya
  // StreamBuilder membuat listener baru di setiap build (ketik pencarian,
  // ganti filter, update notifikasi) — di web tanpa cache, tiap listener
  // baru membaca ulang semua dokumen user.
  final _usersCtrl = StreamController<QuerySnapshot>.broadcast();
  QuerySnapshot? _usersSnap;
  StreamSubscription<QuerySnapshot>? _usersSub;

  @override
  void initState() {
    super.initState();
    _unreadSub = UnreadNotifIndex.watch().listen(
      (idx) => setState(() => _unread = idx),
      onError: (_) {},
    );
    _usersSub = _firestore.collection('users').snapshots().listen(
      (snap) {
        _usersSnap = snap;
        _usersCtrl.add(snap);
      },
      onError: _usersCtrl.addError,
    );
  }

  @override
  void dispose() {
    _unreadSub?.cancel();
    _usersSub?.cancel();
    _usersCtrl.close();
    super.dispose();
  }

  UnreadNotif _unreadOf(QueryDocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return _unread.forUser(
      doc.id,
      (d['noKode'] ?? '').toString(),
      (d['role'] ?? '').toString(),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSidebar(),
        Expanded(child: _buildMainContent()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: Column(
        children: [
          _buildMobileAppBar(),
          Expanded(child: _buildMainContent()),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    final logoutIndex = _menuTitles.length;
    return BottomNavigationBar(
      currentIndex: _selectedIndex < logoutIndex ? _selectedIndex : 0,
      onTap: (index) {
        if (index == logoutIndex) {
          _confirmLogout();
        } else {
          setState(() => _selectedIndex = index);
        }
      },
      selectedItemColor: const Color(0xFFB83B7E),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Users',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Message',
        ),
        if (widget.admin.isSuperadmin)
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
        BottomNavigationBarItem(
          icon: Icon(Icons.logout),
          label: 'Logout',
        ),
      ],
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB83B7E),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 256,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AdminColors.sidebarTop, AdminColors.sidebarBottom],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 28, 20, 28),
              child: _BrandMark(),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                'MENU',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            _buildSidebarItem(
              icon: Icons.space_dashboard_outlined,
              activeIcon: Icons.space_dashboard,
              title: 'Dashboard',
              index: 0,
            ),
            _buildSidebarItem(
              icon: Icons.people_outline,
              activeIcon: Icons.people,
              title: 'Manage Users',
              index: 1,
            ),
            _buildSidebarItem(
              icon: Icons.chat_bubble_outline,
              activeIcon: Icons.chat_bubble,
              title: 'Message Framing',
              index: 2,
            ),
            if (widget.admin.isSuperadmin) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Text(
                  'PENGATURAN',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              _buildSidebarItem(
                icon: Icons.admin_panel_settings_outlined,
                activeIcon: Icons.admin_panel_settings,
                title: 'Kelola Admin',
                index: 3,
              ),
            ],
            const Spacer(),
            _buildSidebarAdminInfo(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarAdminInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Text(
              AdminAvatar.initials(widget.admin.nama),
              style: const TextStyle(
                color: AdminColors.primaryDark,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.admin.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  widget.admin.roleLabel,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 20),
          ),
        ],
      ),
    );
  }

  List<String> get _menuTitles => [
        'Dashboard',
        'Manage Users',
        'Message Framing',
        if (widget.admin.isSuperadmin) 'Kelola Admin',
      ];

  Widget _buildSidebarItem({
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          hoverColor: Colors.white.withOpacity(0.08),
          onTap: () => setState(() => _selectedIndex = index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 20,
                  color: isSelected ? AdminColors.primary : Colors.white70,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? AdminColors.primaryDark : Colors.white.withOpacity(0.85),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileAppBar() {
    final titles = _menuTitles;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AdminColors.sidebarTop, AdminColors.sidebarBottom],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const _BrandMark(compact: true),
            const Spacer(),
            Text(
              _selectedIndex < titles.length ? titles[_selectedIndex] : 'Dashboard',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_selectedIndex == 0) {
      return _buildDashboardOverview();
    } else if (_selectedIndex == 1) {
      return _buildUserManagement();
    } else if (_selectedIndex == 2) {
      return const MessageFramingScreen();
    } else if (_selectedIndex == 3 && widget.admin.isSuperadmin) {
      return ManageAdminScreen(currentAdmin: widget.admin);
    } else {
      return _buildDashboardOverview();
    }
  }

  Widget _buildDashboardOverview() {
    final now = DateTime.now();
    final greeting = now.hour < 11
        ? 'Selamat pagi'
        : now.hour < 15
            ? 'Selamat siang'
            : now.hour < 18
                ? 'Selamat sore'
                : 'Selamat malam';

    return AdminPage(
      title: '$greeting, ${widget.admin.nama}',
      subtitle:
          '${DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now)}  ·  Ringkasan data pengguna Promedia',
      child: StreamBuilder<QuerySnapshot>(
        stream: _usersCtrl.stream,
        initialData: _usersSnap,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return AdminEmptyState(
              icon: Icons.error_outline,
              title: 'Gagal memuat data',
              message: '${snapshot.error}',
            );
          }
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final users = snapshot.data!.docs;
          String roleOf(QueryDocumentSnapshot d) =>
              ((d.data() as Map<String, dynamic>)['role'] ?? '').toString();
          DateTime? createdOf(QueryDocumentSnapshot d) =>
              ((d.data() as Map<String, dynamic>)['createdAt'] as Timestamp?)?.toDate();

          final pasien = users.where((d) => roleOf(d) == 'pasien').length;
          final keluarga = users.where((d) => roleOf(d) == 'keluarga').length;
          final weekAgo = now.subtract(const Duration(days: 7));
          final baru = users.where((d) {
            final c = createdOf(d);
            return c != null && c.isAfter(weekAgo);
          }).length;
          final recent = users.where((d) => createdOf(d) != null).toList()
            ..sort((a, b) => createdOf(b)!.compareTo(createdOf(a)!));

          String share(int n) => users.isEmpty
              ? '-'
              : '${(n * 100 / users.length).round()}% dari total';

          return LayoutBuilder(builder: (context, c) {
            const gap = 16.0;
            final cols = c.maxWidth >= 1000 ? 4 : (c.maxWidth >= 560 ? 2 : 1);
            final w = (c.maxWidth - gap * (cols - 1)) / cols;
            final wide = c.maxWidth >= 1000;

            final recentCard = _buildRecentUsersCard(recent.take(6).toList());
            final sideCard = _buildCompositionCard(pasien, keluarga, users.length);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    _buildStatCard('Total Pengguna', users.length,
                        Icons.people_alt_outlined, AdminColors.info, w,
                        caption: 'Pasien & keluarga'),
                    _buildStatCard('Pasien', pasien, Icons.favorite_border,
                        AdminColors.pasien, w,
                        caption: share(pasien)),
                    _buildStatCard('Keluarga', keluarga,
                        Icons.family_restroom_outlined, AdminColors.keluarga, w,
                        caption: share(keluarga)),
                    _buildStatCard('Pendaftar Baru', baru,
                        Icons.person_add_alt_outlined, AdminColors.warning, w,
                        caption: '7 hari terakhir'),
                  ],
                ),
                const SizedBox(height: gap),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: recentCard),
                      const SizedBox(width: gap),
                      Expanded(flex: 2, child: sideCard),
                    ],
                  )
                else ...[
                  recentCard,
                  const SizedBox(height: gap),
                  sideCard,
                ],
              ],
            );
          });
        },
      ),
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color,
      double width,
      {String? caption}) {
    return SizedBox(
      width: width,
      child: AdminCard(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AdminColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    NumberFormat.decimalPattern('id_ID').format(value),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AdminColors.text,
                      height: 1.2,
                    ),
                  ),
                  if (caption != null)
                    Text(
                      caption,
                      style: const TextStyle(
                          fontSize: 12, color: AdminColors.textSubtle),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentUsersCard(List<QueryDocumentSnapshot> recent) {
    return AdminCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
            child: AdminCardTitle(
              'Pengguna Terbaru',
              subtitle: 'Pendaftar paling akhir',
              trailing: TextButton(
                onPressed: () => setState(() => _selectedIndex = 1),
                child: const Text('Lihat semua'),
              ),
            ),
          ),
          const Divider(),
          if (recent.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Belum ada pengguna',
                  style: TextStyle(color: AdminColors.textMuted)),
            ),
          for (var i = 0; i < recent.length; i++) ...[
            if (i > 0) const Divider(indent: 20, endIndent: 20),
            _buildRecentUserRow(recent[i]),
          ],
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildRecentUserRow(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final nama = (data['namaLengkap'] ?? '-').toString();
    final role = (data['role'] ?? '-').toString();
    final created = (data['createdAt'] as Timestamp?)?.toDate();
    return InkWell(
      onTap: () => _showUserDetail(doc),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            AdminAvatar(nama,
                color: role == 'keluarga'
                    ? AdminColors.keluarga
                    : AdminColors.pasien),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AdminColors.text)),
                  Text(
                    (data['email'] ?? '-').toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, color: AdminColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AdminBadge.role(role),
            const SizedBox(width: 16),
            SizedBox(
              width: 72,
              child: Text(
                created == null
                    ? '-'
                    : DateFormat('d MMM yy', 'id_ID').format(created),
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 12, color: AdminColors.textSubtle),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompositionCard(int pasien, int keluarga, int total) {
    Widget bar(String label, int value, Color color) {
      final ratio = total == 0 ? 0.0 : value / total;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, color: AdminColors.text)),
              const Spacer(),
              Text('$value',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: AdminColors.text)),
              const SizedBox(width: 6),
              Text('(${(ratio * 100).round()}%)',
                  style: const TextStyle(
                      fontSize: 12, color: AdminColors.textMuted)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              color: color,
              backgroundColor: color.withOpacity(0.12),
            ),
          ),
        ],
      );
    }

    Widget quickAction(IconData icon, String label, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AdminColors.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AdminColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, color: AdminColors.text)),
              ),
              const Icon(Icons.chevron_right,
                  size: 20, color: AdminColors.textSubtle),
            ],
          ),
        ),
      );
    }

    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AdminCardTitle('Komposisi Pengguna',
              subtitle: 'Perbandingan pasien dan keluarga'),
          const SizedBox(height: 20),
          bar('Pasien', pasien, AdminColors.pasien),
          const SizedBox(height: 16),
          bar('Keluarga', keluarga, AdminColors.keluarga),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text('Aksi Cepat',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: AdminColors.text)),
          const SizedBox(height: 12),
          quickAction(Icons.people_outline, 'Kelola pengguna',
              () => setState(() => _selectedIndex = 1)),
          const SizedBox(height: 8),
          quickAction(Icons.chat_bubble_outline, 'Kirim message framing',
              () => setState(() => _selectedIndex = 2)),
          const SizedBox(height: 8),
          quickAction(Icons.download_outlined, 'Export semua data (Excel)',
              _isExportingExcel ? () {} : _exportAllToExcel),
        ],
      ),
    );
  }

  Future<void> _openAddUser() async {
    final nama = await showAddUserDialog(context, admin: widget.admin);
    if (nama == null || !mounted) return;
    setState(() => _selectedRole = 'all');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$nama berhasil ditambahkan')),
    );
  }

  Widget _buildUserManagement() {
    return AdminPage(
      title: 'Manage Users',
      subtitle: 'Cari, lihat detail, dan kelola data pasien serta keluarga.',
      scrollable: false,
      actions: [
        OutlinedButton.icon(
          onPressed: _isExportingExcel ? null : _exportAllToExcel,
          icon: _isExportingExcel
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_outlined, size: 18),
          label: Text(_isExportingExcel ? 'Mengekspor...' : 'Export Excel'),
        ),
        ElevatedButton.icon(
          onPressed: _openAddUser,
          icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
          label: const Text('Tambah Pengguna'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildUserFilters(),
          const SizedBox(height: 16),
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }

  // ─── CSV Import ───────────────────────────────────────────────
  Future<void> _importFromCSV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;

    final content = utf8.decode(result.files.single.bytes!);
    final rows = CsvDecoder().convert(content);

    if (rows.length < 2) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File CSV kosong atau tidak valid')),
        );
      }
      return;
    }

    final header = rows.first.map((e) => e.toString().trim()).toList();
    final required = ['namaLengkap', 'email', 'password', 'role', 'noKode'];
    final missing = required.where((c) => !header.contains(c)).toList();
    if (missing.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kolom tidak lengkap: ${missing.join(', ')}')),
        );
      }
      return;
    }

    final dataRows = rows.skip(1).where((r) => r.any((c) => c.toString().trim().isNotEmpty)).toList();
    final users = dataRows.map((row) {
      final map = <String, String>{};
      for (int i = 0; i < header.length && i < row.length; i++) {
        map[header[i]] = row[i].toString().trim();
      }
      return map;
    }).toList();

    if (mounted) _showImportPreview(users);
  }

  // ─── Excel Export Semua Data ─────────────────────────────────
  /// Export membaca seluruh isi koleksi. Tampilkan perkiraan jumlah baca
  /// (dihitung murah lewat count()) dan minta konfirmasi dulu.
  Future<bool> _confirmExport() async {
    const cols = [
      'users',
      'food_logs',
      'medication_logs',
      'aktivitas_tidur_logs',
      'latihan_fisik_logs',
      'stress_management_logs',
      'foot_care_logs',
    ];
    int? total;
    try {
      final counts = await Future.wait(
          cols.map((c) => _firestore.collection(c).count().get()));
      total = counts.fold<int>(0, (a, b) => a + (b.count ?? 0));
    } catch (_) {}
    if (!mounted) return false;
    final fmt = NumberFormat.decimalPattern('id_ID');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export semua data?'),
        content: Text(
          total == null
              ? 'Export akan membaca seluruh data pengguna dan catatan aktivitas dari database.'
              : 'Export akan membaca sekitar ${fmt.format(total)} data dari database. '
                  'Gunakan seperlunya agar kuota harian database tidak cepat habis.',
        ),
        actions: [
          OutlinedButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Export')),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _exportAllToExcel() async {
    if (!await _confirmExport()) return;
    setState(() => _isExportingExcel = true);

    try {
      // Fetch semua user + 6 koleksi aktivitas secara paralel
      final results = await Future.wait([
        _firestore.collection('users').orderBy('noKode').get(),
        _firestore.collection('food_logs').get(),
        _firestore.collection('medication_logs').get(),
        _firestore.collection('aktivitas_tidur_logs').get(),
        _firestore.collection('latihan_fisik_logs').get(),
        _firestore.collection('stress_management_logs').get(),
        _firestore.collection('foot_care_logs').get(),
      ]);

      final users      = results[0].docs;
      final foodDocs   = results[1].docs;
      final obatDocs   = results[2].docs;
      final tidurDocs  = results[3].docs;
      final fisikDocs  = results[4].docs;
      final stressDocs = results[5].docs;
      final kakiDocs   = results[6].docs;

      String fmtDate(dynamic ts) {
        if (ts == null) return '-';
        return DateFormat('yyyy-MM-dd').format((ts as Timestamp).toDate());
      }

      int cmpDoc(QueryDocumentSnapshot a, QueryDocumentSnapshot b) {
        final da = a.data() as Map<String, dynamic>;
        final db = b.data() as Map<String, dynamic>;
        final nc = (da['noKode'] ?? '').compareTo(db['noKode'] ?? '');
        if (nc != 0) return nc;
        final at = (da['tanggal'] as Timestamp?)?.toDate() ?? DateTime(1970);
        final bt = (db['tanggal'] as Timestamp?)?.toDate() ?? DateTime(1970);
        return at.compareTo(bt);
      }

      foodDocs.sort(cmpDoc);
      obatDocs.sort(cmpDoc);
      tidurDocs.sort(cmpDoc);
      fisikDocs.sort(cmpDoc);
      stressDocs.sort(cmpDoc);
      kakiDocs.sort(cmpDoc);

      // Helper: tulis header dengan warna & bold, set lebar kolom
      void addSheet(Sheet sheet, List<String> headers, List<double> widths) {
        final headerStyle = CellStyle(
          bold: true,
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
          backgroundColorHex: ExcelColor.fromHexString('#B83B7E'),
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
          textWrapping: TextWrapping.WrapText,
        );
        sheet.setRowHeight(0, 28);
        sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());
        for (int i = 0; i < headers.length; i++) {
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
              .cellStyle = headerStyle;
          if (i < widths.length) sheet.setColumnWidth(i, widths[i]);
        }
      }

      final excel = Excel.createExcel();
      // Jangan hapus Sheet1 dulu — hapus SETELAH semua sheet kustom dibuat

      // ── Sheet 1: Identitas User ──
      final sUser = excel['Identitas User'];
      addSheet(sUser,
        ['No Kode', 'Nama Lengkap', 'Email', 'No HP', 'NIK', 'Alamat', 'Jenis Kelamin', 'Role'],
        [10, 22, 28, 16, 18, 30, 14, 10],
      );
      for (final doc in users) {
        final u = doc.data() as Map<String, dynamic>;
        sUser.appendRow([
          TextCellValue(u['noKode'] ?? '-'),
          TextCellValue(u['namaLengkap'] ?? '-'),
          TextCellValue(u['email'] ?? '-'),
          TextCellValue(u['noHp'] ?? '-'),
          TextCellValue(u['nik'] ?? '-'),
          TextCellValue(u['alamat'] ?? '-'),
          TextCellValue(u['jenisKelamin'] ?? '-'),
          TextCellValue(u['role'] ?? '-'),
        ]);
      }

      // ── Sheet 2: Data Makan ──
      final sMakan = excel['Data Makan'];
      addSheet(sMakan,
        ['No Kode', 'Nama Pasien', 'Tanggal', 'Waktu', 'Menu / Makanan', 'Kategori', 'Waktu Makan', 'Berat (g)', 'Kalori (kkal)', 'Karbohidrat (g)', 'Protein (g)', 'Lemak (g)'],
        [10, 20, 12, 8, 25, 14, 14, 10, 12, 14, 10, 10],
      );
      for (final doc in foodDocs) {
        final d = doc.data() as Map<String, dynamic>;
        sMakan.appendRow([
          TextCellValue(d['noKode'] ?? '-'),
          TextCellValue(d['userName'] ?? '-'),
          TextCellValue(fmtDate(d['tanggal'])),
          TextCellValue(d['jam'] ?? '-'),
          TextCellValue(d['foodName'] ?? '-'),
          TextCellValue(d['kategori'] ?? '-'),
          TextCellValue(d['waktu'] ?? '-'),
          DoubleCellValue((d['grams'] as num?)?.toDouble() ?? 0),
          DoubleCellValue((d['calories'] as num?)?.toDouble() ?? 0),
          DoubleCellValue((d['carbohydrate'] as num?)?.toDouble() ?? 0),
          DoubleCellValue((d['protein'] as num?)?.toDouble() ?? 0),
          DoubleCellValue((d['fat'] as num?)?.toDouble() ?? 0),
        ]);
      }

      // ── Sheet 2: Minum Obat ──
      final sObat = excel['Minum Obat'];
      addSheet(sObat,
        ['No Kode', 'Nama Pasien', 'Tanggal', 'Waktu', 'Waktu Minum', 'Jenis Obat', 'Dosis', 'Satuan'],
        [10, 20, 12, 8, 12, 22, 8, 10],
      );
      for (final doc in obatDocs) {
        final d = doc.data() as Map<String, dynamic>;
        sObat.appendRow([
          TextCellValue(d['noKode'] ?? '-'),
          TextCellValue(d['userName'] ?? '-'),
          TextCellValue(fmtDate(d['tanggal'])),
          TextCellValue(d['jam'] ?? '-'),
          TextCellValue(d['waktu'] ?? '-'),
          TextCellValue(d['jenisObat'] ?? '-'),
          DoubleCellValue((d['dosis'] as num?)?.toDouble() ?? 0),
          TextCellValue(d['satuan'] ?? '-'),
        ]);
      }

      // ── Sheet 3: Aktivitas Tidur ──
      final sTidur = excel['Aktivitas Tidur'];
      addSheet(sTidur,
        ['No Kode', 'Nama Pasien', 'Tanggal', 'Jam Tidur', 'Jam Bangun', 'Durasi (Menit)', 'Kualitas', 'Catatan'],
        [10, 20, 12, 10, 10, 14, 10, 30],
      );
      for (final doc in tidurDocs) {
        final d = doc.data() as Map<String, dynamic>;
        sTidur.appendRow([
          TextCellValue(d['noKode'] ?? '-'),
          TextCellValue(d['userName'] ?? '-'),
          TextCellValue(fmtDate(d['tanggal'])),
          TextCellValue(d['jamTidur'] ?? '-'),
          TextCellValue(d['jamBangun'] ?? '-'),
          IntCellValue((d['durasiMenit'] as num?)?.toInt() ?? 0),
          TextCellValue(d['kualitas'] ?? '-'),
          TextCellValue(d['catatan'] ?? ''),
        ]);
      }

      // ── Sheet 4: Latihan Fisik ──
      final sFisik = excel['Latihan Fisik'];
      addSheet(sFisik,
        ['No Kode', 'Nama Pasien', 'Tanggal', 'Waktu', 'Jenis Olahraga', 'Durasi', 'Satuan', 'Kalori Terbakar (kal)', 'Kategori Intensitas', 'Manfaat'],
        [10, 20, 12, 8, 18, 8, 8, 16, 20, 35],
      );
      for (final doc in fisikDocs) {
        final d = doc.data() as Map<String, dynamic>;
        sFisik.appendRow([
          TextCellValue(d['noKode'] ?? '-'),
          TextCellValue(d['userName'] ?? '-'),
          TextCellValue(fmtDate(d['tanggal'])),
          TextCellValue(d['jam'] ?? '-'),
          TextCellValue(d['jenisOlahraga'] ?? '-'),
          IntCellValue((d['durasi'] as num?)?.toInt() ?? 0),
          TextCellValue(d['satuanDurasi'] ?? 'Menit'),
          IntCellValue((d['kaloriTerbakar'] as num?)?.toInt() ?? 0),
          TextCellValue(d['kategoriIntensitas'] ?? '-'),
          TextCellValue((List<String>.from(d['manfaat'] ?? [])).join('; ')),
        ]);
      }

      // ── Sheet 5: Manajemen Stress ──
      final sStress = excel['Manajemen Stress'];
      addSheet(sStress,
        ['No Kode', 'Nama Pasien', 'Tanggal', 'Waktu', 'Tekanan Darah', 'Perasaan', 'Skor Stress', 'Status Stress', 'Deskripsi Observasi', 'Analisa TD', 'Analisis Perasaan'],
        [10, 20, 12, 8, 14, 16, 11, 16, 30, 25, 25],
      );
      for (final doc in stressDocs) {
        final d = doc.data() as Map<String, dynamic>;
        sStress.appendRow([
          TextCellValue(d['noKode'] ?? '-'),
          TextCellValue(d['userName'] ?? '-'),
          TextCellValue(fmtDate(d['tanggal'])),
          TextCellValue(d['jam'] ?? '-'),
          TextCellValue(d['tekananDarah'] ?? '-'),
          TextCellValue(d['perasaan'] ?? '-'),
          IntCellValue((d['skorStress'] as num?)?.toInt() ?? 0),
          TextCellValue(d['statusStress'] ?? '-'),
          TextCellValue(d['deskripsiObservasi'] ?? '-'),
          TextCellValue(d['analisaTekananDarah'] ?? '-'),
          TextCellValue(d['analisisPerasaan'] ?? '-'),
        ]);
      }

      // ── Sheet 6: Perawatan Kaki ──
      final sKaki = excel['Perawatan Kaki'];
      addSheet(sKaki,
        ['No Kode', 'Nama Pasien', 'Tanggal', 'Waktu', 'Kondisi Kaki', 'Skor Risiko', 'Status Kondisi', 'Deskripsi Observasi', 'Rekomendasi'],
        [10, 20, 12, 8, 30, 11, 16, 30, 35],
      );
      for (final doc in kakiDocs) {
        final d = doc.data() as Map<String, dynamic>;
        sKaki.appendRow([
          TextCellValue(d['noKode'] ?? '-'),
          TextCellValue(d['userName'] ?? '-'),
          TextCellValue(fmtDate(d['tanggal'])),
          TextCellValue(d['jam'] ?? '-'),
          TextCellValue((List<String>.from(d['kondisiKaki'] ?? [])).join('; ')),
          IntCellValue((d['skorRisiko'] as num?)?.toInt() ?? 0),
          TextCellValue(d['statusKondisi'] ?? '-'),
          TextCellValue(d['deskripsiObservasi'] ?? '-'),
          TextCellValue((List<String>.from(d['rekomendasi'] ?? [])).join('; ')),
        ]);
      }

      // Hapus Sheet1 default SETELAH semua sheet kustom dibuat
      // (package tidak bisa hapus sheet jika itu satu-satunya sheet)
      excel.delete('Sheet1');

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'laporan_semua_user_$timestamp.xlsx';

      // Di web, excel.save() sudah otomatis trigger download browser.
      // Di non-web, kita handle sendiri lewat downloadFileToDevice.
      final bytes = excel.save(fileName: fileName);
      if (bytes == null) throw Exception('Gagal membuat file Excel');

      if (!kIsWeb) {
        await downloadFileToDevice(Uint8List.fromList(bytes), fileName);
      }

      if (!mounted) return;
      setState(() => _isExportingExcel = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File Excel berhasil diunduh'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isExportingExcel = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal export: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImportPreview(List<Map<String, String>> users) {
    final passwordController = TextEditingController();
    bool obscure = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Import ${users.length} Pengguna'),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                        columns: const [
                          DataColumn(label: Text('Nama')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Role')),
                          DataColumn(label: Text('No Kode')),
                        ],
                        rows: users.take(10).map((u) => DataRow(cells: [
                          DataCell(Text(u['namaLengkap'] ?? '-')),
                          DataCell(Text(u['email'] ?? '-')),
                          DataCell(Text(u['role'] ?? '-')),
                          DataCell(Text(u['noKode'] ?? '-')),
                        ])).toList(),
                      ),
                    ),
                  ),
                  if (users.length > 10)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('... dan ${users.length - 10} data lainnya',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ),
                  const SizedBox(height: 20),
                  const Text('Masukkan password admin Anda untuk melanjutkan:',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      hintText: 'Password admin',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setDialogState(() => obscure = !obscure),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload, color: Colors.white),
              label: const Text('Import', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB83B7E)),
              onPressed: () async {
                final pass = passwordController.text.trim();
                if (pass.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Password admin tidak boleh kosong')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                await _processImport(users, pass);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processImport(List<Map<String, String>> users, String adminPassword) async {
    final auth = FirebaseAuth.instance;
    final adminUser = auth.currentUser;
    if (adminUser == null) return;
    final adminEmail = adminUser.email!;

    int success = 0;
    int failed = 0;
    final List<String> errors = [];

    // Progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Expanded(child: Text('Sedang mengimpor data pengguna...')),
          ],
        ),
      ),
    );

    for (final user in users) {
      final email = user['email'] ?? '';
      final password = user['password'] ?? '';
      final nama = user['namaLengkap'] ?? '';
      final role = user['role'] ?? '';
      final noKode = user['noKode'] ?? '';

      if (email.isEmpty || password.isEmpty || nama.isEmpty || role.isEmpty || noKode.isEmpty) {
        failed++;
        errors.add('$nama: data tidak lengkap');
        continue;
      }

      try {
        // Buat akun baru
        final cred = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Simpan data ke Firestore
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'namaLengkap': nama,
          'email': email,
          'role': role,
          'noKode': noKode,
          'nik': user['nik'] ?? '',
          'nomorHP': user['nomorHP'] ?? '',
          'jenisKelamin': user['jenisKelamin'] ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });

        success++;

        // Re-login sebagai admin
        await auth.signInWithEmailAndPassword(email: adminEmail, password: adminPassword);
      } catch (e) {
        failed++;
        errors.add('$nama ($email): $e');
        // Pastikan tetap login sebagai admin jika error
        try {
          await auth.signInWithEmailAndPassword(email: adminEmail, password: adminPassword);
        } catch (_) {}
      }
    }

    // Tutup progress dialog
    if (mounted) Navigator.of(context, rootNavigator: true).pop();

    // Tampilkan hasil
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Hasil Import'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Text('Berhasil: $success pengguna'),
                ]),
                if (failed > 0) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('Gagal: $failed pengguna'),
                  ]),
                  const SizedBox(height: 8),
                  ...errors.map((e) => Padding(
                    padding: const EdgeInsets.only(left: 32, bottom: 4),
                    child: Text('• $e', style: const TextStyle(fontSize: 12, color: Colors.red)),
                  )),
                ],
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
  // ─────────────────────────────────────────────────────────────

  Widget _buildUserFilters() {
    final search = TextField(
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: const InputDecoration(
        hintText: 'Cari nama, email, atau NIK…',
        prefixIcon: Icon(Icons.search, size: 20),
      ),
    );

    Widget chip(String value, String label) {
      final selected = _selectedRole == value;
      return Padding(
        padding: const EdgeInsets.all(3),
        child: Material(
          color: selected ? AdminColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => setState(() => _selectedRole = value),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: selected ? Colors.white : AdminColors.textMuted,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final roleFilter = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AdminColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          chip('all', 'Semua'),
          chip('pasien', 'Pasien'),
          chip('keluarga', 'Keluarga'),
        ],
      ),
    );

    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth < 640) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [search, const SizedBox(height: 12), roleFilter],
        );
      }
      return Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: search,
              ),
            ),
          ),
          const SizedBox(width: 16),
          roleFilter,
        ],
      );
    });
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      // Diurutkan di sisi klien agar user tanpa createdAt tetap tampil.
      stream: _usersCtrl.stream,
      initialData: _usersSnap,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return AdminEmptyState(
            icon: Icons.error_outline,
            title: 'Gagal memuat data',
            message: '${snapshot.error}',
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        DateTime createdOf(QueryDocumentSnapshot d) =>
            ((d.data() as Map<String, dynamic>)['createdAt'] as Timestamp?)
                ?.toDate() ??
            DateTime(1970);

        var users = snapshot.data!.docs.toList()
          ..sort((a, b) => createdOf(b).compareTo(createdOf(a)));

        if (_selectedRole != 'all') {
          users = users
              .where((doc) =>
                  (doc.data() as Map<String, dynamic>)['role'] == _selectedRole)
              .toList();
        }

        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          users = users.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            bool has(String key) =>
                (data[key] ?? '').toString().toLowerCase().contains(q);
            return has('namaLengkap') || has('email') || has('nik') || has('noKode');
          }).toList();
        }

        if (users.isEmpty) {
          return AdminCard(
            child: AdminEmptyState(
              icon: Icons.person_search_outlined,
              title: _searchQuery.isEmpty
                  ? 'Belum ada pengguna'
                  : 'Tidak ada hasil untuk "$_searchQuery"',
              message: _searchQuery.isEmpty
                  ? null
                  : 'Coba kata kunci lain atau ubah filter role.',
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 760) {
              return _buildDesktopTable(users);
            }
            return _buildMobileList(users);
          },
        );
      },
    );
  }

  Widget _buildDesktopTable(List<QueryDocumentSnapshot> users) {
    return AdminCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: Text(
              '${users.length} pengguna',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AdminColors.textMuted,
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: LayoutBuilder(builder: (context, c) {
              return Scrollbar(
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: c.maxWidth),
                      child: DataTable(
                        showCheckboxColumn: false,
                        columns: const [
                          DataColumn(label: Text('PENGGUNA')),
                          DataColumn(label: Text('NIK')),
                          DataColumn(label: Text('ROLE')),
                          DataColumn(label: Text('PASSWORD')),
                          DataColumn(label: Text('NOTIFIKASI')),
                          DataColumn(label: Text('AKSI')),
                        ],
                        rows: users.map(_buildUserRow).toList(),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  DataRow _buildUserRow(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final docId = doc.id;
    final nama = (data['namaLengkap'] ?? '-').toString();
    final role = (data['role'] ?? '-').toString();
    final pass = data['password'] as String?;
    final isRevealed = _revealedPasswords.contains(docId);

    return DataRow(
      onSelectChanged: (_) => _showUserDetail(doc),
      cells: [
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AdminAvatar(nama,
                size: 34,
                color: role == 'keluarga'
                    ? AdminColors.keluarga
                    : AdminColors.pasien),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Text(nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Text(
                      '${data['email'] ?? '-'}  ·  Kode ${data['noKode'] ?? '-'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AdminColors.textMuted)),
                ),
              ],
            ),
          ],
        )),
        DataCell(Text((data['nik'] ?? '-').toString(),
            style: const TextStyle(color: AdminColors.textMuted))),
        DataCell(AdminBadge.role(role)),
        DataCell(
          pass == null
              ? const Text('-', style: TextStyle(color: AdminColors.textSubtle))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        isRevealed ? pass : '••••••••',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontFamily: 'monospace',
                            color: AdminColors.textMuted),
                      ),
                    ),
                    AdminIconAction(
                      icon: isRevealed
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      tooltip: isRevealed ? 'Sembunyikan' : 'Tampilkan password',
                      onPressed: () => setState(() {
                        if (isRevealed) {
                          _revealedPasswords.remove(docId);
                        } else {
                          _revealedPasswords.add(docId);
                        }
                      }),
                    ),
                  ],
                ),
        ),
        DataCell(UnreadNotifBadge(
          info: _unreadOf(doc),
          onTap: () => _openNotifications(doc),
        )),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AdminIconAction(
              icon: Icons.open_in_new_rounded,
              tooltip: 'Lihat detail',
              color: AdminColors.info,
              onPressed: () => _showUserDetail(doc),
            ),
            AdminIconAction(
              icon: Icons.notifications_none_rounded,
              tooltip: 'Notifikasi',
              color: AdminColors.primary,
              onPressed: () => _openNotifications(doc),
            ),
            AdminIconAction(
              icon: Icons.edit_outlined,
              tooltip: 'Edit',
              color: AdminColors.warning,
              onPressed: () => _showEditUser(doc),
            ),
            AdminIconAction(
              icon: Icons.delete_outline,
              tooltip: 'Hapus',
              color: AdminColors.danger,
              onPressed: () => _confirmDelete(doc),
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildMobileList(List<QueryDocumentSnapshot> users) {
    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final doc = users[index];
        final data = doc.data() as Map<String, dynamic>;
        final nama = (data['namaLengkap'] ?? '-').toString();
        final role = (data['role'] ?? '-').toString();
        return AdminCard(
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: () => _showUserDetail(doc),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 4, 14),
              child: Row(
                children: [
                  AdminAvatar(nama,
                      color: role == 'keluarga'
                          ? AdminColors.keluarga
                          : AdminColors.pasien),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nama,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text((data['email'] ?? '-').toString(),
                            style: const TextStyle(
                                fontSize: 13, color: AdminColors.textMuted)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            AdminBadge.role(role),
                            UnreadNotifBadge(
                              info: _unreadOf(doc),
                              compact: true,
                              onTap: () => _openNotifications(doc),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Aksi',
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'view', child: Text('Lihat detail')),
                      PopupMenuItem(value: 'notif', child: Text('Notifikasi')),
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Hapus')),
                    ],
                    onSelected: (value) {
                      if (value == 'view') _showUserDetail(doc);
                      if (value == 'notif') _openNotifications(doc);
                      if (value == 'edit') _showEditUser(doc);
                      if (value == 'delete') _confirmDelete(doc);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openNotifications(DocumentSnapshot doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserNotificationsScreen(
          target: NotifTarget.fromDoc(doc),
          admin: widget.admin,
        ),
      ),
    );
  }

  void _showPasienDetail(QueryDocumentSnapshot doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PasienManageScreen(
          userRef: _firestore.collection('users').doc(doc.id),
          admin: widget.admin,
        ),
      ),
    );
  }

  void _showUserDetail(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    if (data['role'] == 'pasien') {
      _showPasienDetail(doc);
      return;
    }
    
    final nama = (data['namaLengkap'] ?? '-').toString();
    final role = (data['role'] ?? '-').toString();
    String v(String key) {
      final val = data[key]?.toString().trim() ?? '';
      return val.isEmpty ? '-' : val;
    }

    showDialog(
      context: context,
      builder: (context) {
        bool obscurePass = true;
        final pass = data['password'] as String?;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            title: Row(
              children: [
                AdminAvatar(nama,
                    size: 48,
                    color: role == 'keluarga'
                        ? AdminColors.keluarga
                        : AdminColors.pasien),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nama,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          AdminBadge.role(role),
                          const SizedBox(width: 8),
                          Text('Kode ${v('noKode')}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: AdminColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 24,
                      runSpacing: 16,
                      children: [
                        _buildDetailRow('Email', v('email')),
                        _buildDetailRow('NIK', v('nik')),
                        _buildDetailRow('No HP', v('noHp')),
                        _buildDetailRow('Jenis Kelamin', v('jenisKelamin')),
                        _buildDetailRow('Alamat', v('alamat')),
                        SizedBox(
                          width: 216,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Password',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AdminColors.textMuted,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      pass == null
                                          ? '-'
                                          : (obscurePass ? '••••••••' : pass),
                                      style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 15,
                                          color: AdminColors.text),
                                    ),
                                  ),
                                  if (pass != null)
                                    AdminIconAction(
                                      icon: obscurePass
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      tooltip: obscurePass
                                          ? 'Tampilkan'
                                          : 'Sembunyikan',
                                      onPressed: () => setDialogState(
                                          () => obscurePass = !obscurePass),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _openNotifications(doc);
                },
                icon: const Icon(Icons.notifications_none_rounded, size: 18),
                label: const Text('Notifikasi'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showEditUser(doc);
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return SizedBox(
      width: 216,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AdminColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 15, color: AdminColors.text),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditUser(QueryDocumentSnapshot doc) async {
    final ok = await showEditUserDialog(context, doc: doc, admin: widget.admin);
    if (ok == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data pengguna diperbarui')),
      );
    }
  }

  void _confirmDelete(QueryDocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus user ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestore.collection('users').doc(doc.id).delete();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User berhasil dihapus')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    // AdminAuthGate otomatis kembali ke halaman login.
    await FirebaseAuth.instance.signOut();
  }
}

/// Logo + nama aplikasi di sidebar / app bar admin.
class _BrandMark extends StatelessWidget {
  final bool compact;
  const _BrandMark({this.compact = false});

  @override
  Widget build(BuildContext context) {
    final size = compact ? 32.0 : 40.0;
    return Row(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(compact ? 9 : 11),
          ),
          child: Icon(Icons.favorite_rounded,
              color: AdminColors.primary, size: size * 0.55),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Promedia',
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 16 : 19,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            Text(
              'Admin Panel',
              style: TextStyle(
                color: Colors.white60,
                fontSize: compact ? 11 : 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
