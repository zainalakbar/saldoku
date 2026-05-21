import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../logic/transaction_model.dart';
import '../logic/transaction_provider.dart';
import '../logic/financial_provider.dart';
import '../logic/budget_provider.dart';
import '../logic/theme_provider.dart';
import '../logic/financial_models.dart';

import '../calculator_sheet.dart';
import '../split_bill_screen.dart';
import '../debt_management_screen.dart';
import '../transaction_detail_screen.dart';
import '../logic/navigation_provider.dart';
import 'monthly_report_screen.dart';
import 'recurring_transactions_screen.dart';

import '../widgets/dashboard/transaction_history.dart';
import '../widgets/dashboard/budget_section.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dark blue hero header
          _buildHeroHeader(context),
          const SizedBox(height: 24),
          _buildSmartInsights(context),
          const SizedBox(height: 24),
          _buildFeatures(context),
          const SizedBox(height: 24),
          _buildMonthlySummary(context),
          const SizedBox(height: 24),
          const BudgetSection(),
          const SizedBox(height: 24),
          _buildTransactionHistory(),
        ],
      ),
    );
  }

  // ─── HERO HEADER (dark banking style) ───────────────────────────────────
  Widget _buildHeroHeader(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final provider = Provider.of<TransactionProvider>(context);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final isPrivacy = themeProvider.isPrivacyMode;
    final userName = themeProvider.userName;
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'A';

    final hour = DateTime.now().hour;
    String greeting;
    if (hour >= 5 && hour < 11) greeting = 'Selamat Pagi ☀️';
    else if (hour >= 11 && hour < 15) greeting = 'Selamat Siang ☀️';
    else if (hour >= 15 && hour < 18) greeting = 'Selamat Sore 🌤️';
    else greeting = 'Selamat Malam 🌙';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A1628), Color(0xFF0D2248), Color(0xFF0A1A3A)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Avatar + name + bell
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF1E60FE),
                    backgroundImage: themeProvider.profileImagePath != null
                        ? FileImage(File(themeProvider.profileImagePath!))
                        : null,
                    child: themeProvider.profileImagePath == null
                        ? Text(initial, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      Text(userName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.notifications_none_outlined, color: Colors.white70, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Total balance label
              const Text('Total Saldo', style: TextStyle(color: Colors.white54, fontSize: 14, letterSpacing: 0.3)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      isPrivacy ? 'Rp ••••••' : currencyFormatter.format(provider.currentBalance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => themeProvider.setPrivacyMode(!isPrivacy),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isPrivacy ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        key: ValueKey(isPrivacy),
                        color: isPrivacy ? const Color(0xFF4F9EFF) : Colors.white38,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Pemasukan & Pengeluaran pills
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const TransactionDetailScreen(type: TransactionType.income, title: 'Riwayat Pemasukan'),
                      )),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00C853).withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_downward_rounded, color: Color(0xFF00C853), size: 16),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Pemasukan', style: TextStyle(color: Colors.white54, fontSize: 11)),
                                  Text(
                                    isPrivacy ? 'Rp ••••' : currencyFormatter.format(provider.totalIncome),
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const TransactionDetailScreen(type: TransactionType.expense, title: 'Riwayat Pengeluaran'),
                      )),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF5252).withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_upward_rounded, color: Color(0xFFFF5252), size: 16),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Pengeluaran', style: TextStyle(color: Colors.white54, fontSize: 11)),
                                  Text(
                                    isPrivacy ? 'Rp ••••' : currencyFormatter.format(provider.totalExpense),
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── QUICK ACTIONS row (like banking app: Calculator, Split, Hutang, Recurring) ───
  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.calculate_outlined, 'label': 'Kalkulator', 'color': const Color(0xFF1E60FE)},
      {'icon': Icons.group_outlined, 'label': 'Split Bill', 'color': const Color(0xFF10B981)},
      {'icon': Icons.account_balance_outlined, 'label': 'Hutang', 'color': const Color(0xFFF59E0B)},
      {'icon': Icons.autorenew, 'label': 'Rutin', 'color': const Color(0xFF8B5CF6)},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((a) {
          final color = a['color'] as Color;
          final icon = a['icon'] as IconData;
          final label = a['label'] as String;
          return GestureDetector(
            onTap: () {
              if (label == 'Kalkulator') showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const CalculatorSheet());
              else if (label == 'Split Bill') Navigator.push(context, MaterialPageRoute(builder: (_) => const SplitBillScreen()));
              else if (label == 'Hutang') Navigator.push(context, MaterialPageRoute(builder: (_) => const DebtManagementScreen()));
              else if (label == 'Rutin') Navigator.push(context, MaterialPageRoute(builder: (_) => const RecurringTransactionsScreen()));
            },
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(height: 8),
                Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Kept for backward compat (no longer called but methods must still exist)
  Widget _buildHeader(BuildContext context) => const SizedBox.shrink();
  Widget _buildBalanceCards(BuildContext context) => const SizedBox.shrink();

  Widget _buildQuickGoalCard(BuildContext context) {
    final financialProvider = Provider.of<FinancialProvider>(context);
    if (financialProvider.goals.isEmpty) return const SizedBox.shrink();
    
    final goal = financialProvider.goals.first;
    final progress = goal.targetAmount > 0 ? (goal.currentAmount / goal.targetAmount) : 0.0;
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFF4A00E0).withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Target Tabungan', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
              Text('${(progress * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Text(goal.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withOpacity(0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(currencyFormatter.format(goal.currentAmount), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              Text('Goal: ${currencyFormatter.format(goal.targetAmount)}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String amount,
    VoidCallback? onTap,
    bool isMain = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isMain ? 4 : 0),
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isMain ? 12 : 10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(isMain ? 16 : 12),
              ),
              child: Icon(icon, color: iconColor, size: isMain ? 24 : 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: isMain ? 13 : 11, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(amount, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: isMain ? 24 : 16, letterSpacing: -0.5)),
                ],
              ),
            ),
            if (onTap != null) Icon(Icons.arrow_forward_ios, color: Colors.grey.withOpacity(0.3), size: 14),
          ],
        ),
      ),
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

  void _showBudgetBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
        final now = DateTime.now();
        
        return Consumer2<BudgetProvider, TransactionProvider>(
          builder: (context, budgetProvider, transProvider, child) {
            final allCategories = AppCategories.expenseCategories;
            
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
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),
                  const Text('Budget Pengeluaran', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D1C44))),
                  const Text('Atur batas pengeluaran bulananmu', style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 24),
                  
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: allCategories.length,
                      itemBuilder: (context, index) {
                        final cat = allCategories[index];
                        final budget = budgetProvider.getBudgetForCategory(cat.name, now.month, now.year);
                        
                        final catSpending = transProvider.transactions
                            .where((t) => t.type == TransactionType.expense && t.category.name == cat.name && t.date.month == now.month && t.date.year == now.year)
                            .fold(0.0, (sum, t) => sum + t.amount);
                            
                        final usage = budget != null && budget.limitAmount > 0 ? catSpending / budget.limitAmount : 0.0;
                        final isOver = usage > 1.0;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: cat.color.withOpacity(0.1), shape: BoxShape.circle),
                                      child: Icon(cat.icon, color: cat.color, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D1C44))),
                                          Text(
                                            budget == null 
                                              ? 'Belum ada budget' 
                                              : '${(usage * 100).toStringAsFixed(0)}% terpakai (${currencyFormatter.format(catSpending)})',
                                            style: TextStyle(fontSize: 12, color: isOver ? Colors.red : Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => _showSetBudgetDialog(context, cat.name, budget?.limitAmount ?? 0),
                                      child: Text(budget == null ? 'Set' : 'Edit', style: const TextStyle(color: Color(0xFF1E60FE), fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                if (budget != null) ...[
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: usage.clamp(0.0, 1.0),
                                      backgroundColor: Colors.grey.shade100,
                                      valueColor: AlwaysStoppedAnimation<Color>(isOver ? Colors.red : (usage > 0.8 ? Colors.orange : cat.color)),
                                      minHeight: 6,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Limit: ${currencyFormatter.format(budget.limitAmount)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                      if (isOver)
                                        const Text('Over Budget!', style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSetBudgetDialog(BuildContext context, String categoryName, double currentLimit) {
    final controller = TextEditingController(text: currentLimit > 0 ? currentLimit.toStringAsFixed(0) : '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Budget $categoryName'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Limit Bulanan', prefixText: 'Rp '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final limit = double.tryParse(controller.text) ?? 0;
              if (limit >= 0) {
                final now = DateTime.now();
                Provider.of<BudgetProvider>(context, listen: false).setBudget(
                  CategoryBudget(categoryName: categoryName, limitAmount: limit, month: now.month, year: now.year)
                );
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

  Widget _buildSmartInsights(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final financialProvider = Provider.of<FinancialProvider>(context);
    final transProvider = Provider.of<TransactionProvider>(context);
    
    String message = "Keuanganmu hari ini terlihat stabil gess. Tetap konsisten ya!";
    IconData icon = Icons.auto_awesome;
    Color color1 = const Color(0xFF1E60FE);
    Color color2 = const Color(0xFF00D2FF);

    bool hasOverBudget = false;
    bool hasWarningBudget = false;
    String categoryName = "";

    for (var cat in AppCategories.expenseCategories) {
      final budget = budgetProvider.getBudgetForCategory(cat.name, DateTime.now().month, DateTime.now().year);
      if (budget != null) {
        final spending = transProvider.getCategorySpending(cat.name, DateTime.now().month, DateTime.now().year);
        final usage = spending / budget.limitAmount;
        if (usage >= 1.0) {
          hasOverBudget = true; categoryName = cat.name; break;
        } else if (usage >= 0.8) {
          hasWarningBudget = true; categoryName = cat.name;
        }
      }
    }

    final expense = transProvider.totalExpense;
    final income = transProvider.totalIncome;

    if (hasOverBudget) {
      message = "Waduh! Pengeluaran $categoryName kamu sudah jebol budget. Rem dulu gess! 🛑";
      icon = Icons.warning_amber_rounded;
      color1 = const Color(0xFFFF5252); color2 = const Color(0xFFFF8A80);
    } else if (expense > income && income > 0) {
      message = "Waduh gess, pengeluaranmu lebih besar dari pemasukan! Atur strategi ya. 💸";
      icon = Icons.trending_down;
      color1 = const Color(0xFFFF5252); color2 = const Color(0xFFFF8A80);
    } else if (hasWarningBudget) {
      message = "Waspada gess, pengeluaran $categoryName sudah mau habis limitnya. Hati-hati! ⚠️";
      icon = Icons.info_outline;
      color1 = Colors.orange; color2 = Colors.amber;
    } else if (financialProvider.goals.isNotEmpty && (financialProvider.goals.first.currentAmount / financialProvider.goals.first.targetAmount) >= 0.9) {
      message = "Dikit lagi! Tabungan '${financialProvider.goals.first.name}' kamu hampir finish. Semangat! 🎉";
      icon = Icons.emoji_events;
      color1 = Colors.amber; color2 = Colors.orange;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color1, color2]),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color1.withOpacity(0.2), color2.withOpacity(0.2)]),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color1, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SMART INSIGHTS',
                      style: TextStyle(color: color1, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w600, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatures(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Fitur Andalan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Wrap(
            spacing: 8,
            runSpacing: 16,
            alignment: WrapAlignment.start,
            children: [
              _buildFeatureIcon(
                context, Icons.calculate, 'Kalkulator', const Color(0xFF1E60FE), Colors.blue.shade50,
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
                context, Icons.receipt_long, 'Split Bill', const Color(0xFF607D8B), Colors.blueGrey.shade50,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SplitBillScreen()),
                  );
                },
              ),
              _buildFeatureIcon(
                context, Icons.account_balance_outlined, 'Hutang', const Color(0xFFF59E0B), Colors.orange.shade50,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DebtManagementScreen()),
                  );
                },
              ),
              _buildFeatureIcon(
                context, Icons.savings_outlined, 'Tabungan', const Color(0xFFE91E63), Colors.pink.shade50,
                onTap: () => _showTabunganBottomSheet(context),
              ),
              _buildFeatureIcon(
                context, Icons.pie_chart, 'Budgeting', const Color(0xFFFF9800), Colors.orange.shade50,
                onTap: () => _showBudgetBottomSheet(context),
              ),
              _buildFeatureIcon(
                context, Icons.bar_chart_rounded, 'Laporan', const Color(0xFF10B981), Colors.green.shade50,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MonthlyReportScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureIcon(BuildContext context, IconData icon, String label, Color color, Color bgColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Container(
              height: 58,
              width: 58,
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: color.withOpacity(0.22), width: 1.5),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
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
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkasan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 12),
          _buildSummaryItem(
            context: context,
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
            context: context,
            icon: Icons.money_off,
            iconColor: const Color(0xFFF59E0B),
            iconBgColor: const Color(0xFFFFF4E5),
            title: 'Total Hutang Saya',
            amount: currencyFormatter.format(Provider.of<FinancialProvider>(context).totalDebtAmount),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DebtManagementScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSummaryItem(
            context: context,
            icon: Icons.savings_outlined,
            iconColor: const Color(0xFF10B981),
            iconBgColor: const Color(0xFFE6F7F1),
            title: 'Total Piutang (Ke Saya)',
            amount: currencyFormatter.format(Provider.of<FinancialProvider>(context).totalPiutangAmount),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DebtManagementScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required BuildContext context,
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
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05)),
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
              child: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          Text(amount, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(width: 12),
          Icon(Icons.keyboard_arrow_down, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2), size: 20),
        ],
      ),
    ),
    );
  }



  Widget _buildTransactionHistory() {
    return const TransactionHistorySection();
  }
}
