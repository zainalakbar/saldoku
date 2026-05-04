import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/transaction_model.dart';
import 'logic/transaction_provider.dart';
import 'transaction_detail_screen.dart';
import 'package:intl/intl.dart';

class StatistikScreen extends StatelessWidget {
  const StatistikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final now = DateTime.now();
    final monthlyIncome = provider.getMonthlyIncome(now.month, now.year);
    final monthlyExpense = provider.getMonthlyExpense(now.month, now.year);
    final cashFlow = monthlyIncome - monthlyExpense;
    final cashFlowPercent = monthlyIncome > 0 ? (cashFlow / monthlyIncome * 100).toStringAsFixed(0) : '0';
    
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Stack(
        children: [
          // Background Gradient Header
          Container(
            height: 300,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE2EDFF),
                  Color(0xFFF2F5FB),
                  Color(0xFFF2F5FB),
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text('Statistik', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0D1C44))),
                  const SizedBox(height: 4),
                  const Text('Analisis keuangan bulanan', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
                  const SizedBox(height: 32),
                  const Text('SALDO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF), letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  
                  // Simple Visualizer (Progress bar like)
                  if (monthlyIncome > 0 || monthlyExpense > 0)
                    _buildSimpleChart(monthlyIncome, monthlyExpense)
                  else
                    // Empty Chart State
                    Container(
                      height: 150,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Belum ada transaksi.', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
                          SizedBox(height: 4),
                          Text('Grafik akan muncul setelah ada transaksi.', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  
                  // Month Selector
                  _buildMonthSelector(provider),
                  const SizedBox(height: 24),
                  
                  // Summary Cards
                  _buildSummaryItem(
                    context: context,
                    icon: Icons.south_west, 
                    iconColor: const Color(0xFF1E60FE), 
                    iconBgColor: const Color(0xFFE8F0FF), 
                    title: 'Pendapatan bulan ini', 
                    amount: currencyFormatter.format(monthlyIncome),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TransactionDetailScreen(type: TransactionType.income, title: 'Pendapatan Bulan Ini')),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryItem(
                    context: context,
                    icon: Icons.north_east, 
                    iconColor: const Color(0xFFE53935), 
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
                  const SizedBox(height: 16),
                  
                  // Asset & Debt Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildSmallBalanceCard(icon: Icons.account_balance_wallet, iconColor: const Color(0xFF1E60FE), iconBgColor: const Color(0xFFE8F0FF), title: 'Total Aset', amount: currencyFormatter.format(provider.totalIncome)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSmallBalanceCard(icon: Icons.credit_card, iconColor: const Color(0xFF4A4A4A), iconBgColor: const Color(0xFFF0F0F0), title: 'Total Hutang', amount: currencyFormatter.format(provider.totalExpense)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Cash Flow Card
                  _buildCashFlowCard(currencyFormatter.format(cashFlow), cashFlowPercent),
                  const SizedBox(height: 32),
                  
                  // Financial Planner
                  _buildFinancialPlanner(monthlyIncome, monthlyExpense),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(TransactionProvider provider) {
    final now = DateTime.now();
    final count = provider.getTransactionsByMonth(now.month, now.year).length;
    final monthName = DateFormat('MMMM yyyy').format(now);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.chevron_left, color: Color(0xFF0D1C44)),
          Column(
            children: [
              Text(monthName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D1C44))),
              const SizedBox(height: 2),
              Text('$count transaksi', style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
            ],
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({required BuildContext context, required IconData icon, required Color iconColor, required Color iconBgColor, required String title, required String amount, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.w500))),
            Text(amount, style: const TextStyle(color: Color(0xFF0D1C44), fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9CA3AF), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallBalanceCard({required IconData icon, required Color iconColor, required Color iconBgColor, required String title, required String amount}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9CA3AF), size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(amount, style: const TextStyle(color: Color(0xFF0D1C44), fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildCashFlowCard(String amount, String percent) {
    final isPositive = !amount.startsWith('-');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.account_balance_wallet, color: Colors.green.shade600, size: 20),
              ),
              const Text('Cash Flow Bulan Ini', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          Text('${isPositive ? '+' : ''}$amount', style: const TextStyle(color: Color(0xFF0D1C44), fontWeight: FontWeight.w800, fontSize: 24)),
          const SizedBox(height: 4),
          Text('$percent% dari pemasukan tersisa', style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSimpleChart(double income, double expense) {
    final total = income + expense;
    final incomeWidth = total > 0 ? (income / total) : 0.5;
    
    return Container(
      height: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Distribusi Keuangan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0D1C44))),
              Text('Bulan Ini', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 20,
              child: Row(
                children: [
                  Expanded(flex: (incomeWidth * 100).toInt(), child: Container(color: const Color(0xFF1E60FE))),
                  Expanded(flex: ((1 - incomeWidth) * 100).toInt(), child: Container(color: const Color(0xFFFF5252))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildLegend(const Color(0xFF1E60FE), 'Pemasukan'),
              const SizedBox(width: 24),
              _buildLegend(const Color(0xFFFF5252), 'Pengeluaran'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
      ],
    );
  }

  Widget _buildFinancialPlanner(double income, double expense) {
    final expenseRatio = income > 0 ? (expense / income) : 0.0;
    final savingCapacity = income > 0 ? ((income - expense) / income) : 0.0;
    
    // Simple health score logic
    int healthScore = 50;
    if (income > 0) {
      if (expenseRatio < 0.5) healthScore += 25;
      else if (expenseRatio < 0.7) healthScore += 15;
      
      if (savingCapacity > 0.2) healthScore += 25;
      else if (savingCapacity > 0.1) healthScore += 15;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.auto_awesome, color: Colors.purple.shade400, size: 20),
                ),
                const SizedBox(width: 12),
                const Text('Financial Planner', style: TextStyle(color: Color(0xFF0D1C44), fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                const Text('👍', style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
          // Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTabItem(Icons.pie_chart, 'Overview', true),
                _buildTabItem(Icons.thumb_up_alt_outlined, 'Tips', false),
                _buildTabItem(Icons.rocket_launch_outlined, 'Roadmap', false),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Health Score Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F7FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade100, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Financial Health Score', style: TextStyle(color: Color(0xFF0D1C44), fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 8),
                        Text(
                          healthScore > 70 ? 'Bagus! Keuangan Anda dalam kondisi baik' : 'Ayo tingkatkan kapasitas menabung Anda!',
                          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      Text('$healthScore', style: const TextStyle(color: Color(0xFF1E60FE), fontWeight: FontWeight.w800, fontSize: 32)),
                      const Text('/ 100', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
                      const SizedBox(height: 8),
                      Container(
                        width: 50,
                        height: 6,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(3)),
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: (healthScore / 100) * 50,
                          height: 6,
                          decoration: BoxDecoration(color: const Color(0xFF1E60FE), borderRadius: BorderRadius.circular(3)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Metrics Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(child: _buildMetricCard(title: 'Debt Ratio', value: '0.00x', target: '< 0.5x', isGood: true, icon: Icons.arrow_outward)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard(title: 'Expense\nRatio', value: '${(expenseRatio * 100).toStringAsFixed(0)}%', target: '< 70%', isGood: expenseRatio < 0.7, icon: expenseRatio < 0.7 ? Icons.arrow_outward : Icons.south_east)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(child: _buildMetricCard(title: 'Saving\nCapacity', value: '${(savingCapacity * 100).toStringAsFixed(0)}%', target: '> 20%', isGood: savingCapacity > 0.2, icon: savingCapacity > 0.2 ? Icons.arrow_outward : Icons.south_east)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard(title: 'Asset\nCoverage', value: 'No Debt', target: '> 1.5x', isGood: true, icon: Icons.arrow_outward)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Penjelasan Metrik Keuangan
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.lightbulb_outline, color: Color(0xFF1E60FE), size: 18),
                    SizedBox(width: 8),
                    Text('Penjelasan Metrik Keuangan', style: TextStyle(color: Color(0xFF0D1C44), fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildExplanationCard(
                  title: 'Debt Ratio',
                  description: 'Perbandingan total hutang dengan total aset. Semakin rendah semakin baik. Target ideal < 0.5x artinya hutang tidak boleh lebih dari setengah total aset Anda.',
                  iconBgColor: Colors.orange.shade50,
                  icon: Icons.pie_chart,
                  iconColor: Colors.orange.shade400,
                ),
                _buildExplanationCard(
                  title: 'Expense Ratio',
                  description: 'Persentase pengeluaran dari total pendapatan bulanan. Target ideal < 70% artinya maksimal 70% pendapatan untuk pengeluaran, sisanya untuk tabungan.',
                  iconBgColor: Colors.green.shade50,
                  icon: Icons.receipt_long,
                  iconColor: Colors.green.shade400,
                ),
                _buildExplanationCard(
                  title: 'Saving Capacity',
                  description: 'Kemampuan menabung dari pendapatan bulanan. Target ideal > 20% artinya minimal 20% pendapatan harus ditabung untuk masa depan.',
                  iconBgColor: Colors.blue.shade50,
                  icon: Icons.savings,
                  iconColor: Colors.blue.shade400,
                ),
                _buildExplanationCard(
                  title: 'Asset Coverage',
                  description: 'Perbandingan total aset dengan total hutang. Target ideal > 1.5x artinya aset harus 1.5 kali lipat dari hutang untuk keamanan finansial.',
                  iconBgColor: Colors.purple.shade50,
                  icon: Icons.shield,
                  iconColor: Colors.purple.shade400,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(IconData icon, String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: isActive
          ? BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            )
          : null,
      child: Column(
        children: [
          Icon(icon, color: isActive ? const Color(0xFF1E60FE) : const Color(0xFF9CA3AF), size: 20),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: isActive ? const Color(0xFF1E60FE) : const Color(0xFF9CA3AF), fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.w500)),
          if (isActive) ...[
            const SizedBox(height: 4),
            Container(width: 20, height: 2, decoration: BoxDecoration(color: const Color(0xFF1E60FE), borderRadius: BorderRadius.circular(1))),
          ]
        ],
      ),
    );
  }

  Widget _buildMetricCard({required String title, required String value, required String target, required bool isGood, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(color: Color(0xFF4A4A4A), fontWeight: FontWeight.w600, fontSize: 13, height: 1.2)),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isGood ? Colors.green.shade50 : Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: isGood ? Colors.green.shade600 : Colors.red.shade600, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(color: isGood ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 4),
          Text('Target: $target', style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildExplanationCard({required String title, required String description, required Color iconBgColor, required IconData icon, required Color iconColor}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Color(0xFF0D1C44), fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          Text(description, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }
}
