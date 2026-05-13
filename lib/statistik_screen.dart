import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/transaction_model.dart';
import 'logic/transaction_provider.dart';
import 'logic/financial_provider.dart';
import 'logic/budget_provider.dart';
import 'transaction_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class StatistikScreen extends StatefulWidget {
  const StatistikScreen({super.key});

  @override
  State<StatistikScreen> createState() => _StatistikScreenState();
}

class _StatistikScreenState extends State<StatistikScreen> {
  DateTime _selectedDate = DateTime.now();

  void _previousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    });
  }

  void _nextMonth() {
    if (_selectedDate.year >= DateTime.now().year && _selectedDate.month >= DateTime.now().month) {
      return;
    }
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final financialProvider = Provider.of<FinancialProvider>(context);
    
    final selectedMonth = _selectedDate.month;
    final selectedYear = _selectedDate.year;
    
    final monthlyIncome = transactionProvider.getMonthlyIncome(selectedMonth, selectedYear);
    final monthlyExpense = transactionProvider.getMonthlyExpense(selectedMonth, selectedYear);
    final cashFlow = monthlyIncome - monthlyExpense;
    final cashFlowPercent = monthlyIncome > 0 ? (cashFlow / monthlyIncome * 100).toStringAsFixed(0) : '0';

    // Last month comparison logic
    final lastMonth = DateTime(selectedYear, selectedMonth - 1);
    final lastMonthExpense = transactionProvider.getMonthlyExpense(lastMonth.month, lastMonth.year);
    final expenseDiff = monthlyExpense - lastMonthExpense;
    final expenseChangePercent = lastMonthExpense > 0 ? (expenseDiff / lastMonthExpense * 100) : 0.0;
    
    // Top Expenses Logic
    final monthlyTransactions = transactionProvider.getTransactionsByMonth(selectedMonth, selectedYear)
        .where((t) => t.type == TransactionType.expense)
        .toList();
    final Map<String, double> categoryMap = {};
    for (var t in monthlyTransactions) {
      categoryMap[t.category.name] = (categoryMap[t.category.name] ?? 0) + t.amount;
    }
    final sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = sortedCategories.take(3).toList();
    
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final now = DateTime.now();

    // Daily Allowance Logic
    final daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;
    final currentDay = now.month == selectedMonth && now.year == selectedYear ? now.day : 1;
    final remainingDays = (daysInMonth - currentDay) + 1;
    final dailyAllowance = transactionProvider.currentBalance > 0 ? transactionProvider.currentBalance / remainingDays : 0.0;

    // Remaining Budget Logic
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final activeBudgets = budgetProvider.budgets.where((b) => b.month == selectedMonth && b.year == selectedYear).toList();
    final totalBudgetLimit = activeBudgets.fold(0.0, (sum, b) => sum + b.limitAmount);
    final totalBudgetSpending = activeBudgets.fold(0.0, (sum, b) {
      final spending = transactionProvider.getCategorySpending(b.categoryName, selectedMonth, selectedYear);
      return sum + spending;
    });
    final remainingBudget = totalBudgetLimit - totalBudgetSpending;

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
                  Text(currencyFormatter.format(transactionProvider.currentBalance), style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: const Color(0xFF1E60FE))),
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
                    subtitle: lastMonthExpense > 0 
                        ? '${expenseChangePercent.abs().toStringAsFixed(1)}% ${expenseChangePercent > 0 ? 'lebih boros' : 'lebih hemat'} dari bulan lalu'
                        : 'Bulan pertama pencatatan',
                    subtitleColor: expenseChangePercent > 0 ? Colors.red : Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TransactionDetailScreen(type: TransactionType.expense, title: 'Pengeluaran Bulan Ini')),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Top Expenses Section
                  if (topCategories.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Kategori Terboros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface)),
                        Text('Top 3', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...topCategories.map((entry) {
                      final cat = AppCategories.expenseCategories.firstWhere((c) => c.name == entry.key, orElse: () => AppCategories.expenseCategories.last);
                      final percentage = monthlyExpense > 0 ? (entry.value / monthlyExpense) * 100 : 0.0;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: cat.color.withOpacity(0.1), shape: BoxShape.circle),
                              child: Icon(cat.icon, color: cat.color, size: 16),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text('${percentage.toStringAsFixed(0)}% dari total belanja', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Text(currencyFormatter.format(entry.value), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                  ],
                  
                  // Allowance & Budget Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildSmallBalanceCard(
                          context: context, 
                          icon: Icons.timer_outlined, 
                          iconColor: const Color(0xFF1E60FE), 
                          iconBgColor: const Color(0xFFE8F0FF), 
                          title: 'Jatah Harian', 
                          amount: currencyFormatter.format(dailyAllowance),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSmallBalanceCard(
                          context: context, 
                          icon: Icons.pie_chart_outline, 
                          iconColor: remainingBudget < 0 ? const Color(0xFFFF5252) : const Color(0xFF00C853), 
                          iconBgColor: remainingBudget < 0 ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9), 
                          title: 'Sisa Budget', 
                          amount: currencyFormatter.format(remainingBudget),
                        ),
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
    final month = _selectedDate.month;
    final year = _selectedDate.year;

    return Consumer2<BudgetProvider, TransactionProvider>(
      builder: (context, budgetProvider, transProvider, child) {
        final activeBudgets = budgetProvider.budgets.where((b) => b.month == month && b.year == year).toList();
        
        if (activeBudgets.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status Budget', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 16),
            ...activeBudgets.map((budget) {
              final cat = AppCategories.expenseCategories.firstWhere((c) => c.name == budget.categoryName, orElse: () => AppCategories.expenseCategories.last);
              final catSpending = transProvider.transactions
                  .where((t) => t.type == TransactionType.expense && t.category.name == budget.categoryName && t.date.month == month && t.date.year == year)
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
    final count = provider.getTransactionsByMonth(_selectedDate.month, _selectedDate.year).length;
    final monthName = DateFormat('MMMM yyyy').format(_selectedDate);
    final isLatest = _selectedDate.year >= DateTime.now().year && _selectedDate.month >= DateTime.now().month;

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
          IconButton(
            icon: Icon(Icons.chevron_left, color: Theme.of(context).colorScheme.onSurface),
            onPressed: _previousMonth,
          ),
          Column(
            children: [
              Text(monthName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 2),
              Text('$count transaksi', style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
            ],
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: isLatest ? Colors.grey.shade300 : const Color(0xFF1E60FE)),
            onPressed: isLatest ? null : _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({required BuildContext context, required IconData icon, required Color iconColor, required Color iconBgColor, required String title, required String amount, String? subtitle, Color? subtitleColor, VoidCallback? onTap}) {
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.w500)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(color: subtitleColor ?? Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ],
              ),
            ),
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
        final daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
        final currencyFormatter = NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp');
        
        final Map<int, double> dailySpending = {};
        double maxSpending = 100000;
        for (var t in provider.transactions) {
          if (t.date.month == _selectedDate.month && t.date.year == _selectedDate.year && t.type == TransactionType.expense) {
            dailySpending[t.date.day] = (dailySpending[t.date.day] ?? 0) + t.amount;
            if ((dailySpending[t.date.day] ?? 0) > maxSpending) maxSpending = dailySpending[t.date.day]!;
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tren Pengeluaran Harian', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                  Icon(Icons.trending_up, color: Colors.blue.shade300, size: 20),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 7, 
                          getTitlesWidget: (value, meta) {
                            if (value < 1 || value > daysInMonth) return const SizedBox.shrink();
                            return Text('${value.toInt()}', style: TextStyle(color: Colors.grey.shade500, fontSize: 10));
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: maxSpending / 3,
                          reservedSize: 45,
                          getTitlesWidget: (value, meta) {
                            return Text(currencyFormatter.format(value), style: TextStyle(color: Colors.grey.shade500, fontSize: 10));
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (spot) => const Color(0xFF1E60FE),
                        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                          return touchedBarSpots.map((barSpot) {
                            final flSpot = barSpot;
                            return LineTooltipItem(
                              'Tgl ${flSpot.x.toInt()}\n',
                              const TextStyle(color: Colors.white70, fontSize: 10),
                              children: [
                                TextSpan(
                                  text: NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(flSpot.y),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(daysInMonth, (index) {
                          final day = index + 1;
                          return FlSpot(day.toDouble(), dailySpending[day] ?? 0);
                        }),
                        isCurved: true,
                        gradient: const LinearGradient(colors: [Color(0xFF1E60FE), Color(0xFF00D2FF)]),
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true, 
                          gradient: LinearGradient(
                            colors: [const Color(0xFF1E60FE).withOpacity(0.2), const Color(0xFF1E60FE).withOpacity(0.0)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpensePieChart(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final monthlyTransactions = provider.getTransactionsByMonth(_selectedDate.month, _selectedDate.year)
            .where((t) => t.type == TransactionType.expense)
            .toList();
        
        final Map<String, double> categoryData = {};
        for (var t in monthlyTransactions) {
          categoryData[t.category.name] = (categoryData[t.category.name] ?? 0) + t.amount;
        }

        final totalExpense = categoryData.values.fold(0.0, (sum, val) => sum + val);
        final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

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
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 65,
                        sections: categoryData.entries.map((entry) {
                          final cat = AppCategories.expenseCategories.firstWhere((c) => c.name == entry.key, orElse: () => AppCategories.expenseCategories.last);
                          final percentage = totalExpense > 0 ? (entry.value / totalExpense) * 100 : 0.0;
                          return PieChartSectionData(
                            color: cat.color,
                            value: entry.value,
                            title: percentage >= 8 ? '${percentage.toStringAsFixed(0)}%' : '',
                            radius: 35,
                            titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                            showTitle: true,
                          );
                        }).toList(),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text(
                          NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp').format(totalExpense),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 10,
                children: categoryData.entries.map((entry) {
                  final cat = AppCategories.expenseCategories.firstWhere((c) => c.name == entry.key, orElse: () => AppCategories.expenseCategories.last);
                  return _buildLegendItem(context, cat.color, entry.key, currencyFormatter.format(entry.value));
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label, String amount) {
    return Container(
      width: (MediaQuery.of(context).size.width - 80) / 2,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, overflow: TextOverflow.ellipsis)),
                Text(amount, style: const TextStyle(fontSize: 9, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialPlanner(BuildContext context, FinancialProvider financialProvider, double income, double expense) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final expenseRatio = income > 0 ? (expense / income) : 0.0;
    final savingCapacity = income > 0 ? ((income - expense) / income) : 0.0;

    // Budget Usage calculation
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final selectedMonth = _selectedDate.month;
    final selectedYear = _selectedDate.year;
    final activeBudgets = budgetProvider.budgets.where((b) => b.month == selectedMonth && b.year == selectedYear).toList();
    final totalLimit = activeBudgets.fold(0.0, (sum, b) => sum + b.limitAmount);
    final totalSpending = activeBudgets.fold(0.0, (sum, b) {
      final transProvider = Provider.of<TransactionProvider>(context, listen: false);
      return sum + transProvider.getCategorySpending(b.categoryName, selectedMonth, selectedYear);
    });
    final budgetUsage = totalLimit > 0 ? (totalSpending / totalLimit) : 0.0;
    
    int healthScore = 50;
    if (income > 0) {
      if (expenseRatio < 0.5) healthScore += 25;
      else if (expenseRatio < 0.7) healthScore += 15;
      
      if (savingCapacity > 0.2) healthScore += 25;
      else if (savingCapacity > 0.1) healthScore += 15;
    } else if (expense == 0) {
      healthScore = 100; // No activity yet
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
              Expanded(child: _buildMetricCard(context: context, title: 'Saving\nCapacity', value: '${(savingCapacity * 100).toStringAsFixed(0)}%', target: '> 20%', isGood: savingCapacity > 0.2, icon: savingCapacity > 0.2 ? Icons.arrow_outward : Icons.south_east)),
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
              Expanded(child: _buildMetricCard(context: context, title: 'Budget\nUsage', value: '${(budgetUsage * 100).toStringAsFixed(0)}%', target: '< 100%', isGood: budgetUsage <= 1.0, icon: budgetUsage <= 1.0 ? Icons.check_circle_outline : Icons.warning_amber_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard(context: context, title: 'Cash Flow\nStatus', value: income >= expense ? 'Surplus' : 'Defisit', target: 'Surplus', isGood: income >= expense, icon: income >= expense ? Icons.trending_up : Icons.trending_down)),
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
