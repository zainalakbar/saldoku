import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../logic/transaction_model.dart';
import '../../logic/transaction_provider.dart';
import '../../logic/budget_provider.dart';
import '../../logic/financial_models.dart';

class BudgetSection extends StatelessWidget {
  const BudgetSection({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final transProvider = Provider.of<TransactionProvider>(context);
    final now = DateTime.now();
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    final budgets = budgetProvider.budgets.where((b) => b.month == now.month && b.year == now.year).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pantau Budget',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Batas pengeluaran bulan ini',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => _showSetBudgetSheet(context),
                child: const Text('Atur Budget', style: TextStyle(color: Color(0xFF1E60FE), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (budgets.isEmpty)
            _buildEmptyBudget(context)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: budgets.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final budget = budgets[index];
                final spending = transProvider.getCategorySpending(budget.categoryName, now.month, now.year);
                final percent = budget.limitAmount > 0 ? (spending / budget.limitAmount) : 0.0;
                final remaining = budget.limitAmount - spending;
                
                Color progressColor = Colors.green;
                if (percent > 0.9) {
                  progressColor = Colors.red;
                } else if (percent > 0.7) {
                  progressColor = Colors.orange;
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(budget.categoryName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${(percent * 100).toStringAsFixed(0)}%',
                            style: TextStyle(color: progressColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: percent.clamp(0.0, 1.0),
                          backgroundColor: progressColor.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Terpakai: ${currencyFormatter.format(spending)}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          Text(
                            remaining >= 0 
                                ? 'Sisa: ${currencyFormatter.format(remaining)}'
                                : 'Over: ${currencyFormatter.format(remaining.abs())}',
                            style: TextStyle(
                              fontSize: 11, 
                              color: remaining >= 0 ? Colors.grey : Colors.red,
                              fontWeight: remaining < 0 ? FontWeight.bold : FontWeight.normal
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyBudget(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5FB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(Icons.track_changes, size: 40, color: Colors.blue.withOpacity(0.3)),
          const SizedBox(height: 12),
          const Text(
            'Belum ada target budget',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D1C44)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pasang budget per kategori biar gak boros gess!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showSetBudgetSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SetBudgetSheet(),
    );
  }
}

class SetBudgetSheet extends StatefulWidget {
  const SetBudgetSheet({super.key});

  @override
  State<SetBudgetSheet> createState() => _SetBudgetSheetState();
}

class _SetBudgetSheetState extends State<SetBudgetSheet> {
  String? _selectedCategory;
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategory = AppCategories.expenseCategories.first.name;
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final now = DateTime.now();

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Atur Anggaran', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const Text('Pilih Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                items: AppCategories.expenseCategories.map((cat) {
                  return DropdownMenuItem(value: cat.name, child: Text(cat.name));
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Jatah Maksimal', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: 'Rp ',
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text) ?? 0;
                if (amount > 0 && _selectedCategory != null) {
                  budgetProvider.setBudget(CategoryBudget(
                    categoryName: _selectedCategory!,
                    limitAmount: amount,
                    month: now.month,
                    year: now.year,
                  ));
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E60FE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Simpan Budget'),
            ),
          ),
        ],
      ),
    );
  }
}
