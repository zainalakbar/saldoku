import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  // Track which FAQ item is expanded
  int? _expandedIndex;

  final List<Map<String, String>> _faqs = [
    {
      'q': 'Bagaimana cara mencatat transaksi?',
      'a':
          'Tekan tombol + (plus) besar di bagian bawah layar. Pilih tipe transaksi (Pemasukan atau Pengeluaran), isi nominal, keterangan, kategori, dan tanggal, lalu tekan "Simpan Transaksi".',
    },
    {
      'q': 'Apa itu fitur Budget?',
      'a':
          'Budget adalah batas maksimal pengeluaran per kategori dalam sebulan. Kamu bisa mengatur budget di bagian Dashboard atau Statistik. Saldo akan otomatis dipantau dan kamu akan diperingatkan jika mendekati batas.',
    },
    {
      'q': 'Bagaimana cara menggunakan Split Bill?',
      'a':
          'Buka menu Split Bill dari fitur andalan di Dashboard. Masukkan total tagihan, jumlah orang, dan nama masing-masing. Aplikasi akan otomatis menghitung bagian setiap orang.',
    },
    {
      'q': 'Bagaimana cara mencatat hutang?',
      'a':
          'Buka menu Hutang dari fitur andalan di Dashboard. Tambahkan data hutang (nama, nominal, tanggal jatuh tempo). Hutang yang lunas bisa ditandai agar riwayatnya tetap tersimpan.',
    },
    {
      'q': 'Apa itu Transaksi Rutin?',
      'a':
          'Transaksi rutin adalah pengeluaran/pemasukan yang terjadi secara berkala, seperti bayar kos, langganan, atau gaji. Kamu bisa atur di menu Transaksi Rutin agar tidak lupa mencatatnya.',
    },
    {
      'q': 'Bagaimana cara mengekspor data?',
      'a':
          'Buka Akun → Data & Dukungan → Backup & Ekspor Data. Data transaksimu akan dikonversi ke format CSV yang bisa dibuka di aplikasi spreadsheet seperti Excel atau Google Sheets.',
    },
    {
      'q': 'Apakah data saya aman?',
      'a':
          'Ya. Semua data tersimpan secara lokal di perangkat kamu menggunakan database SQLite. Data tidak dikirim ke server manapun. Pastikan kamu rutin melakukan backup agar data tidak hilang.',
    },
    {
      'q': 'Bagaimana cara mengaktifkan Mode Gelap?',
      'a':
          'Buka Akun → Keamanan & Pengaturan → toggle "Mode Gelap". Perubahan tampilan akan langsung terlihat tanpa perlu restart aplikasi.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pusat Bantuan',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Banner ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E60FE), Color(0xFF548CFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.support_agent_rounded,
                        color: Colors.white, size: 48),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Ada yang bisa kami bantu?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Temukan jawaban dari pertanyaan yang sering ditanyakan di bawah ini.',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Tombol Lihat Panduan ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSectionTitle('Panduan Penggunaan'),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const OnboardingScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E60FE).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.play_circle_outline_rounded,
                            color: Color(0xFF1E60FE), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lihat Panduan Lagi',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tampilkan ulang tutorial cara menggunakan Saldoku.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          size: 14, color: Color(0xFFD1D5DB)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── FAQ Section ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSectionTitle('Pertanyaan Umum (FAQ)'),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: List.generate(_faqs.length, (index) {
                    final isExpanded = _expandedIndex == index;
                    final isLast = index == _faqs.length - 1;
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _expandedIndex =
                                  isExpanded ? null : index;
                            });
                          },
                          borderRadius: BorderRadius.vertical(
                            top: index == 0
                                ? const Radius.circular(16)
                                : Radius.zero,
                            bottom: isLast
                                ? const Radius.circular(16)
                                : Radius.zero,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: isExpanded
                                        ? const Color(0xFF1E60FE)
                                            .withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.help_outline_rounded,
                                    size: 16,
                                    color: isExpanded
                                        ? const Color(0xFF1E60FE)
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _faqs[index]['q']!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isExpanded
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isExpanded
                                          ? const Color(0xFF1E60FE)
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                AnimatedRotation(
                                  turns: isExpanded ? 0.5 : 0,
                                  duration:
                                      const Duration(milliseconds: 250),
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: isExpanded
                                        ? const Color(0xFF1E60FE)
                                        : Colors.grey,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        AnimatedCrossFade(
                          firstChild: const SizedBox.shrink(),
                          secondChild: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 16),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E60FE).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFF1E60FE)
                                      .withOpacity(0.15)),
                            ),
                            child: Text(
                              _faqs[index]['a']!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7),
                                height: 1.6,
                              ),
                            ),
                          ),
                          crossFadeState: isExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 250),
                        ),
                        if (!isLast)
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Tentang Aplikasi ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSectionTitle('Tentang Saldoku'),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // App logo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E60FE), Color(0xFF548CFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded,
                          color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Saldoku',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Versi 1.0.0',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    _buildAboutRow(context, Icons.school_rounded,
                        'Dibuat untuk', 'Tugas Kuliah Semester 4'),
                    const SizedBox(height: 12),
                    _buildAboutRow(context, Icons.code_rounded,
                        'Dibangun dengan', 'Flutter & Dart'),
                    const SizedBox(height: 12),
                    _buildAboutRow(context, Icons.storage_rounded,
                        'Penyimpanan', 'SQLite (Lokal)'),
                    const SizedBox(height: 12),
                    _buildAboutRow(context, Icons.shield_rounded,
                        'Privasi', 'Data 100% tersimpan di perangkat'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildAboutRow(
      BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1E60FE)),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
