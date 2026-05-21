import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/theme_provider.dart';
import '../pin_lock_screen.dart';

class KeamananScreen extends StatefulWidget {
  const KeamananScreen({super.key});

  @override
  State<KeamananScreen> createState() => _KeamananScreenState();
}

class _KeamananScreenState extends State<KeamananScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Keamanan & Privasi'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              _buildSectionHeader('Autentikasi Utama'),
              _buildSwitchItem(
                context: context,
                icon: Icons.lock_outline,
                iconColor: const Color(0xFF1E60FE),
                title: 'Gunakan PIN saat Masuk',
                subtitle: 'Wajibkan PIN setiap membuka aplikasi',
                value: themeProvider.isPinEnabled,
                onChanged: (val) {
                  themeProvider.setPinEnabled(val);
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(height: 1, color: Colors.grey, thickness: 0.2),
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.pin_outlined,
                iconColor: const Color(0xFFF59E0B),
                title: 'Ubah PIN',
                subtitle: 'Ganti PIN untuk keamanan ekstra',
                enabled: themeProvider.isPinEnabled,
                onTap: () => _showPinLengthDialog(context),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Autentikasi Alternatif'),
              _buildSwitchItem(
                context: context,
                icon: Icons.fingerprint,
                iconColor: const Color(0xFF10B981),
                title: 'Login Biometrik',
                subtitle: 'Gunakan Sidik Jari atau Face ID',
                value: themeProvider.isBiometricEnabled,
                enabled: themeProvider.isPinEnabled,
                onChanged: (val) {
                  themeProvider.setBiometricEnabled(val);
                  if (val) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Autentikasi biometrik diaktifkan!')),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Keamanan Tambahan'),
              _buildMenuItem(
                context: context,
                icon: Icons.visibility_off_outlined,
                iconColor: const Color(0xFF6366F1),
                title: 'Mode Privasi',
                subtitle: 'Sembunyikan saldo di halaman beranda',
                enabled: true,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur Mode Privasi akan segera hadir')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8, top: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: SwitchListTile(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: const Color(0xFF1E60FE),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: ListTile(
        onTap: enabled ? onTap : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      ),
    );
  }

  void _showPinLengthDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(top: 12, bottom: 40, left: 24, right: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Pilih Jenis PIN', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Pilih tingkat keamanan untuk melindungi akun dan saldomu.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 14)),
            const SizedBox(height: 24),
            
            _buildPinOptionCard(
              context: context,
              icon: Icons.password,
              title: 'PIN 6 Digit',
              subtitle: 'Keamanan ekstra, sangat direkomendasikan',
              color: const Color(0xFF10B981), // Emerald
              onTap: () {
                Navigator.pop(context);
                _navigateToSetPin(context, 6);
              },
            ),
            const SizedBox(height: 16),
            _buildPinOptionCard(
              context: context,
              icon: Icons.pin_outlined,
              title: 'PIN 4 Digit',
              subtitle: 'Standar keamanan dasar yang mudah diingat',
              color: const Color(0xFF3B82F6), // Blue
              onTap: () {
                Navigator.pop(context);
                _navigateToSetPin(context, 4);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          borderRadius: BorderRadius.circular(16),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  void _navigateToSetPin(BuildContext context, int length) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PinLockScreen(
        isSettingPin: true,
        pinLength: length,
        onPinVerified: (newPin) {
          context.read<ThemeProvider>().updatePin(newPin);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PIN Berhasil Diperbarui!'), backgroundColor: Colors.green),
          );
        },
      )),
    );
  }
}
