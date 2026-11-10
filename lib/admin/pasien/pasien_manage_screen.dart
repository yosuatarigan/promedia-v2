import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promedia_v2/admin/admin_session.dart';
import 'package:promedia_v2/admin/admin_ui.dart';
import 'package:promedia_v2/admin/pasien/activity_config.dart';
import 'package:promedia_v2/admin/pasien/activity_editor.dart';
import 'package:promedia_v2/admin/pasien/activity_table.dart';
import 'package:promedia_v2/admin/pasien/edit_user_dialog.dart';

/// Halaman kelola satu pasien: profil lengkap + semua catatan aktivitas.
class PasienManageScreen extends StatefulWidget {
  final DocumentReference<Map<String, dynamic>> userRef;
  final AdminProfile admin;

  const PasienManageScreen({
    super.key,
    required this.userRef,
    required this.admin,
  });

  @override
  State<PasienManageScreen> createState() => _PasienManageScreenState();
}

class _PasienManageScreenState extends State<PasienManageScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: kActivityConfigs.length + 1, vsync: this);
    _userStream = widget.userRef.snapshots();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _userStream,
      builder: (context, snap) {
        if (snap.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: AdminEmptyState(
                icon: Icons.error_outline,
                title: 'Gagal memuat pasien',
                message: '${snap.error}'),
          );
        }
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final doc = snap.data!;
        if (!doc.exists) {
          return Scaffold(
            appBar: AppBar(),
            body: const AdminEmptyState(
                icon: Icons.person_off_outlined,
                title: 'Pasien tidak ditemukan',
                message: 'Data pasien ini mungkin sudah dihapus.'),
          );
        }
        final data = doc.data()!;
        final pasien = PasienRef(
          uid: doc.id,
          nama: (data['namaLengkap'] ?? '-').toString(),
          noKode: (data['noKode'] ?? '').toString(),
        );

        return Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(doc, data),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _SummaryTab(
                      data: data,
                      pasien: pasien,
                      onOpenTab: (i) => _tabs.animateTo(i + 1),
                    ),
                    for (final c in kActivityConfigs)
                      _TabPadding(
                        child: ActivityTable(
                          config: c,
                          pasien: pasien,
                          admin: widget.admin,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      DocumentSnapshot<Map<String, dynamic>> doc, Map<String, dynamic> data) {
    final nama = (data['namaLengkap'] ?? '-').toString();
    final wide = MediaQuery.of(context).size.width >= 720;
    return Material(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(wide ? 20 : 8, 16, wide ? 32 : 16, 12),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Kembali',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 8),
                AdminAvatar(nama, size: 48),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nama,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AdminColors.text)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          AdminBadge.role('pasien'),
                          Text('Kode ${data['noKode'] ?? '-'}',
                              style: const TextStyle(
                                  fontSize: 13, color: AdminColors.textMuted)),
                          if (wide)
                            Text('·  ${data['email'] ?? '-'}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AdminColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final ok = await showEditUserDialog(context,
                        doc: doc, admin: widget.admin);
                    if (ok == true && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profil diperbarui')));
                    }
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(wide ? 'Edit Profil' : 'Edit'),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: EdgeInsets.symmetric(horizontal: wide ? 20 : 4),
            labelColor: AdminColors.primary,
            unselectedLabelColor: AdminColors.textMuted,
            indicatorColor: AdminColors.primary,
            indicatorWeight: 2.5,
            dividerColor: AdminColors.border,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            tabs: [
              const Tab(
                  icon: Icon(Icons.dashboard_outlined, size: 18),
                  iconMargin: EdgeInsets.only(bottom: 2),
                  text: 'Ringkasan'),
              for (final c in kActivityConfigs)
                Tab(
                    icon: Icon(c.icon, size: 18),
                    iconMargin: const EdgeInsets.only(bottom: 2),
                    text: c.title),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabPadding extends StatelessWidget {
  final Widget child;
  const _TabPadding({required this.child});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Padding(
      padding: w < 600 ? const EdgeInsets.all(12) : const EdgeInsets.all(24),
      child: child,
    );
  }
}

// ───────────────────────── Ringkasan ─────────────────────────

class _SummaryTab extends StatefulWidget {
  final Map<String, dynamic> data;
  final PasienRef pasien;
  final ValueChanged<int> onOpenTab;

  const _SummaryTab({
    required this.data,
    required this.pasien,
    required this.onOpenTab,
  });

  @override
  State<_SummaryTab> createState() => _SummaryTabState();
}

class _SummaryTabState extends State<_SummaryTab>
    with AutomaticKeepAliveClientMixin {
  late Future<List<QuerySnapshot<Map<String, dynamic>>>> _activity;
  late Future<QuerySnapshot<Map<String, dynamic>>> _keluarga;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final db = FirebaseFirestore.instance;
    final kode = widget.pasien.noKode;
    _activity = Future.wait(kActivityConfigs.map((c) =>
        db.collection(c.collection).where('noKode', isEqualTo: kode).get()));
    _keluarga = db
        .collection('users')
        .where('noKode', isEqualTo: kode)
        .where('role', isEqualTo: 'keluarga')
        .get();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth >= 1000;
      final pad = c.maxWidth < 600 ? 12.0 : 24.0;
      final left = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildActivityGrid(c.maxWidth - pad * 2, wide),
          const SizedBox(height: 16),
          _buildGlucoseChart(),
        ],
      );
      final right = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProfileCard(),
          const SizedBox(height: 16),
          _buildKaloriCard(),
          const SizedBox(height: 16),
          _buildKeluargaCard(),
        ],
      );
      return RefreshIndicator(
        onRefresh: () async {
          setState(_load);
          await _activity;
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: left),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: right),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [right, const SizedBox(height: 16), left],
                ),
        ),
      );
    });
  }

  Widget _buildActivityGrid(double fullWidth, bool wide) {
    return FutureBuilder<List<QuerySnapshot<Map<String, dynamic>>>>(
      future: _activity,
      builder: (context, snap) {
        return AdminCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AdminCardTitle('Catatan Aktivitas',
                  subtitle: 'Jumlah catatan dan input terakhir',
                  trailing: IconButton(
                    tooltip: 'Muat ulang',
                    onPressed: () => setState(_load),
                    icon: const Icon(Icons.refresh,
                        size: 20, color: AdminColors.textMuted),
                  )),
              const SizedBox(height: 16),
              if (snap.hasError)
                Text('Gagal memuat: ${snap.error}',
                    style: const TextStyle(color: AdminColors.danger))
              else
                LayoutBuilder(builder: (context, box) {
                  final cols = box.maxWidth >= 640 ? 4 : 2;
                  const gap = 12.0;
                  final w = (box.maxWidth - gap * (cols - 1)) / cols;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (var i = 0; i < kActivityConfigs.length; i++)
                        SizedBox(
                          width: w,
                          child: _activityTile(
                              i, snap.hasData ? snap.data![i] : null),
                        ),
                    ],
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _activityTile(int i, QuerySnapshot<Map<String, dynamic>>? q) {
    final c = kActivityConfigs[i];
    String last = '…';
    String count = '…';
    if (q != null) {
      count = '${q.size}';
      DateTime? latest;
      for (final d in q.docs) {
        final t = activityDate(c, d.data());
        if (t != null && (latest == null || t.isAfter(latest))) latest = t;
      }
      last = latest == null
          ? 'Belum ada'
          : 'Terakhir ${DateFormat('d MMM yy', 'id_ID').format(latest)}';
    }
    return InkWell(
      onTap: () => widget.onOpenTab(i),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: AdminColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: c.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(c.icon, size: 18, color: c.color),
                ),
                const Spacer(),
                Text(count,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AdminColors.text)),
              ],
            ),
            const SizedBox(height: 10),
            Text(c.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: AdminColors.text)),
            Text(last,
                style: const TextStyle(
                    fontSize: 12, color: AdminColors.textSubtle)),
          ],
        ),
      ),
    );
  }

  Widget _buildGlucoseChart() {
    final gula = kActivityConfigs.indexWhere((c) => c.id == 'gula');
    return FutureBuilder<List<QuerySnapshot<Map<String, dynamic>>>>(
      future: _activity,
      builder: (context, snap) {
        final c = kActivityConfigs[gula];
        final docs = snap.hasData
            ? (snap.data![gula].docs.toList()
              ..sort((a, b) => (activityDate(c, a.data()) ?? DateTime(1970))
                  .compareTo(activityDate(c, b.data()) ?? DateTime(1970))))
            : <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        final recent = docs.length > 14 ? docs.sublist(docs.length - 14) : docs;

        const series = [
          ('gulaDarahPuasa', 'Puasa', AdminColors.info),
          ('gulaDarahSewaktu', 'Sewaktu', AdminColors.warning),
          ('gulaDarah2JamPP', '2 Jam PP', AdminColors.primary),
        ];

        List<FlSpot> spots(String key) => [
              for (var i = 0; i < recent.length; i++)
                if ((recent[i].data()[key] as num?) != null &&
                    (recent[i].data()[key] as num) > 0)
                  FlSpot(i.toDouble(),
                      (recent[i].data()[key] as num).toDouble()),
            ];

        return AdminCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AdminCardTitle('Tren Gula Darah',
                  subtitle: recent.isEmpty
                      ? 'Belum ada catatan gula darah'
                      : '${recent.length} catatan terakhir (mg/dL)',
                  trailing: TextButton(
                      onPressed: () => widget.onOpenTab(gula),
                      child: const Text('Lihat data'))),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                children: [
                  for (final s in series)
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              color: s.$3, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(s.$2,
                          style: const TextStyle(
                              fontSize: 12, color: AdminColors.textMuted)),
                    ]),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 240,
                child: !snap.hasData
                    ? const Center(child: CircularProgressIndicator())
                    : recent.isEmpty
                        ? const Center(
                            child: Text('Belum ada data',
                                style:
                                    TextStyle(color: AdminColors.textSubtle)))
                        : LineChart(
                            LineChartData(
                              minY: 0,
                              gridData: FlGridData(
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (_) => const FlLine(
                                    color: AdminColors.divider, strokeWidth: 1),
                              ),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (v, m) => Text(
                                        v.toInt().toString(),
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AdminColors.textSubtle)),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 28,
                                    interval: recent.length > 7 ? 2 : 1,
                                    getTitlesWidget: (v, m) {
                                      final i = v.toInt();
                                      if (i < 0 || i >= recent.length || v != i) {
                                        return const SizedBox();
                                      }
                                      final t = activityDate(c, recent[i].data());
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                            t == null
                                                ? ''
                                                : DateFormat('d/M').format(t),
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: AdminColors.textSubtle)),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              lineBarsData: [
                                for (final s in series)
                                  LineChartBarData(
                                    spots: spots(s.$1),
                                    isCurved: true,
                                    curveSmoothness: 0.25,
                                    color: s.$3,
                                    barWidth: 2.5,
                                    dotData: FlDotData(
                                      getDotPainter: (p, d, b, i) =>
                                          FlDotCirclePainter(
                                              radius: 3,
                                              color: Colors.white,
                                              strokeWidth: 2,
                                              strokeColor: s.$3),
                                    ),
                                  ),
                              ],
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _info(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 160,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: AdminColors.textMuted)),
            ),
            Expanded(
              child: Text(value,
                  style:
                      const TextStyle(fontSize: 14, color: AdminColors.text)),
            ),
          ],
        ),
      );

  Widget _buildProfileCard() {
    final d = widget.data;
    final lama = d['lamaMenderitaDM'];
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AdminCardTitle('Data Pasien'),
          const SizedBox(height: 10),
          _info('NIK', str(d['nik'])),
          _info('Jenis kelamin', str(d['jenisKelamin'])),
          _info('No HP', str(d['noHp'])),
          _info('Email', str(d['email'])),
          _info('Alamat', str(d['alamat'])),
          const Divider(height: 20),
          _info('Pendidikan', str(d['pendidikan'])),
          _info('Lama menderita DM', lama == null ? '-' : '$lama tahun'),
          _info('Keluarga pendamping', str(d['keluargaPendamping'])),
        ],
      ),
    );
  }

  Widget _buildKaloriCard() {
    final d = widget.data;
    final k = (d['kebutuhanKalori'] as num?)?.round();
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AdminCardTitle('Kebutuhan Kalori'),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(k == null ? '-' : NumberFormat.decimalPattern('id_ID').format(k),
                  style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AdminColors.text,
                      height: 1)),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text('kkal / hari',
                    style: TextStyle(color: AdminColors.textMuted)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (k == null)
            const Text('Belum dihitung. Isi lewat tombol Edit Profil.',
                style: TextStyle(fontSize: 13, color: AdminColors.textMuted))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AdminBadge('Usia ${fmtNum(d['usiaKalori'])} th',
                    color: AdminColors.textMuted),
                AdminBadge('TB ${fmtNum(d['tbKalori'], decimals: 1)} cm',
                    color: AdminColors.textMuted),
                AdminBadge('BB ${fmtNum(d['bbKalori'], decimals: 1)} kg',
                    color: AdminColors.textMuted),
                if (d['aktivitasKalori'] != null)
                  AdminBadge(
                      (d['aktivitasKalori'] as String).split(':').first,
                      color: AdminColors.warning),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildKeluargaCard() {
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: _keluarga,
      builder: (context, snap) {
        final docs = snap.data?.docs ?? [];
        return AdminCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AdminCardTitle('Keluarga Pendamping',
                  subtitle: 'Akun keluarga dengan no kode yang sama'),
              const SizedBox(height: 12),
              if (!snap.hasData)
                const LinearProgressIndicator()
              else if (docs.isEmpty)
                const Text('Belum ada akun keluarga terhubung.',
                    style:
                        TextStyle(fontSize: 13, color: AdminColors.textMuted))
              else
                for (final k in docs)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        AdminAvatar((k.data()['namaLengkap'] ?? '-').toString(),
                            size: 32, color: AdminColors.keluarga),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(str(k.data()['namaLengkap']),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              Text(
                                  '${str(k.data()['noHp'])}  ·  ${str(k.data()['email'])}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AdminColors.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}
