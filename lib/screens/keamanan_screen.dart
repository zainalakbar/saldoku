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
            title: const Text('Keamanan & Akses'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah PIN', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Berapa digit PIN yang ingin kamu gunakan?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToSetPin(context, 4);
            },
            child: const Text('4 Digit', style: TextStyle(color: Color(0xFF1E60FE), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToSetPin(context, 6);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E60FE),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('6 Digit', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
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
