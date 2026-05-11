import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../logic/transaction_model.dart';
import '../logic/transaction_provider.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final transProvider = Provider.of<TransactionProvider>(context);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    
    final income = transProvider.getMonthlyIncome(_selectedMonth.month, _selectedMonth.year);
    final expense = transProvider.getMonthlyExpense(_selectedMonth.month, _selectedMonth.year);
    
    // Calculate category distribution
    Map<String, double> categoryData = {};
    for (var cat in AppCategories.expenseCategories) {
      final spending = transProvider.getCategorySpending(cat.name, _selectedMonth.month, _selectedMonth.year);
      if (spending > 0) {
        categoryData[cat.name] = spending;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FB),
      appBar: AppBar(
        title: const Text('Laporan Bulanan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0D1C44),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _selectMonth(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selector Header
            Center(
              child: Text(
                DateFormat('MMMM yyyy', 'id_ID').format(_selectedMonth),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E60FE)),
              ),
            ),
            const SizedBox(height: 24),

            // Summary Card
            _buildSummaryCard(income, expense, currencyFormatter),
            const SizedBox(height: 32),

            // Chart Section
            if (categoryData.isNotEmpty) ...[
              const Text('Distribusi Pengeluaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 40,
                    sections: _buildChartSections(categoryData),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Category Breakdown List
            const Text('Rincian Kategori', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildCategoryList(categoryData, currencyFormatter),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double income, double expense, NumberFormat formatter) {
    final balance = income - expense;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E60FE), Color(0xFF4A89FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1E60FE).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Pemasukan', income, Colors.white.withOpacity(0.9), formatter),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
              _buildSummaryItem('Pengeluaran', expense, Colors.white.withOpacity(0.9), formatter),
            ],
          ),
          const Divider(height: 32, color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sisa Saldo Bulan Ini', style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text(
                formatter.format(balance),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color, NumberFormat formatter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 12)),
        const SizedBox(height: 4),
        Text(formatter.format(amount), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  List<PieChartSectionData> _buildChartSections(Map<String, double> data) {
    final total = data.values.fold(0.0, (sum, val) => sum + val);
    return data.entries.map((entry) {
      final cat = AppCategories.expenseCategories.firstWhere((c) => c.name == entry.key);
      return PieChartSectionData(
        color: cat.color,
        value: entry.value,
        title: '${(entry.value / total * 100).toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  Widget _buildCategoryList(Map<String, double> data, NumberFormat formatter) {
    if (data.isEmpty) {
      return const Center(child: Text('Belum ada data pengeluaran', style: TextStyle(color: Colors.grey)));
    }

    final sortedEntries = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedEntries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = sortedEntries[index];
        final cat = AppCategories.expenseCategories.firstWhere((c) => c.name == entry.key);
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: cat.color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(cat.icon, color: cat.color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('Total pengeluaran', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Text(formatter.format(entry.value), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D1C44))),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectMonth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      // Need a custom picker for month/year ideally, but for now standard is okay
    );
    if (picked != null) {
      setState(() => _selectedMonth = DateTime(picked.year, picked.month));
    }
  }
}
