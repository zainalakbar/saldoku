import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/notification_provider.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pengaturan Notifikasi',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notifProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header ilustrasi
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
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
                      const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 48),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Notifikasi In-App',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Atur notifikasi yang muncul saat kamu menggunakan Saldoku.',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Grup: Transaksi
                _buildSectionTitle(context, 'Transaksi'),
                const SizedBox(height: 12),
                _buildToggleCard(
                  context: context,
                  isDark: isDark,
                  icon: Icons.receipt_long_rounded,
                  iconColor: const Color(0xFF10B981),
                  title: 'Notifikasi Transaksi',
                  subtitle: 'Muncul popup saat transaksi baru berhasil dicatat.',
                  value: notifProvider.transactionNotif,
                  onChanged: notifProvider.setTransactionNotif,
                ),
                const SizedBox(height: 24),

                // Grup: Budget
                _buildSectionTitle(context, 'Budget & Pengeluaran'),
                const SizedBox(height: 12),
                _buildToggleCard(
                  context: context,
                  isDark: isDark,
                  icon: Icons.pie_chart_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Peringatan Budget',
                  subtitle: 'Ingatkan saat pengeluaran mendekati atau melewati batas budget kategori.',
                  value: notifProvider.budgetAlertNotif,
                  onChanged: notifProvider.setBudgetAlertNotif,
                ),
                const SizedBox(height: 24),

                // Grup: Hutang
                _buildSectionTitle(context, 'Hutang & Piutang'),
                const SizedBox(height: 12),
                _buildToggleCard(
                  context: context,
                  isDark: isDark,
                  icon: Icons.handshake_rounded,
                  iconColor: const Color(0xFFEF4444),
                  title: 'Pengingat Hutang',
                  subtitle: 'Tampilkan pengingat saat ada hutang yang belum lunas.',
                  value: notifProvider.debtReminderNotif,
                  onChanged: notifProvider.setDebtReminderNotif,
                ),
                const SizedBox(height: 32),

                // Info box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E60FE).withOpacity(0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF1E60FE).withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Color(0xFF1E60FE), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Notifikasi ini hanya muncul di dalam aplikasi Saldoku saat kamu sedang menggunakannya.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
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

  Widget _buildToggleCard({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Future<void> Function(bool) onChanged,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF1E60FE),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}
