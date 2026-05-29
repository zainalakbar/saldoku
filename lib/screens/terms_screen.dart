import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
          'Syarat & Ketentuan',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E60FE), Color(0xFF548CFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.gavel_rounded, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Syarat & Ketentuan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Harap baca syarat dan ketentuan berikut sebelum menggunakan aplikasi Saldoku.',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Terakhir diperbarui: Mei 2026',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sections
            _buildSection(
              context: context,
              isDark: isDark,
              icon: Icons.info_outline_rounded,
              iconColor: const Color(0xFF1E60FE),
              title: '1. Tentang Aplikasi',
              content:
                  'Saldoku adalah aplikasi manajemen keuangan pribadi yang dikembangkan sebagai proyek akademik. Aplikasi ini dirancang untuk membantu pengguna mencatat, memantau, dan menganalisis pengeluaran serta pemasukan sehari-hari.',
            ),
            const SizedBox(height: 16),

            _buildSection(
              context: context,
              isDark: isDark,
              icon: Icons.person_outline_rounded,
              iconColor: const Color(0xFF10B981),
              title: '2. Penggunaan Aplikasi',
              content:
                  'Dengan menggunakan Saldoku, kamu setuju bahwa:\n\n• Aplikasi ini digunakan untuk keperluan pencatatan keuangan pribadi.\n• Kamu bertanggung jawab atas keakuratan data yang diinput.\n• Aplikasi tidak boleh digunakan untuk tujuan ilegal atau menyalahi hukum yang berlaku.\n• Pengguna wajib menjaga kerahasiaan PIN atau metode keamanan yang diaktifkan.',
            ),
            const SizedBox(height: 16),

            _buildSection(
              context: context,
              isDark: isDark,
              icon: Icons.storage_rounded,
              iconColor: const Color(0xFF8B5CF6),
              title: '3. Penyimpanan Data',
              content:
                  'Seluruh data transaksi, anggaran, dan informasi profil disimpan secara lokal di perangkat pengguna menggunakan database SQLite. Saldoku tidak mengirimkan data apapun ke server eksternal. Data sepenuhnya berada di bawah kendali pengguna.',
            ),
            const SizedBox(height: 16),

            _buildSection(
              context: context,
              isDark: isDark,
              icon: Icons.shield_outlined,
              iconColor: const Color(0xFFF59E0B),
              title: '4. Privasi & Keamanan',
              content:
                  'Kami menghargai privasi penggunamu:\n\n• Tidak ada data yang dikumpulkan atau diteruskan ke pihak ketiga.\n• Fitur PIN dan keamanan biometrik bersifat opsional namun sangat dianjurkan.\n• Developer tidak bertanggung jawab atas akses tidak sah akibat kelalaian pengguna dalam menjaga perangkatnya.',
            ),
            const SizedBox(height: 16),

            _buildSection(
              context: context,
              isDark: isDark,
              icon: Icons.backup_rounded,
              iconColor: const Color(0xFFEF4444),
              title: '5. Kehilangan Data',
              content:
                  'Saldoku tidak menyediakan layanan backup berbasis cloud. Pengguna dianjurkan untuk secara rutin melakukan ekspor data melalui menu Backup & Ekspor Data. Developer tidak bertanggung jawab atas kehilangan data akibat:\n\n• Penghapusan aplikasi\n• Kerusakan atau penggantian perangkat\n• Reset pabrik (factory reset)',
            ),
            const SizedBox(height: 16),

            _buildSection(
              context: context,
              isDark: isDark,
              icon: Icons.update_rounded,
              iconColor: const Color(0xFF06B6D4),
              title: '6. Perubahan Ketentuan',
              content:
                  'Developer berhak memperbarui syarat dan ketentuan ini sewaktu-waktu tanpa pemberitahuan sebelumnya. Perubahan akan berlaku sejak dipublikasikan di dalam aplikasi. Penggunaan berkelanjutan dianggap sebagai persetujuan terhadap ketentuan terbaru.',
            ),
            const SizedBox(height: 16),

            _buildSection(
              context: context,
              isDark: isDark,
              icon: Icons.school_rounded,
              iconColor: const Color(0xFF1E60FE),
              title: '7. Penggunaan Akademik',
              content:
                  'Saldoku dikembangkan dalam rangka memenuhi tugas mata kuliah Semester 4. Aplikasi ini bukan produk komersial. Seluruh fitur dikembangkan dengan tujuan pembelajaran dan demonstrasi kemampuan pengembangan aplikasi mobile menggunakan Flutter.',
            ),
            const SizedBox(height: 24),

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    '© 2026 Saldoku. All rights reserved.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dibuat dengan ❤️ menggunakan Flutter',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 13,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
