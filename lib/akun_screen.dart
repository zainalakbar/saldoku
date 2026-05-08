import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'logic/theme_provider.dart';
import 'logic/transaction_provider.dart';
import 'pin_lock_screen.dart';

class AkunScreen extends StatefulWidget {
  const AkunScreen({super.key});

  @override
  State<AkunScreen> createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunScreen> {
  // Local variable removed, using Provider instead

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      if (mounted) {
        Provider.of<ThemeProvider>(context, listen: false).setProfileImage(pickedFile.path);
      }
    }
  }


  void _showEditProfileDialog() {
    final TextEditingController _controller = TextEditingController(
      text: Provider.of<ThemeProvider>(context, listen: false).userName
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Edit Nama Profil', style: Theme.of(context).textTheme.titleLarge),
        content: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Masukkan nama baru',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                Provider.of<ThemeProvider>(context, listen: false).setUserName(_controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text('Akun Saya', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                // Header Profil
                _buildProfileHeader(context),
                const SizedBox(height: 32),
                
                // Grup 1: Pengaturan Keamanan
                _buildMenuGroup(
                  context: context,
                  title: 'Keamanan & Pengaturan',
                  items: [
                    _buildMenuItem(context, Icons.lock_outline, 'Keamanan & PIN', const Color(0xFF1E60FE)),
                    _buildThemeToggle(context, themeProvider),
                    _buildMenuItem(context, Icons.notifications_none, 'Notifikasi', const Color(0xFFF59E0B)),
                    _buildMenuItem(context, Icons.language, 'Bahasa', const Color(0xFF10B981)),
                  ],
                ),
            const SizedBox(height: 24),
            
                // Grup 2: Data & Bantuan
                _buildMenuGroup(
                  context: context,
                  title: 'Data & Dukungan',
                  items: [
                    _buildMenuItem(context, Icons.cloud_download_outlined, 'Backup & Ekspor Data', const Color(0xFF8B5CF6)),
                    _buildMenuItem(context, Icons.help_outline, 'Pusat Bantuan', const Color(0xFF3B82F6)),
                    _buildMenuItem(context, Icons.description_outlined, 'Syarat & Ketentuan', const Color(0xFF6B7280)),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Logout & Version
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Tindakan Keluar
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.logout, color: Color(0xFFEF4444)),
                            SizedBox(width: 8),
                            Text('Keluar', style: TextStyle(color: Color(0xFFEF4444), fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Versi 1.0.0', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B429A),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B429A).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  image: themeProvider.profileImagePath != null
                      ? DecorationImage(
                          image: FileImage(File(themeProvider.profileImagePath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: themeProvider.profileImagePath == null
                    ? Center(
                        child: Text(
                          themeProvider.userName.isNotEmpty ? themeProvider.userName[0].toUpperCase() : 'A', 
                          style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)
                        ),
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E60FE),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _showEditProfileDialog,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(Provider.of<ThemeProvider>(context).userName, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(width: 8),
              Icon(Icons.edit, size: 18, color: Theme.of(context).primaryColor),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text('+62 812 3456 7890', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildMenuGroup({required BuildContext context, required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, Color iconColor) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (title == 'Keamanan & PIN') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PinLockScreen(
                isSettingPin: true,
                onPinVerified: (newPin) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('PIN Berhasil Disetel ke $newPin'), backgroundColor: Colors.green),
                  );
                },
              )),
            );
          } else if (title == 'Backup & Ekspor Data') {
            final csvData = Provider.of<TransactionProvider>(context, listen: false).exportToCSV();
            if (csvData.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Belum ada data untuk diekspor')));
              return;
            }
            
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.surface,
                title: Text('Data Berhasil Diekspor', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Data transaksi Anda telah dikonversi ke format CSV.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 100),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: SingleChildScrollView(child: Text(csvData, style: const TextStyle(fontSize: 10, fontFamily: 'monospace'))),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
                  TextButton(
                    onPressed: () {
                      // Logic untuk share/save file bisa ditambahkan di sini
                      debugPrint(csvData);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data lengkap dicetak di konsol debug')));
                    }, 
                    child: const Text('Cetak di Konsol')
                  ),
                ],
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              const SizedBox(width: 16),
              Expanded(
                child: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
              ),
              const Icon(Icons.arrow_forward_ios, color: Color(0xFFD1D5DB), size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, ThemeProvider themeProvider) {
    final iconColor = const Color(0xFF6366F1);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Mode Gelap',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          Switch(
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) => themeProvider.toggleTheme(value),
            activeColor: const Color(0xFF1E60FE),
          ),
        ],
      ),
    );
  }
}
