import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/transaction_model.dart';
import 'logic/transaction_provider.dart';
import 'logic/financial_provider.dart';
import 'logic/budget_provider.dart';
import 'transaction_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class StatistikScreen extends StatelessWidget {
  const StatistikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final financialProvider = Provider.of<FinancialProvider>(context);
    
    final now = DateTime.now();
    final monthlyIncome = transactionProvider.getMonthlyIncome(now.month, now.year);
    final monthlyExpense = transactionProvider.getMonthlyExpense(now.month, now.year);
    final cashFlow = monthlyIncome - monthlyExpense;
    final cashFlowPercent = monthlyIncome > 0 ? (cashFlow / monthlyIncome * 100).toStringAsFixed(0) : '0';
    
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Stack(
        children: [
          // Background Gradient Header
          Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark 
                  ? [const Color(0xFF1E1E2C), const Color(0xFF0A0E21), const Color(0xFF0A0E21)]
                  : [const Color(0xFFE2EDFF), const Color(0xFFF2F5FB), const Color(0xFFF2F5FB)],
                stops: const [0.0, 0.6, 1.0],
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
                  Text('Statistik', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Text('Analisis keuangan bulanan', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                  const SizedBox(height: 32),
                  Text('SALDO', style: Theme.of(context).textTheme.bodySmall?.copyWith(letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(currencyFormatter.format(financialProvider.totalAssetAmount), style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: const Color(0xFF1E60FE))),
                  const SizedBox(height: 24),
                  
                  // Month Selector
                  _buildMonthSelector(context, transactionProvider),
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
                        child: _buildSmallBalanceCard(context: context, icon: Icons.account_balance_wallet, iconColor: const Color(0xFF1E60FE), iconBgColor: const Color(0xFFE8F0FF), title: 'Total Aset', amount: currencyFormatter.format(financialProvider.totalAssetAmount)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSmallBalanceCard(context: context, icon: Icons.credit_card, iconColor: const Color(0xFF4A4A4A), iconBgColor: const Color(0xFFF0F0F0), title: 'Total Hutang', amount: currencyFormatter.format(financialProvider.totalDebtAmount)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Cash Flow Card
                  _buildCashFlowCard(context, currencyFormatter.format(cashFlow), cashFlowPercent),
                  const SizedBox(height: 32),
                  
                  // Budget Status Section
                  _buildBudgetStatus(context),
                  const SizedBox(height: 32),
                  
                  // Financial Planner
                  _buildFinancialPlanner(context, financialProvider, monthlyIncome, monthlyExpense),
                  const SizedBox(height: 32),

                  // Trends
                  _buildTrendChart(context),
                  const SizedBox(height: 32),

                  // Category Distribution
                  _buildExpensePieChart(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetStatus(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final now = DateTime.now();

    return Consumer2<BudgetProvider, TransactionProvider>(
      builder: (context, budgetProvider, transProvider, child) {
        final activeBudgets = budgetProvider.budgets.where((b) => b.month == now.month && b.year == now.year).toList();
        
        if (activeBudgets.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status Budget', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 16),
            ...activeBudgets.map((budget) {
              final cat = AppCategories.expenseCategories.firstWhere((c) => c.name == budget.categoryName, orElse: () => AppCategories.expenseCategories.last);
              final catSpending = transProvider.transactions
                  .where((t) => t.type == TransactionType.expense && t.category.name == budget.categoryName && t.date.month == now.month && t.date.year == now.year)
                  .fold(0.0, (sum, t) => sum + t.amount);
              
              final usage = budget.limitAmount > 0 ? catSpending / budget.limitAmount : 0.0;
              final isOver = usage > 1.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(cat.icon, color: cat.color, size: 18),
                            const SizedBox(width: 8),
                            Text(budget.categoryName, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
                          ],
                        ),
                        Text(
                          '${(usage * 100).toStringAsFixed(0)}%',
                          style: TextStyle(fontWeight: FontWeight.bold, color: isOver ? Colors.red : (usage > 0.8 ? Colors.orange : Colors.green)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: usage.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey.shade100,
                        minHeight: 8,
                        valueColor: AlwaysStoppedAnimation<Color>(isOver ? Colors.red : (usage > 0.8 ? Colors.orange : cat.color)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(currencyFormatter.format(catSpending), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('Limit: ${currencyFormatter.format(budget.limitAmount)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildMonthSelector(BuildContext context, TransactionProvider provider) {
    final now = DateTime.now();
    final count = provider.getTransactionsByMonth(now.month, now.year).length;
    final monthName = DateFormat('MMMM yyyy').format(now);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.chevron_left, color: Theme.of(context).colorScheme.onSurface),
          Column(
            children: [
              Text(monthName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
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
          color: Theme.of(context).colorScheme.surface,
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
            Text(amount, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9CA3AF), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallBalanceCard({required BuildContext context, required IconData icon, required Color iconColor, required Color iconBgColor, required String title, required String amount}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
          Text(amount, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildCashFlowCard(BuildContext context, String amount, String percent) {
    final isPositive = !amount.startsWith('-');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
          Text('${isPositive ? '+' : ''}$amount', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w800, fontSize: 24)),
          const SizedBox(height: 4),
          Text('$percent% dari pemasukan tersisa', style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTrendChart(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final now = DateTime.now();
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        
        // Group spending by day
        final Map<int, double> dailySpending = {};
        for (var t in provider.transactions) {
          if (t.date.month == now.month && t.date.year == now.year && t.type == TransactionType.expense) {
            dailySpending[t.date.day] = (dailySpending[t.date.day] ?? 0) + t.amount;
          }
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tren Pengeluaran Harian', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 32),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(daysInMonth, (index) {
                          final day = index + 1;
                          return FlSpot(day.toDouble(), dailySpending[day] ?? 0);
                        }),
                        isCurved: true,
                        color: const Color(0xFF1E60FE),
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true, 
                          color: const Color(0xFF1E60FE).withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Center(child: Text('Tanggal dalam bulan ini', style: TextStyle(fontSize: 11, color: Colors.grey))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpensePieChart(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final now = DateTime.now();
        final monthlyTransactions = provider.getTransactionsByMonth(now.month, now.year)
            .where((t) => t.type == TransactionType.expense)
            .toList();
        
        final Map<String, double> categoryData = {};
        for (var t in monthlyTransactions) {
          categoryData[t.category.name] = (categoryData[t.category.name] ?? 0) + t.amount;
        }

        final totalExpense = categoryData.values.fold(0.0, (sum, val) => sum + val);

        if (categoryData.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: const Center(child: Text('Belum ada data pengeluaran bulan ini', style: TextStyle(color: Colors.grey))),
          );
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Distribusi Pengeluaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 32),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 50,
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        // Logic for tooltip or highlight
                      },
                    ),
                    sections: categoryData.entries.map((entry) {
                      final cat = AppCategories.expenseCategories.firstWhere((c) => c.name == entry.key, orElse: () => AppCategories.expenseCategories.last);
                      final percentage = (entry.value / totalExpense) * 100;
                      return PieChartSectionData(
                        color: cat.color,
                        value: entry.value,
                        title: percentage >= 10 ? '${percentage.toStringAsFixed(0)}%' : '',
                        radius: 50,
                        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        showTitle: true,
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: categoryData.keys.map((catName) {
                  final cat = AppCategories.expenseCategories.firstWhere((c) => c.name == catName, orElse: () => AppCategories.expenseCategories.last);
                  return _buildLegend(context, cat.color, catName);
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegend(BuildContext context, Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
      ],
    );
  }

  Widget _buildFinancialPlanner(BuildContext context, FinancialProvider financialProvider, double income, double expense) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final expenseRatio = income > 0 ? (expense / income) : 0.0;
    final savingCapacity = income > 0 ? ((income - expense) / income) : 0.0;
    
    int healthScore = 50;
    if (income > 0) {
      if (expenseRatio < 0.5) healthScore += 25;
      else if (expenseRatio < 0.7) healthScore += 15;
      
      if (savingCapacity > 0.2) healthScore += 25;
      else if (savingCapacity > 0.1) healthScore += 15;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text('Financial Insights', style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                  ? [const Color(0xFF1E3C72), const Color(0xFF2A5298)]
                  : [const Color(0xFF1E60FE), const Color(0xFF00D2FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E60FE).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              children: [
                const Text('Skor Kesehatan Finansial', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                Text('$healthScore', style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w900, letterSpacing: -2)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    healthScore >= 80 ? 'Sangat Sehat gess! 🚀' : healthScore >= 60 ? 'Cukup Sehat' : 'Perlu Waspada!',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
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
              Expanded(child: _buildMetricCard(context: context, title: 'Debt Ratio', value: financialProvider.totalAssetAmount > 0 ? (financialProvider.totalDebtAmount / financialProvider.totalAssetAmount).toStringAsFixed(2) + 'x' : '0.00x', target: '< 0.5x', isGood: financialProvider.totalAssetAmount > 0 ? (financialProvider.totalDebtAmount / financialProvider.totalAssetAmount) < 0.5 : true, icon: Icons.arrow_outward)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard(context: context, title: 'Expense\nRatio', value: '${(expenseRatio * 100).toStringAsFixed(0)}%', target: '< 70%', isGood: expenseRatio < 0.7, icon: expenseRatio < 0.7 ? Icons.arrow_outward : Icons.south_east)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Expanded(child: _buildMetricCard(context: context, title: 'Saving\nCapacity', value: '${(savingCapacity * 100).toStringAsFixed(0)}%', target: '> 20%', isGood: savingCapacity > 0.2, icon: savingCapacity > 0.2 ? Icons.arrow_outward : Icons.south_east)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard(context: context, title: 'Asset\nCoverage', value: financialProvider.totalDebtAmount > 0 ? (financialProvider.totalAssetAmount / financialProvider.totalDebtAmount).toStringAsFixed(1) + 'x' : 'No Debt', target: '> 1.5x', isGood: financialProvider.totalDebtAmount > 0 ? (financialProvider.totalAssetAmount / financialProvider.totalDebtAmount) > 1.5 : true, icon: Icons.arrow_outward)),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTabItem(BuildContext context, IconData icon, String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: isActive
          ? BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            )
          : null,
      child: Row(
        children: [
          Icon(icon, size: 16, color: isActive ? const Color(0xFF1E60FE) : Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? const Color(0xFF1E60FE) : Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildMetricCard({required BuildContext context, required String title, required String value, required String target, required bool isGood, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
              Icon(icon, size: 14, color: isGood ? Colors.green : Colors.red),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text('Target: $target', style: TextStyle(fontSize: 10, color: isGood ? Colors.green : Colors.red)),
        ],
      ),
    );
  }

  Widget _buildExplanationCard({required BuildContext context, required String title, required String description, required Color iconBgColor, required IconData icon, required Color iconColor}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
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
          Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          Text(description, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }
}
