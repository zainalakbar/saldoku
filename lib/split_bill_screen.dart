import 'package:flutter/material.dart';
import 'logic/split_bill_logic.dart';

class SplitBillScreen extends StatefulWidget {
  const SplitBillScreen({super.key});

  @override
  State<SplitBillScreen> createState() => _SplitBillScreenState();
}

class _SplitBillScreenState extends State<SplitBillScreen> {
  final SplitBillService _service = SplitBillService();
  
  // Data State
  User _mainPayer = User(id: 'me', name: 'Saya (Pembalang)', balance: 1000000);
  List<User> _friends = [];
  List<TransactionItem> _items = [];
  
  // Controllers
  final TextEditingController _friendNameController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemPriceController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();

  List<User> get _allUsers => [_mainPayer, ..._friends];

  @override
  void dispose() {
    _friendNameController.dispose();
    _itemNameController.dispose();
    _itemPriceController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  void _addFriend() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Tambah Teman', style: TextStyle(color: Color(0xFF0D1C44), fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _friendNameController,
            decoration: const InputDecoration(
              hintText: 'Nama Teman',
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E60FE))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_friendNameController.text.isNotEmpty) {
                  setState(() {
                    _friends.add(User(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _friendNameController.text,
                    ));
                  });
                  _friendNameController.clear();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E60FE), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Tambah Makanan/Pesanan', style: TextStyle(color: Color(0xFF0D1C44), fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _itemNameController,
                decoration: const InputDecoration(hintText: 'Nama Makanan (mis: Nasi Goreng)', focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E60FE)))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _itemPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Harga (mis: 25000)', prefixText: 'Rp ', focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E60FE)))),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_itemNameController.text.isNotEmpty && _itemPriceController.text.isNotEmpty) {
                  setState(() {
                    _items.add(TransactionItem(
                      name: _itemNameController.text,
                      price: double.tryParse(_itemPriceController.text) ?? 0.0,
                    ));
                  });
                  _itemNameController.clear();
                  _itemPriceController.clear();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E60FE), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Tambah', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showAssignDialog(TransactionItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Siapa yang makan ${item.name}?', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D1C44))),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _allUsers.length,
                      itemBuilder: (context, index) {
                        User user = _allUsers[index];
                        bool isAssigned = item.assignedUserIds.contains(user.id);
                        return CheckboxListTile(
                          value: isAssigned,
                          activeColor: const Color(0xFF1E60FE),
                          title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                          onChanged: (bool? val) {
                            setModalState(() {
                              if (val == true) {
                                item.assignedUserIds.add(user.id);
                              } else {
                                item.assignedUserIds.remove(user.id);
                              }
                            });
                            setState(() {}); // Update parent UI
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E60FE),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Selesai', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            );
          }
        );
      },
    );
  }

  void _calculateAndShowResult() {
    double tax = double.tryParse(_taxController.text) ?? 0.0;
    
    BillTransaction bill = BillTransaction(
      id: 'bill_current',
      items: _items,
      taxAndServiceAmount: tax,
      mainPayerId: _mainPayer.id,
    );

    List<UserDebt> debts = _service.calculateDebts(bill);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFFF2F5FB),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 24),
              const Text('Rincian Patungan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D1C44))),
              const SizedBox(height: 8),
              Text('Total Tagihan Kasir: Rp${bill.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: debts.length,
                  itemBuilder: (context, index) {
                    var debt = debts[index];
                    var user = _allUsers.firstWhere((u) => u.id == debt.userId, orElse: () => User(id: '', name: 'Unknown'));
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D1C44))),
                                const SizedBox(height: 4),
                                Text('Item: Rp${debt.itemsTotal.toStringAsFixed(0)} | Pajak: Rp${debt.taxShare.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                              ],
                            ),
                          ),
                          Text('Rp${debt.grandTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1E60FE))),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0D1C44)),
        title: const Text('Split Bill', style: TextStyle(color: Color(0xFF0D1C44), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teman Patungan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Teman Patungan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D1C44))),
                TextButton.icon(
                  onPressed: _addFriend,
                  icon: const Icon(Icons.person_add, size: 16, color: Color(0xFF1E60FE)),
                  label: const Text('Tambah', style: TextStyle(color: Color(0xFF1E60FE), fontWeight: FontWeight.bold)),
                )
              ],
            ),
            if (_friends.isEmpty)
              const Text('Belum ada teman ditambahkan. Hanya kamu saat ini.', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12))
            else
              Wrap(
                spacing: 8,
                children: _friends.map((f) => Chip(
                  label: Text(f.name, style: const TextStyle(color: Color(0xFF1E60FE), fontSize: 12, fontWeight: FontWeight.w600)),
                  backgroundColor: const Color(0xFFE8F0FF),
                  side: BorderSide.none,
                  deleteIcon: const Icon(Icons.close, size: 14, color: Color(0xFF1E60FE)),
                  onDeleted: () {
                    setState(() {
                      _friends.remove(f);
                      // Hapus juga assignment orang tsb
                      for(var item in _items) {
                        item.assignedUserIds.remove(f.id);
                      }
                    });
                  },
                )).toList(),
              ),
            const SizedBox(height: 32),

            // Daftar Pesanan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Daftar Pesanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D1C44))),
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add_shopping_cart, size: 16, color: Color(0xFF1E60FE)),
                  label: const Text('Tambah', style: TextStyle(color: Color(0xFF1E60FE), fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 8),
            if (_items.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: const Text('Belum ada makanan/pesanan yang ditambahkan.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF9CA3AF))),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  var item = _items[index];
                  String assignedNames = item.assignedUserIds.map((id) => _allUsers.firstWhere((u) => u.id == id, orElse: () => User(id: '', name: 'Unknown')).name).join(', ');
                  if (assignedNames.isEmpty) assignedNames = 'Belum ada yg ditugaskan';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D1C44))),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Rp${item.price.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF1E60FE), fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text('Dimakan oleh: $assignedNames', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.people_alt_outlined, color: Color(0xFF9CA3AF)),
                        onPressed: () => _showAssignDialog(item),
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 32),

            // Pajak & Biaya Layanan
            const Text('Pajak & Biaya Layanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D1C44))),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _taxController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Total Pajak (mis: 15000)',
                  prefixText: 'Rp ',
                  prefixStyle: const TextStyle(color: Color(0xFF0D1C44), fontWeight: FontWeight.w600),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Tombol Hitung
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _items.isNotEmpty ? _calculateAndShowResult : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E60FE),
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Hitung Patungan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
