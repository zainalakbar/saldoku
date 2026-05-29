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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pantau Budget',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  Text(
                    'Batas pengeluaran bulan ini',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => _showSetBudgetSheet(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Atur Budget', style: TextStyle(fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF1E60FE),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
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
                final cat = AppCategories.expenseCategories.firstWhere((c) => c.name == budget.categoryName, orElse: () => AppCategories.expenseCategories.last);
                final spending = transProvider.getCategorySpending(budget.categoryName, now.month, now.year);
                final percent = budget.limitAmount > 0 ? (spending / budget.limitAmount) : 0.0;
                final remaining = budget.limitAmount - spending;
                
                Color progressColor = cat.color;
                if (percent > 0.9) {
                  progressColor = Colors.red;
                } else if (percent > 0.7) {
                  progressColor = Colors.orange;
                }

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFF1E60FE).withOpacity(0.45), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
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
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: cat.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(cat.icon, color: cat.color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(budget.categoryName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).colorScheme.onSurface)),
                                Text(
                                  remaining >= 0 
                                      ? 'Sisa: ${currencyFormatter.format(remaining)}'
                                      : 'Over: ${currencyFormatter.format(remaining.abs())}',
                                  style: TextStyle(
                                    fontSize: 12, 
                                    color: remaining >= 0 ? Colors.grey.shade400 : Colors.redAccent,
                                    fontWeight: remaining < 0 ? FontWeight.bold : FontWeight.normal
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${(percent * 100).toStringAsFixed(0)}%',
                            style: TextStyle(color: progressColor, fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Stack(
                        children: [
                          Container(
                            height: 10,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: percent.clamp(0.0, 1.0),
                            child: Container(
                              height: 10,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [progressColor, progressColor.withOpacity(0.6)],
                                ),
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [
                                  BoxShadow(
                                    color: progressColor.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Terpakai: ${currencyFormatter.format(spending)}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Limit: ${currencyFormatter.format(budget.limitAmount)}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
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
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF1E60FE).withOpacity(0.45), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: const Color(0xFF1E60FE).withOpacity(0.12), blurRadius: 16)
              ],
            ),
            child: const Icon(Icons.track_changes, size: 32, color: Color(0xFF1E90FF)),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum ada target budget',
            style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Pasang budget per kategori biar gak boros gess!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
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
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Atur Anggaran', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          Text('Tentukan jatah maksimal belanja gess', style: TextStyle(color: Colors.grey.shade500)),
          const SizedBox(height: 32),
          Text('Pilih Kategori', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8))),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E60FE).withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                dropdownColor: Theme.of(context).colorScheme.surface,
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1E90FF)),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500),
                items: AppCategories.expenseCategories.map((cat) {
                  return DropdownMenuItem(
                    value: cat.name, 
                    child: Row(
                      children: [
                        Icon(cat.icon, color: cat.color, size: 20),
                        const SizedBox(width: 12),
                        Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    )
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Jatah Maksimal (Limit)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8))),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              prefixText: 'Rp ',
              prefixStyle: const TextStyle(color: Color(0xFF6B7C9D)),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              prefixIcon: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF1E90FF)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF1E90FF), width: 0.3)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16), 
                borderSide: const BorderSide(color: Color(0xFF1E90FF), width: 1.5)
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
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
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Simpan Budget', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

