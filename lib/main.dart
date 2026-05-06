import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'calculator_sheet.dart';
import 'statistik_screen.dart';
import 'split_bill_screen.dart';
import 'notes_screen.dart';
import 'akun_screen.dart';
import 'package:provider/provider.dart';
import 'logic/transaction_model.dart';
import 'logic/transaction_provider.dart';
import 'logic/financial_provider.dart';
import 'logic/financial_models.dart';
import 'add_transaction_sheet.dart';
import 'transaction_detail_screen.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => FinancialProvider()),
      ],
      child: MaterialApp(
        title: 'Saldoku',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E60FE)),
          useMaterial3: true,
          fontFamily: 'Inter',
          scaffoldBackgroundColor: const Color(0xFFF2F5FB),
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const NotesScreen(), // Notes
    const Center(child: Text('')), // Placeholder for FAB space
    const StatistikScreen(), // Statistik
    const AkunScreen(), // Akun
  ];

  void _onItemTapped(int index) {
    if (index == 2) return; // Ignore the empty space for FAB
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_selectedIndex],
          // Custom Bottom Nav
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.home_filled, 'Home', 0),
              _buildNavItem(Icons.note_alt_outlined, 'Notes', 1),
              const SizedBox(width: 40), // Space for FAB
              _buildNavItem(Icons.pie_chart_outline, 'Statistik', 3),
              _buildNavItem(Icons.person_outline, 'Akun', 4),
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AddTransactionSheet(),
              );
            },
            child: Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF1E60FE),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E60FE).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? const Color(0xFF1E60FE) : const Color(0xFF9CA3AF), size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? const Color(0xFF1E60FE) : const Color(0xFF9CA3AF),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Stack(
        children: [
                // Background Gradient Header (Now scrolls with content)
                Container(
                  height: 400,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF8BBEFF),
                        Color(0xFFE2EDFF),
                        Color(0xFFF2F5FB),
                      ],
                      stops: [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildBalanceCards(context),
                      const SizedBox(height: 24),
                      _buildFeatures(context),
                      const SizedBox(height: 24),
                      _buildMonthlySummary(context),
                      const SizedBox(height: 24),
                      _buildNotesSection(),
                      const SizedBox(height: 24),
                      _buildTransactionHistory(),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFF8B429A),
            child: Text('A', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selamat Siang ☀️', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 13, fontWeight: FontWeight.w500)),
              Text('Akbar Gg', style: TextStyle(color: Color(0xFF0D1C44), fontSize: 18, fontWeight: FontWeight.w800)),
            ],
          ),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mail_outline, color: Color(0xFF0D1C44), size: 22),
              ),
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53935),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCards(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          children: [
            _buildBalanceItem(
              icon: Icons.account_balance_wallet,
              iconColor: const Color(0xFF1E60FE),
              iconBgColor: const Color(0xFFE8F0FF),
              title: 'Total Aset',
              amount: currencyFormatter.format(Provider.of<FinancialProvider>(context).totalAssetAmount),
              onTap: () => _showAsetBottomSheet(context),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildBalanceItem(
                    icon: Icons.south_west,
                    iconColor: const Color(0xFF1E60FE),
                    iconBgColor: const Color(0xFFE8F0FF),
                    title: 'Pemasukan',
                    amount: currencyFormatter.format(provider.totalIncome),
                    onTap: null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildBalanceItem(
                    icon: Icons.north_east,
                    iconColor: const Color(0xFFFF5252),
                    iconBgColor: const Color(0xFFFFEBEE),
                    title: 'Pengeluaran',
                    amount: currencyFormatter.format(provider.totalExpense),
                    onTap: null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String amount,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(amount, style: const TextStyle(color: Color(0xFF0D1C44), fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
            if (onTap != null) const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  void _showAsetBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
        
        return Consumer<FinancialProvider>(
          builder: (context, provider, child) {
            return Container(
              padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Aset', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D1C44))),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 18, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Blue Gradient Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E60FE), Color(0xFF548CFF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(currencyFormatter.format(provider.totalAssetAmount), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _showAsetBaruBottomSheet(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                            child: const Row(
                              children: [
                                Icon(Icons.add_circle_outline, color: Color(0xFF1E60FE), size: 16),
                                SizedBox(width: 4),
                                Text('Aset', style: TextStyle(color: Color(0xFF1E60FE), fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (provider.assets.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text('Belum ada aset.', style: TextStyle(color: Colors.grey))),
                    )
                  else
                    ...provider.assets.map((asset) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: asset.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                              child: Icon(asset.icon, color: asset.color, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(asset.name, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 4),
                                  Text(currencyFormatter.format(asset.amount), style: const TextStyle(color: Color(0xFF0D1C44), fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              onPressed: () => provider.deleteAsset(asset.id),
                            ),
                          ],
                        ),
                      ),
                    )).toList(),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAsetBaruBottomSheet(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 40),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 20),
                const Text('Aset Baru', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D1C44))),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Aset (Misal: Tabungan BCA)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Nominal Saldo',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final name = nameController.text;
                      final amount = double.tryParse(amountController.text) ?? 0;
                      if (name.isNotEmpty && amount > 0) {
                        final asset = FinancialAsset(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: name,
                          amount: amount,
                          type: AssetType.cash,
                          icon: Icons.account_balance_wallet,
                          color: const Color(0xFF1E60FE),
                        );
                        Provider.of<FinancialProvider>(context, listen: false).addAsset(asset);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E60FE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Simpan Aset', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTabunganBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
        
        return Consumer<FinancialProvider>(
          builder: (context, provider, child) {
            return Container(
              padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Target Tabungan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D1C44))),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 18, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Dark Gradient Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2C2C2C), Color(0xFF5A5A5A)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(currencyFormatter.format(provider.totalGoalAmount), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _showTabunganBaruBottomSheet(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                            child: const Row(
                              children: [
                                Icon(Icons.add_circle_outline, color: Color(0xFF1E60FE), size: 16),
                                SizedBox(width: 4),
                                Text('Target', style: TextStyle(color: Color(0xFF1E60FE), fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (provider.goals.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Belum ada target tabungan.')))
                  else
                    ...provider.goals.map((goal) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: goal.color.withOpacity(0.1), shape: BoxShape.circle),
                                  child: Icon(goal.icon, color: goal.color, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(goal.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D1C44))),
                                      Text('${(goal.progress * 100).toStringAsFixed(0)}% terkumpul (${currencyFormatter.format(goal.currentAmount)})', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(currencyFormatter.format(goal.targetAmount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () {
                                        _showIsiTabunganDialog(context, goal);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(color: const Color(0xFFE8F0FF), borderRadius: BorderRadius.circular(12)),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.add, color: Color(0xFF1E60FE), size: 14),
                                            Text(' Isi', style: TextStyle(color: Color(0xFF1E60FE), fontSize: 11, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: goal.progress,
                                backgroundColor: Colors.grey.shade100,
                                valueColor: AlwaysStoppedAnimation<Color>(goal.color),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )).toList(),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showTabunganBaruBottomSheet(BuildContext context) {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 40),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                const Text('Target Tabungan Baru', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D1C44))),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Target (Misal: Liburan ke Jepang)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Target Nominal',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final name = nameController.text;
                      final target = double.tryParse(targetController.text) ?? 0;
                      if (name.isNotEmpty && target > 0) {
                        final goal = FinancialGoal(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: name,
                          targetAmount: target,
                          currentAmount: 0,
                          icon: Icons.savings,
                          color: const Color(0xFFFF9800),
                        );
                        Provider.of<FinancialProvider>(context, listen: false).addGoal(goal);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E60FE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Buat Target', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showIsiTabunganDialog(BuildContext context, FinancialGoal goal) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Isi ${goal.name}'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Nominal Tabungan',
            prefixText: 'Rp ',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                Provider.of<FinancialProvider>(context, listen: false).updateGoalAmount(goal.id, amount);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E60FE), foregroundColor: Colors.white),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text('Fitur Andalan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0D1C44))),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeatureIcon(
                Icons.calculate, 'Kalkulator', const Color(0xFF1E60FE), Colors.blue.shade50,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const CalculatorSheet(),
                  );
                },
              ),
              _buildFeatureIcon(
                Icons.receipt_long, 'Split Bill', const Color(0xFF607D8B), Colors.blueGrey.shade50,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SplitBillScreen()),
                  );
                },
              ),
              _buildFeatureIcon(
                Icons.savings, 'Tabungan', const Color(0xFF333333), Colors.grey.shade200,
                onTap: () => _showTabunganBottomSheet(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label, Color color, Color bgColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Color(0xFF4A4A4A), fontWeight: FontWeight.w500, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlySummary(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final now = DateTime.now();
    final monthlyIncome = provider.getMonthlyIncome(now.month, now.year);
    final monthlyExpense = provider.getMonthlyExpense(now.month, now.year);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          _buildSummaryItem(
            icon: Icons.south_west,
            iconColor: const Color(0xFF1E60FE),
            iconBgColor: const Color(0xFFE8F0FF),
            title: 'Pendapatan bulanan ini',
            amount: currencyFormatter.format(monthlyIncome),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TransactionDetailScreen(type: TransactionType.income, title: 'Pendapatan Bulan Ini')),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSummaryItem(
            icon: Icons.north_east,
            iconColor: const Color(0xFFFF5252),
            iconBgColor: const Color(0xFFFFEBEE),
            title: 'Pengeluaran bulan ini',
            amount: currencyFormatter.format(monthlyExpense),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TransactionDetailScreen(type: TransactionType.expense, title: 'Pengeluaran Bulan Ini')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String amount,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          Text(amount, style: const TextStyle(color: Color(0xFF0D1C44), fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(width: 12),
          const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9CA3AF), size: 20),
        ],
      ),
    ),);
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0D1C44))),
              Text('Lihat Semua', style: TextStyle(fontSize: 13, color: const Color(0xFF1E60FE), fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildNotesCard(),
              _buildNotesCard(),
            ],
          ),
        ),
        const SizedBox(height: 40), // extra padding for bottom scroll
      ],
    );
  }

  Widget _buildNotesCard() {
    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: Colors.blue.shade700, size: 20),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Sisa Saldo New...', style: TextStyle(color: Color(0xFF0D1C44), fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return const TransactionHistorySection();
  }

}

class TransactionHistorySection extends StatefulWidget {
  const TransactionHistorySection({super.key});

  @override
  State<TransactionHistorySection> createState() => _TransactionHistorySectionState();
}

class _TransactionHistorySectionState extends State<TransactionHistorySection> {
  bool _isAsetTab = false; // "Hutang" selected by default to show the feature requested

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Riwayat Transaksi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D1C44)),
        ),
        const SizedBox(height: 16),
        
        // Toggle (Aset / Hutang)
        Container(
          width: 220,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EEF8),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isAsetTab = true),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: _isAsetTab ? BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ) : null,
                    alignment: Alignment.center,
                    child: Text('Aset', style: TextStyle(fontWeight: _isAsetTab ? FontWeight.w600 : FontWeight.w500, color: _isAsetTab ? const Color(0xFF0D1C44) : const Color(0xFF6B7280), fontSize: 14)),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isAsetTab = false),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: !_isAsetTab ? BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ) : null,
                    alignment: Alignment.center,
                    child: Text('Hutang', style: TextStyle(fontWeight: !_isAsetTab ? FontWeight.w600 : FontWeight.w500, color: !_isAsetTab ? const Color(0xFF0D1C44) : const Color(0xFF6B7280), fontSize: 14)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Content
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isAsetTab ? _buildAsetContent() : _buildHutangContent(),
        ),
      ],
    );
  }

  Widget _buildAsetContent() {
    return Padding(
      key: const ValueKey('aset'),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header (Icon, 'y', 'Lihat Semua')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.handyman, color: Colors.blueGrey, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text('y', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D1C44))),
                  ],
                ),
                Text('Lihat Semua', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 40),
            
            // Illustration (Notepad/Pencil)
            Icon(Icons.edit_document, size: 80, color: Colors.orange.shade300),
            const SizedBox(height: 24),
            
            // Texts
            const Text('Belum ada transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A))),
            const SizedBox(height: 8),
            const Text('Mulai mencatat transaksi untuk y', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
            const SizedBox(height: 24),
            
            // Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E60FE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text('Catat Transaksi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildHutangContent() {
    return Padding(
      key: const ValueKey('hutang'),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: CustomPaint(
          painter: DashedRectPainter(
            color: Colors.grey.shade400,
            strokeWidth: 1.2,
            gap: 6.0,
            borderRadius: 16.0,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('📋', style: TextStyle(fontSize: 54)),
                const SizedBox(height: 24),
                const Text(
                  'Belum ada transaksi hutang',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D1C44)),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Mulai mencatat transaksi keuangan Anda\nuntuk melihat riwayat hutang',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.5),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E60FE),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Catat Transaksi Pertama', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double borderRadius;

  DashedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    var path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius)));

    Path dashPath = Path();
    double distance = 0.0;
    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
      distance = 0.0; // reset for next metric just in case
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
