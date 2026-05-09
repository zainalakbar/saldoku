import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/financial_provider.dart';
import 'logic/financial_models.dart';
import 'logic/split_bill_logic.dart';
import 'logic/transaction_model.dart';
import 'logic/transaction_provider.dart';
import 'package:intl/intl.dart';
import 'debt_management_screen.dart';
import 'split_bill_success_screen.dart';
import 'split_bill_history_screen.dart';

class SplitBillScreen extends StatefulWidget {
  const SplitBillScreen({super.key});

  @override
  State<SplitBillScreen> createState() => _SplitBillScreenState();
}

class _SplitBillScreenState extends State<SplitBillScreen> {
  final SplitBillService _service = SplitBillService();
  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  
  // State
  final User _mainPayer = User(id: 'me', name: 'Saya (Pembalang)');
  List<User> _friends = [];
  List<TransactionItem> _items = [];
  
  final TextEditingController _billTitleController = TextEditingController(text: 'Patungan Nongkrong');
  final TextEditingController _friendNameController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemPriceController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();
  bool _showBreakdown = false;

  @override
  void initState() {
    super.initState();
    _taxController.addListener(() => setState(() {}));
    _billTitleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _billTitleController.dispose();
    _friendNameController.dispose();
    _itemNameController.dispose();
    _itemPriceController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  void _addFriend() {
    if (_friendNameController.text.isNotEmpty) {
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _friendNameController.text,
      );
      setState(() {
        _friends.add(newUser);
      });
      
      // Auto-save to persistent contacts
      context.read<FinancialProvider>().addFriend(newUser);
      
      _friendNameController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _addSavedFriend(User friend) {
    if (!_friends.any((f) => f.name == friend.name)) {
      setState(() {
        _friends.add(User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: friend.name,
        ));
      });
    }
  }

  void _addItem() {
    if (_itemNameController.text.isNotEmpty && _itemPriceController.text.isNotEmpty) {
      setState(() {
        _items.add(TransactionItem(
          name: _itemNameController.text,
          price: double.tryParse(_itemPriceController.text.replaceAll('.', '')) ?? 0.0,
        ));
      });
      _itemNameController.clear();
      _itemPriceController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  List<UserDebt> _getCurrentDebts() {
    double tax = double.tryParse(_taxController.text.replaceAll('.', '')) ?? 0.0;
    final bill = BillTransaction(
      id: 'current',
      items: _items,
      taxAndServiceAmount: tax,
      mainPayerId: _mainPayer.id,
    );
    return _service.calculateDebts(bill, [_mainPayer, ..._friends]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final debts = _getCurrentDebts();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark 
                    ? [const Color(0xFF1E1E2C), const Color(0xFF0A0E21), const Color(0xFF0A0E21)]
                    : [const Color(0xFF8BBEFF), const Color(0xFFE2EDFF), const Color(0xFFF2F5FB)],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context, isDark),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader('Judul Patungan', Icons.title_outlined, null),
                          const SizedBox(height: 12),
                          _buildTitleField(isDark),
                          const SizedBox(height: 32),
                          
                          _buildSectionHeader('1. Teman Patungan', Icons.group_add_outlined, _showAddFriendDialog),
                          const SizedBox(height: 12),
                          _buildFriendsList(),
                          const SizedBox(height: 32),
                          
                          _buildSectionHeader('2. Daftar Pesanan', Icons.receipt_long_outlined, _showAddItemDialog),
                          const SizedBox(height: 12),
                          _buildItemsList(isDark),
                          const SizedBox(height: 32),
                          
                          _buildSectionHeader('3. Pajak & Layanan', Icons.add_circle_outline, null),
                          const SizedBox(height: 12),
                          _buildTaxInput(isDark),
                          const SizedBox(height: 32),
                          
                          _buildRealTimeSummary(isDark),
                          const SizedBox(height: 32),

                          if (debts.isNotEmpty) ...[
                            _buildSectionHeader('Rincian Tagihan Live', Icons.analytics_outlined, null),
                            const SizedBox(height: 12),
                            _buildDebtsBreakdown(debts, isDark),
                          ],
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                  _buildFinalizeButton(debts),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : const Color(0xFF0D1C44), size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Split Bill',
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0D1C44), fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: Icon(Icons.history_rounded, color: isDark ? Colors.white : const Color(0xFF0D1C44)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SplitBillHistoryScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: _billTitleController,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
        decoration: InputDecoration(
          hintText: 'Misal: Makan Bakso / Main PS',
          suffixIcon: IconButton(
            icon: const Icon(Icons.check_circle, color: Color(0xFF1E60FE)),
            onPressed: () => FocusScope.of(context).unfocus(),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, VoidCallback? onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF1E60FE)),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        if (onAdd != null)
          TextButton(
            onPressed: onAdd,
            child: const Text('Tambah', style: TextStyle(color: Color(0xFF1E60FE), fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _buildFriendsList() {
    if (_friends.isEmpty) {
      return const Text('Belum ada teman ditambahkan.', style: TextStyle(color: Colors.grey, fontSize: 13));
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _friends.map((f) => Chip(
        label: Text(f.name, style: const TextStyle(color: Color(0xFF1E60FE), fontSize: 12, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E60FE).withOpacity(0.1),
        side: BorderSide.none,
        deleteIcon: const Icon(Icons.close, size: 14, color: Color(0xFF1E60FE)),
        onDeleted: () {
          setState(() {
            _friends.remove(f);
          });
        },
      )).toList(),
    );
  }

  Widget _buildItemsList(bool isDark) {
    if (_items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: const Column(
          children: [
            Icon(Icons.shopping_cart_outlined, color: Colors.grey, size: 40),
            SizedBox(height: 12),
            Text('Daftar pesanan masih kosong', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      );
    }
    return Column(
      children: _items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF1E60FE).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.receipt_long_outlined, color: Color(0xFF1E60FE), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(currencyFormatter.format(item.price), style: const TextStyle(color: Color(0xFF1E60FE), fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _items.remove(item)),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTaxInput(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: _taxController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
        decoration: InputDecoration(
          hintText: 'Total Pajak + Service (Opsional)',
          prefixText: 'Rp ',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildRealTimeSummary(bool isDark) {
    double subtotal = _items.fold(0.0, (sum, item) => sum + item.price);
    double tax = double.tryParse(_taxController.text.replaceAll('.', '')) ?? 0.0;
    double total = subtotal + tax;
    int peopleCount = _friends.length + 1; // +1 for "Saya"
    double average = total / peopleCount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [const Color(0xFF2A2A3C), const Color(0xFF1E1E2C)]
            : [const Color(0xFFF0F4FF), Colors.white],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1E60FE).withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Total Pesanan', currencyFormatter.format(subtotal), false),
          const SizedBox(height: 8),
          _buildSummaryRow('Pajak & Layanan', currencyFormatter.format(tax), false),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildSummaryRow('Total Keseluruhan', currencyFormatter.format(total), true),
          if (peopleCount > 1) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E60FE).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 14, color: Color(0xFF1E60FE)),
                  const SizedBox(width: 8),
                  Text(
                    'Rata-rata: ${currencyFormatter.format(average)} / orang',
                    style: const TextStyle(color: Color(0xFF1E60FE), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isTotal ? null : Colors.grey, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 16 : 13)),
        Text(value, style: TextStyle(color: isTotal ? const Color(0xFF1E60FE) : null, fontWeight: FontWeight.bold, fontSize: isTotal ? 20 : 14)),
      ],
    );
  }

  Widget _buildDebtsBreakdown(List<UserDebt> debts, bool isDark) {
    final all = [_mainPayer, ..._friends];
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _showBreakdown = !_showBreakdown),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E60FE).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Lihat Rincian Per Orang', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E60FE))),
                Icon(_showBreakdown ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: const Color(0xFF1E60FE), size: 20),
              ],
            ),
          ),
        ),
        if (_showBreakdown) ...[
          const SizedBox(height: 12),
          ...all.map((u) {
            final d = debts.firstWhere((debt) => debt.userId == u.id, orElse: () => UserDebt(userId: u.id, itemsTotal: 0, taxShare: 0, grandTotal: 0));
            bool isMe = u.id == 'me';
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2C) : const Color(0xFFF2F5FB),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isMe ? Colors.transparent : const Color(0xFF1E60FE).withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: isMe ? Colors.grey.shade200 : const Color(0xFF1E60FE).withOpacity(0.1),
                    child: Text(u.name[0].toUpperCase(), style: TextStyle(fontSize: 12, color: isMe ? Colors.grey : const Color(0xFF1E60FE), fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isMe ? 'Saya (Pembalang)' : u.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isMe ? Colors.grey : null)),
                        Text(
                          'Bagi rata ${_items.length} item',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                  Text(currencyFormatter.format(d.grandTotal), style: TextStyle(fontWeight: FontWeight.w900, color: isMe ? Colors.grey : const Color(0xFF1E60FE), fontSize: 15)),
                ],
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  Widget _buildFinalizeButton(List<UserDebt> debts) {
    final hasItems = _items.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: hasItems ? () => _finalizeAndSave(debts) : null,
          icon: const Icon(Icons.check_circle_outline, size: 18),
          label: const Text('Selesaikan & Simpan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E60FE),
            disabledBackgroundColor: Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            shadowColor: const Color(0xFF1E60FE).withOpacity(0.4),
          ),
        ),
      ),
    );
  }

  void _finalizeAndSave(List<UserDebt> debts) {
    final financialProvider = context.read<FinancialProvider>();
    
    // NEW: Record my own share as a real expense in transactions
    final myDebt = debts.firstWhere((d) => d.userId == 'me', orElse: () => UserDebt(userId: 'me', itemsTotal: 0, taxShare: 0, grandTotal: 0));
    if (myDebt.grandTotal > 0) {
      final transactionProvider = context.read<TransactionProvider>();
      final myExpense = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString() + "_me",
        title: "${_billTitleController.text} (Bagian Saya)",
        amount: myDebt.grandTotal,
        date: DateTime.now(),
        type: TransactionType.expense,
        category: AppCategories.getByName('Hiburan', TransactionType.expense),
        note: 'Otomatis dari Split Bill: ${_billTitleController.text}',
      );
      transactionProvider.addTransaction(myExpense);
    }
    
    double subtotal = _items.fold(0.0, (sum, item) => sum + item.price);
    double tax = double.tryParse(_taxController.text.replaceAll('.', '')) ?? 0.0;
    double total = subtotal + tax;

    // Save to History
    financialProvider.addSplitBillHistory(SplitBillHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _billTitleController.text,
      totalAmount: total,
      date: DateTime.now(),
      debts: debts,
      allUsers: [_mainPayer, ..._friends],
      items: _items,
    ));

    Navigator.pop(context); // Close Split Bill screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SplitBillSuccessScreen(
          title: _billTitleController.text,
          totalAmount: total,
          debts: debts,
          allUsers: [_mainPayer, ..._friends],
          items: _items,
        ),
      ),
    );
  }

  void _showAddFriendDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Tambah Teman', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _friendNameController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama teman baru...',
                  prefixIcon: const Icon(Icons.person_add_alt_1_outlined, color: Color(0xFF1E60FE)),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                onSubmitted: (_) {
                  _addFriend();
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 24),
            Consumer<FinancialProvider>(
              builder: (context, provider, child) {
                final savedFriends = provider.persistentFriends;
                if (savedFriends.isEmpty) return const SizedBox();
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text('Teman Tersimpan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: savedFriends.length,
                        itemBuilder: (context, index) {
                          final f = savedFriends[index];
                          final isAlreadyAdded = _friends.any((friend) => friend.name == f.name);
                          
                          return GestureDetector(
                            onTap: isAlreadyAdded ? null : () {
                              _addSavedFriend(f);
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 80,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              child: Column(
                                children: [
                                  Opacity(
                                    opacity: isAlreadyAdded ? 0.3 : 1.0,
                                    child: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: const Color(0xFF1E60FE).withOpacity(0.1),
                                      child: Text(f.name[0].toUpperCase(), style: const TextStyle(color: Color(0xFF1E60FE), fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    f.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 11, color: isAlreadyAdded ? Colors.grey : null),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _addFriend();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E60FE),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Simpan Ke Patungan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _itemNameController, decoration: const InputDecoration(hintText: 'Nama Item')),
            const SizedBox(height: 12),
            TextField(controller: _itemPriceController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Harga', prefixText: 'Rp ')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(onPressed: () { _addItem(); Navigator.pop(context); }, child: const Text('Tambah')),
        ],
      ),
    );
  }
}
