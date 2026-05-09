import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'logic/split_bill_logic.dart';
import 'logic/financial_models.dart';

class SplitBillSuccessScreen extends StatelessWidget {
  final String title;
  final double totalAmount;
  final List<UserDebt> debts;
  final List<User> allUsers;
  final List<TransactionItem> items;

  const SplitBillSuccessScreen({
    super.key,
    required this.title,
    required this.totalAmount,
    required this.debts,
    required this.allUsers,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark 
              ? [const Color(0xFF1A1A2E), const Color(0xFF0D0D1F)]
              : [const Color(0xFFF0F4FF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Color(0xFF00C853), size: 60),
              ),
              const SizedBox(height: 16),
              const Text('Tagihan Berhasil!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    children: [
                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now()), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(thickness: 1)),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Pembayaran', style: TextStyle(color: Colors.grey)),
                          Text(currencyFormatter.format(totalAmount), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF1E60FE))),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Align(alignment: Alignment.centerLeft, child: Text('Rincian Per Orang:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey))),
                      const SizedBox(height: 16),
                      
                      Expanded(
                        child: ListView.builder(
                          itemCount: allUsers.length,
                          itemBuilder: (context, index) {
                            final u = allUsers[index];
                            final d = debts.firstWhere((debt) => debt.userId == u.id, orElse: () => UserDebt(userId: u.id, itemsTotal: 0, taxShare: 0, grandTotal: 0));
                            bool isMe = u.id == 'me';
                            
                            final userItems = items.where((item) => item.assignedUserIds.contains(u.id)).map((item) => item.name).toList();
                            String itemsStr = userItems.isEmpty ? 'Belum pilih menu' : userItems.join(', ');

                            return Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: isMe ? Colors.grey.shade100 : const Color(0xFF1E60FE).withOpacity(0.1),
                                    child: Text(u.name[0].toUpperCase(), style: TextStyle(fontSize: 12, color: isMe ? Colors.grey : const Color(0xFF1E60FE), fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(isMe ? 'Saya (Pembalang)' : u.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isMe ? Colors.grey : null)),
                                        Text(itemsStr, style: TextStyle(fontSize: 11, color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        if (d.itemsTotal > 0 || d.taxShare > 0)
                                          Text(
                                            'Menu: ${currencyFormatter.format(d.itemsTotal)} + Pajak: ${currencyFormatter.format(d.taxShare)}',
                                            style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontStyle: FontStyle.italic),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(currencyFormatter.format(d.grandTotal), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isMe ? Colors.grey : const Color(0xFF1E60FE))),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(thickness: 1, height: 32),
                      const Text('Tagihan dicatat otomatis di Saldoku', style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E60FE),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Kembali ke Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
