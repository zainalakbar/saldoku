import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/financial_provider.dart';
import 'logic/financial_models.dart';
import 'package:intl/intl.dart';

class DebtManagementScreen extends StatefulWidget {
  const DebtManagementScreen({super.key});

  @override
  State<DebtManagementScreen> createState() => _DebtManagementScreenState();
}

class _DebtManagementScreenState extends State<DebtManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddDebtDialog(BuildContext context, DebtType type) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    DateTime? selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Text(
              type == DebtType.fromMe ? 'Tambah Hutang Saya' : 'Tambah Piutang (Orang Lain)',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nama Orang',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah Nominal',
                prefixText: 'Rp ',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
                    final amount = double.tryParse(amountController.text) ?? 0;
                    if (amount > 0) {
                      final newDebt = Debt(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        personName: nameController.text,
                        amount: amount,
                        type: type,
                        createdAt: DateTime.now(),
                        isPaid: false,
                      );
                      context.read<FinancialProvider>().addDebt(newDebt);
                      Navigator.pop(context);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('Simpan Catatan', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showDeleteOptions(BuildContext context) {
    final type = _tabController.index == 0 ? DebtType.toMe : DebtType.fromMe;
    final typeName = type == DebtType.toMe ? 'Piutang' : 'Hutang';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            Text('Bersihkan Histori $typeName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.done_all, color: Colors.green, size: 20),
              ),
              title: const Text('Hapus yang SUDAH LUNAS', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Membersihkan catatan yang sudah selesai'),
              onTap: () {
                context.read<FinancialProvider>().clearPaidDebts(type);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Catatan lunas berhasil dihapus')));
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.delete_forever, color: Colors.red, size: 20),
              ),
              title: const Text('Hapus SEMUA Catatan', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Menghapus seluruh histori $typeName'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Konfirmasi'),
                    content: Text('Yakin mau hapus SEMUA histori $typeName? Data ini tidak bisa dikembalikan.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                      TextButton(
                        onPressed: () {
                          context.read<FinancialProvider>().clearAllDebts(type);
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                        }, 
                        child: const Text('Hapus Semua', style: TextStyle(color: Colors.red))
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Manajemen Hutang'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () => _showDeleteOptions(context),
            tooltip: 'Bersihkan Histori',
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Piutang (Ke Saya)'),
            Tab(text: 'Hutang (Dari Saya)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDebtList(context, DebtType.toMe),
          _buildDebtList(context, DebtType.fromMe),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDebtDialog(context, _tabController.index == 0 ? DebtType.toMe : DebtType.fromMe),
        label: const Text('Tambah Catatan'),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildDebtList(BuildContext context, DebtType type) {
    return Consumer<FinancialProvider>(
      builder: (context, provider, child) {
        final filteredDebts = provider.debts.where((d) => d.type == type).toList();

        if (filteredDebts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.withOpacity(0.2)),
                const SizedBox(height: 16),
                Text('Belum ada catatan gess', style: TextStyle(color: Colors.grey.withOpacity(0.5))),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
          itemCount: filteredDebts.length,
          itemBuilder: (context, index) {
            final debt = filteredDebts[index];
            return _buildDebtCard(context, debt);
          },
        );
      },
    );
  }

  Widget _buildDebtCard(BuildContext context, Debt debt) {
    final color = debt.type == DebtType.toMe ? Colors.green : Colors.red;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onLongPress: () {
              // Delete logic
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hapus Catatan?'),
                  content: const Text('Data ini bakal ilang selamanya gess.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                    TextButton(
                      onPressed: () {
                        context.read<FinancialProvider>().deleteDebt(debt.id);
                        Navigator.pop(context);
                      }, 
                      child: const Text('Hapus', style: TextStyle(color: Colors.red))
                    ),
                  ],
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (debt.isPaid ? Colors.grey : color).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      debt.type == DebtType.toMe ? Icons.arrow_downward : Icons.arrow_upward,
                      color: debt.isPaid ? Colors.grey : color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          debt.personName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: debt.isPaid ? TextDecoration.lineThrough : null,
                            color: debt.isPaid ? Colors.grey : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM yyyy • HH:mm').format(debt.createdAt),
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormatter.format(debt.amount),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: debt.isPaid ? Colors.grey : color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => context.read<FinancialProvider>().toggleDebtPaid(debt.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: debt.isPaid ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            debt.isPaid ? 'LUNAS ✅' : 'BELUM LUNAS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: debt.isPaid ? Colors.green : Colors.grey,
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
        ),
      ),
    );
  }
}
