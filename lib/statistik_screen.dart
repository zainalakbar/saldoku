import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/transaction_model.dart';
import 'logic/transaction_provider.dart';
import 'logic/financial_provider.dart';
import 'logic/budget_provider.dart';
import 'transaction_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
    final monthName = DateFormat('MMMM').format(_selectedDate);
    
    final monthlyIncome = transactionProvider.getMonthlyIncome(selectedMonth, selectedYear);
    final monthlyExpense = transactionProvider.getMonthlyExpense(selectedMonth, selectedYear);

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

    // Daily Allowance Logic (Removed)
    
    // Remaining Budget Logic
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final activeBudgets = budgetProvider.budgets.where((b) => b.month == selectedMonth && b.year == selectedYear).toList();
    final totalBudgetLimit = activeBudgets.fold(0.0, (sum, b) => sum + b.limitAmount);
    final totalBudgetSpending = activeBudgets.fold(0.0, (sum, b) {
      final spending = transactionProvider.getCategorySpending(b.categoryName, selectedMonth, selectedYear);
      return sum + spending;
    });
    final remainingBudget = totalBudgetLimit - totalBudgetSpending;

    // Average Spending Logic (Last 3 months)
    double totalLastMonthsExpense = 0;
    int monthsCount = 0;
    for (int i = 1; i <= 3; i++) {
      final prevMonth = DateTime(selectedYear, selectedMonth - i);
      final exp = transactionProvider.getMonthlyExpense(prevMonth.month, prevMonth.year);
      if (exp > 0) {
        totalLastMonthsExpense += exp;
        monthsCount++;
      }
    }
    final avgMonthlyExpense = monthsCount > 0 ? totalLastMonthsExpense / monthsCount : monthlyExpense;


    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Weekly Comparison Logic (Last 7 days vs Previous 7 days)
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1)); // Monday
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    
    final thisWeekTransactions = transactionProvider.transactions.where((t) => 
      t.type == TransactionType.expense && 
      t.date.isAfter(thisWeekStart.subtract(const Duration(seconds: 1))) &&
      t.date.isBefore(now.add(const Duration(seconds: 1)))
    ).toList();
    
    final lastWeekTransactions = transactionProvider.transactions.where((t) => 
      t.type == TransactionType.expense && 
      t.date.isAfter(lastWeekStart.subtract(const Duration(seconds: 1))) &&
      t.date.isBefore(thisWeekStart)
    ).toList();
    
    final thisWeekTotal = thisWeekTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final lastWeekTotal = lastWeekTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final weeklyDiff = thisWeekTotal - lastWeekTotal;
    final weeklyChangePercent = lastWeekTotal > 0 ? (weeklyDiff / lastWeekTotal * 100) : 0.0;

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Statistik', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                          const SizedBox(height: 4),
                          Text('Analisis keuangan bulan ini', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFF1E60FE), size: 28),
                        onPressed: () => _exportToPdf(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Month Selector
                  _buildMonthSelector(context, transactionProvider),
                  const SizedBox(height: 24),
                  
                  if (monthlyIncome == 0 && monthlyExpense == 0)
                    _buildEmptyState(context, monthName, selectedYear.toString())
                  else ...[
                    // Income & Expense Summary Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            context: context,
                            title: 'Pemasukan',
                            amount: currencyFormatter.format(monthlyIncome),
                            icon: Icons.arrow_downward,
                            color: const Color(0xFF1E60FE),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => TransactionDetailScreen(
                                  type: TransactionType.income, 
                                  title: 'Pemasukan $monthName',
                                  month: selectedMonth,
                                  year: selectedYear,
                                )),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            context: context,
                            title: 'Pengeluaran',
                            amount: currencyFormatter.format(monthlyExpense),
                            icon: Icons.arrow_upward,
                            color: const Color(0xFFE53935),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => TransactionDetailScreen(
                                  type: TransactionType.expense, 
                                  title: 'Pengeluaran $monthName',
                                  month: selectedMonth,
                                  year: selectedYear,
                                )),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

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
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => TransactionDetailScreen(
                                type: TransactionType.expense, 
                                title: entry.key,
                                categoryName: entry.key,
                                month: selectedMonth,
                                year: selectedYear,
                              )),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                                BoxShadow(
                                  color: const Color(0xFF1E60FE).withOpacity(0.15),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
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
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 16),
                    ],
                    
                    const SizedBox(height: 8),
                    
                    const SizedBox(height: 24),
                    
                    // Weekly Analysis Section
                    _buildWeeklyComparison(context, thisWeekTotal, lastWeekTotal, weeklyDiff, weeklyChangePercent),
                    const SizedBox(height: 24),
                    
                    // Budget Status Section
                    _buildBudgetStatus(context),
                    const SizedBox(height: 32),
                    
                    // Financial Insights
                    _buildFinancialPlanner(context, financialProvider, monthlyIncome, monthlyExpense, avgMonthlyExpense),
                    const SizedBox(height: 32),

                    _buildTrendChart(context),
                    const SizedBox(height: 40),

                    // Category Distribution
                    _buildExpensePieChart(context),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String monthName, String yearName) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF1E60FE).withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E60FE).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.query_stats_rounded,
              size: 64,
              color: Color(0xFF1E60FE),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum Ada Transaksi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Catat transaksi pemasukan atau pengeluaran pada bulan $monthName $yearName untuk melihat analisa statistik keuangan Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToPdf(BuildContext context) async {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final monthName = DateFormat('MMMM yyyy').format(_selectedDate);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sedang membuat laporan $monthName...')),
    );

    try {
      final transactions = transactionProvider.getTransactionsByMonth(_selectedDate.month, _selectedDate.year);
      
      if (transactions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada transaksi di bulan ini untuk dilaporkan.')),
        );
        return;
      }

      final doc = pw.Document();
      final income = transactionProvider.getMonthlyIncome(_selectedDate.month, _selectedDate.year);
      final expense = transactionProvider.getMonthlyExpense(_selectedDate.month, _selectedDate.year);

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Laporan Keuangan Saldoku', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text(monthName),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(
                    children: [
                      pw.Text('Total Pemasukan'),
                      pw.Text(currencyFormatter.format(income), style: pw.TextStyle(color: PdfColors.blue, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Total Pengeluaran'),
                      pw.Text(currencyFormatter.format(expense), style: pw.TextStyle(color: PdfColors.red, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Sisa Arus Kas'),
                      pw.Text(currencyFormatter.format(income - expense), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Text('Daftar Transaksi', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Tanggal', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Judul', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Kategori', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Tipe', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Jumlah', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  ...transactions.map((t) => pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(DateFormat('dd/MM/yy').format(t.date))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(t.title)),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(t.category.name)),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(t.type == TransactionType.income ? 'Masuk' : 'Keluar')),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(currencyFormatter.format(t.amount))),
                    ],
                  )),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Footer(
                margin: const pw.EdgeInsets.only(top: 20),
                trailing: pw.Text('Dibuat otomatis oleh Aplikasi Saldoku'),
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat PDF: $e')),
      );
    }
  }

  Widget _buildWeeklyComparison(BuildContext context, double current, double previous, double diff, double percent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSaving = diff <= 0;
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Analisa Mingguan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSaving 
                  ? Colors.green.withOpacity(0.35) 
                  : Colors.red.withOpacity(0.35), 
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (isSaving ? Colors.green : Colors.red).withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isSaving ? Colors.green : Colors.red).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSaving ? Icons.trending_down : Icons.trending_up,
                      color: isSaving ? Colors.green : Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSaving ? 'Lebih Hemat gess! ✨' : 'Wah, Lagi Boros 💸',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isSaving ? Colors.green : Colors.red),
                        ),
                        Text(
                          isSaving 
                            ? 'Kamu hemat ${currencyFormatter.format(diff.abs())} dari minggu lalu.'
                            : 'Kamu belanja ${currencyFormatter.format(diff)} lebih banyak.',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildWeeklyStat('Minggu Ini', currencyFormatter.format(current), isDark),
                  _buildWeeklyStat('Minggu Lalu', currencyFormatter.format(previous), isDark),
                  _buildWeeklyStat('Perubahan', '${isSaving ? '-' : '+'}${percent.abs().toStringAsFixed(0)}%', isDark, isBold: true, color: isSaving ? Colors.green : Colors.red),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyStat(String label, String value, bool isDark, {bool isBold = false, Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(
          value, 
          style: TextStyle(
            fontSize: 14, 
            fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
            color: color,
          )
        ),
      ],
    );
  }

  Widget _buildBudgetStatus(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final month = _selectedDate.month;
    final year = _selectedDate.year;

    return Consumer2<BudgetProvider, TransactionProvider>(
      builder: (context, budgetProvider, transProvider, child) {
        final activeBudgets = budgetProvider.budgets.where((b) => b.month == month && b.year == year).toList();
        
        if (activeBudgets.isEmpty) return const SizedBox.shrink();

        // Sort by usage percentage (descending) so critical budgets are at the top
        activeBudgets.sort((a, b) {
          final usageA = (transProvider.getCategorySpending(a.categoryName, month, year) / a.limitAmount);
          final usageB = (transProvider.getCategorySpending(b.categoryName, month, year) / b.limitAmount);
          return usageB.compareTo(usageA);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Status Budget', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface)),
                Text('${activeBudgets.length} Kategori', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            ...activeBudgets.map((budget) {
              final cat = AppCategories.expenseCategories.firstWhere((c) => c.name == budget.categoryName, orElse: () => AppCategories.expenseCategories.last);
              final catSpending = transProvider.getCategorySpending(budget.categoryName, month, year);
              final remaining = budget.limitAmount - catSpending;
              final usage = budget.limitAmount > 0 ? catSpending / budget.limitAmount : 0.0;
              
              Color statusColor = const Color(0xFF1E60FE); // Default Blue
              if (usage >= 1.0) {
                statusColor = const Color(0xFFFF5252); // Critical Red
              } else if (usage >= 0.8) {
                statusColor = const Color(0xFFFF9800); // Warning Orange
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.45), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: cat.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: Icon(cat.icon, color: cat.color, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(budget.categoryName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(
                                usage >= 1.0 
                                  ? 'Over Budget! ⚠️' 
                                  : 'Sisa ${currencyFormatter.format(remaining)} lagi',
                                style: TextStyle(fontSize: 11, color: usage >= 1.0 ? Colors.red : Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Text('${(usage * 100).toStringAsFixed(0)}%', style: TextStyle(fontWeight: FontWeight.bold, color: statusColor)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: usage.clamp(0.0, 1.0),
                        backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        minHeight: 8,
                      ),
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
    final monthName = DateFormat('MMMM').format(_selectedDate);
    final yearName = DateFormat('yyyy').format(_selectedDate);
    final isLatest = _selectedDate.year >= DateTime.now().year && _selectedDate.month >= DateTime.now().month;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1E60FE).withOpacity(0.45), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E60FE).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMonthNavBtn(context, Icons.chevron_left, _previousMonth, true),
          Column(
            children: [
              Text(monthName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              Text(yearName, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
            ],
          ),
          _buildMonthNavBtn(context, Icons.chevron_right, isLatest ? null : _nextMonth, !isLatest),
        ],
      ),
    );
  }

  Widget _buildMonthNavBtn(BuildContext context, IconData icon, VoidCallback? onPressed, bool enabled) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFF1E60FE).withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        icon: Icon(icon, color: enabled ? const Color(0xFF1E60FE) : Colors.grey.shade300),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildSummaryCard({required BuildContext context, required String title, required String amount, required IconData icon, required Color color, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: const Color(0xFF1E60FE).withOpacity(0.15),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(amount, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
        final currencyFormatter = NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp');
        
        final Map<int, double> dailySpending = {};
        final Map<int, double> dailyIncome = {};
        double maxVal = 100000;
        
        for (var t in provider.transactions) {
          if (t.date.month == _selectedDate.month && t.date.year == _selectedDate.year) {
            if (t.type == TransactionType.expense) {
              dailySpending[t.date.day] = (dailySpending[t.date.day] ?? 0) + t.amount;
              if (dailySpending[t.date.day]! > maxVal) maxVal = dailySpending[t.date.day]!;
            } else {
              dailyIncome[t.date.day] = (dailyIncome[t.date.day] ?? 0) + t.amount;
              if (dailyIncome[t.date.day]! > maxVal) maxVal = dailyIncome[t.date.day]!;
            }
          }
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: const Color(0xFF1E60FE).withOpacity(0.15),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tren Keuangan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildChartLegend(Colors.blue, 'Masuk'),
                          const SizedBox(width: 12),
                          _buildChartLegend(Colors.red, 'Keluar'),
                        ],
                      ),
                    ],
                  ),
                  Icon(Icons.show_chart, color: Colors.blue.shade300, size: 24),
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
                      getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.05), strokeWidth: 1),
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
                            return Text('${value.toInt()}', style: TextStyle(color: Colors.grey.shade400, fontSize: 10));
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: maxVal / 3,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(currencyFormatter.format(value), style: TextStyle(color: Colors.grey.shade400, fontSize: 9));
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (spot) => const Color(0xFF1E1E2C).withOpacity(0.9),
                        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                          return touchedBarSpots.map((barSpot) {
                            return LineTooltipItem(
                              '${barSpot.barIndex == 0 ? "Pengeluaran" : "Pemasukan"}\n',
                              TextStyle(color: barSpot.barIndex == 0 ? Colors.red.shade300 : Colors.blue.shade300, fontSize: 10, fontWeight: FontWeight.bold),
                              children: [
                                TextSpan(
                                  text: NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(barSpot.y),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                    ),
                    lineBarsData: [
                      // Spending Line (Red)
                      LineChartBarData(
                        spots: List.generate(daysInMonth, (index) {
                          final day = index + 1;
                          return FlSpot(day.toDouble(), dailySpending[day] ?? 0);
                        }),
                        isCurved: true,
                        color: Colors.red.withOpacity(0.7),
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                      // Income Line (Blue)
                      LineChartBarData(
                        spots: List.generate(daysInMonth, (index) {
                          final day = index + 1;
                          return FlSpot(day.toDouble(), dailyIncome[day] ?? 0);
                        }),
                        isCurved: true,
                        color: Colors.blue.withOpacity(0.7),
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
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

  Widget _buildChartLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: const Color(0xFF1E60FE).withOpacity(0.15),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(child: Text('Belum ada data pengeluaran bulan ini', style: TextStyle(color: Colors.grey))),
          );
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: const Color(0xFF1E60FE).withOpacity(0.15),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
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
                  return _buildLegendItem(
                    context: context, 
                    color: cat.color, 
                    label: entry.key, 
                    amount: currencyFormatter.format(entry.value),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TransactionDetailScreen(
                          type: TransactionType.expense, 
                          title: entry.key,
                          categoryName: entry.key,
                          month: _selectedDate.month,
                          year: _selectedDate.year,
                        )),
                      );
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem({required BuildContext context, required Color color, required String label, required String amount, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }

  Widget _buildFinancialPlanner(BuildContext context, FinancialProvider financialProvider, double income, double expense, double avgExpense) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
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
        const SizedBox(height: 20),
        // Average Spending Insight Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF1E60FE).withOpacity(0.45), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E60FE).withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.analytics_outlined, color: Colors.blue.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Insight Pengeluaran', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text(
                        expense > avgExpense 
                          ? 'Pengeluaranmu bulan ini Rp ${currencyFormatter.format(expense - avgExpense)} lebih tinggi dari rata-rata.'
                          : 'Keren! Kamu berhasil menekan pengeluaran di bawah rata-rata biasanya.',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF1E60FE).withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
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
