class User {
  String id;
  String name;
  double balance;

  User({required this.id, required this.name, this.balance = 0.0});
}

class BudgetItem {
  String category;
  double limitAmount;
  double currentSpending;

  BudgetItem({
    required this.category,
    required this.limitAmount,
    this.currentSpending = 0.0,
  });
}

class TransactionItem {
  String name;
  double price;
  List<String> assignedUserIds;

  TransactionItem({
    required this.name,
    required this.price,
    List<String>? assignedUserIds,
  }) : assignedUserIds = assignedUserIds ?? [];
}

class BillTransaction {
  String id;
  List<TransactionItem> items;
  double taxAndServiceAmount;
  String mainPayerId;

  BillTransaction({
    required this.id,
    required this.items,
    required this.taxAndServiceAmount,
    required this.mainPayerId,
  });

  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + item.price);
  }

  double get totalAmount {
    return subtotal + taxAndServiceAmount;
  }
}

class UserDebt {
  final String userId;
  final double itemsTotal;
  final double taxShare;
  final double grandTotal;

  UserDebt({
    required this.userId,
    required this.itemsTotal,
    required this.taxShare,
    required this.grandTotal,
  });
}

class SplitBillService {
  // 1. Assign User ke Item
  void assignUserToItem(TransactionItem item, String userId) {
    if (!item.assignedUserIds.contains(userId)) {
      item.assignedUserIds.add(userId);
    }
  }

  // 2. Hitung hutang tiap orang secara adil
  List<UserDebt> calculateDebts(BillTransaction bill) {
    Map<String, double> userItemsTotal = {};

    // Hitung total harga dasar (subtotal) yang harus dibayar setiap user
    for (var item in bill.items) {
      if (item.assignedUserIds.isEmpty) continue;
      
      // Harga dibagi rata berdasarkan jumlah orang yang ditugaskan ke item ini
      double splitPrice = item.price / item.assignedUserIds.length;
      
      for (var userId in item.assignedUserIds) {
        userItemsTotal[userId] = (userItemsTotal[userId] ?? 0.0) + splitPrice;
      }
    }

    double billSubtotal = bill.subtotal;
    List<UserDebt> calculatedDebts = [];

    // Hitung proporsi pajak & layanan untuk setiap user
    userItemsTotal.forEach((userId, itemsTotal) {
      // Jika subtotal > 0, proporsi pajak dihitung berdasarkan harga dasar yg ditanggung
      double proportion = billSubtotal > 0 ? itemsTotal / billSubtotal : 0.0;
      double taxShare = proportion * bill.taxAndServiceAmount;
      double grandTotal = itemsTotal + taxShare;

      calculatedDebts.add(UserDebt(
        userId: userId,
        itemsTotal: itemsTotal,
        taxShare: taxShare,
        grandTotal: grandTotal,
      ));
    });

    return calculatedDebts;
  }

  // 3. Proses Pembayaran Awal (Main Payer menalangi kasir)
  void processInitialPayment(BillTransaction bill, User mainPayer, BudgetItem mainPayerBudget) {
    if (bill.mainPayerId != mainPayer.id) return;
    
    // Saldo utama berkurang sebesar total tagihan kasir
    mainPayer.balance -= bill.totalAmount;
    
    // Budget tercatat sebagai pengeluaran (sementara menanggung utang teman)
    mainPayerBudget.currentSpending += bill.totalAmount;
  }

  // 4. Pembayaran Hutang & Pemulihan Budget (Teman melunasi)
  void payDebt({
    required User debtor,
    required User mainPayer,
    required double amount,
    required BudgetItem mainPayerBudget,
  }) {
    // Uang berpindah dari peminjam (debtor) ke penagih (mainPayer)
    debtor.balance -= amount;
    mainPayer.balance += amount;

    // PENTING: Anggaran mainPayer pulih sebesar uang yang dikembalikan
    // Karena pengeluaran tersebut sebenarnya adalah milik teman
    mainPayerBudget.currentSpending -= amount;
    
    // Pastikan spending tidak negatif jika terjadi kesalahan pembulatan
    if (mainPayerBudget.currentSpending < 0) {
      mainPayerBudget.currentSpending = 0;
    }
  }
}

// ==========================================
// TEST FUNCTION
// ==========================================
void main() {
  print("--- Simulasi Split Bill & Budgeting ---\n");

  // 1. Setup Users & Budgets
  var userA = User(id: 'A', name: 'Akbar (Main Payer)', balance: 1000000);
  var userB = User(id: 'B', name: 'Budi', balance: 500000);
  var userC = User(id: 'C', name: 'Citra', balance: 500000);

  var akbarFoodBudget = BudgetItem(category: 'Makan', limitAmount: 500000, currentSpending: 100000);

  print("Kondisi Awal Akbar: Saldo Rp${userA.balance}, Budget Terpakai Rp${akbarFoodBudget.currentSpending}\n");

  // 2. Setup Bill
  var item1 = TransactionItem(name: 'Nasi Goreng Spesial', price: 40000);
  var item2 = TransactionItem(name: 'Mie Tek-Tek', price: 30000);
  var item3 = TransactionItem(name: 'Es Teh Manis (3x)', price: 15000);
  var item4 = TransactionItem(name: 'Cemilan Tengah', price: 20000);

  var service = SplitBillService();

  service.assignUserToItem(item1, userA.id); // Akbar
  service.assignUserToItem(item2, userB.id); // Budi
  service.assignUserToItem(item3, userA.id); // Es teh (3x) dibagi Akbar, Budi, Citra
  service.assignUserToItem(item3, userB.id);
  service.assignUserToItem(item3, userC.id); 
  service.assignUserToItem(item4, userA.id); // Cemilan dibagi Akbar, Budi, Citra
  service.assignUserToItem(item4, userB.id);
  service.assignUserToItem(item4, userC.id); 

  var bill = BillTransaction(
    id: 'bill_01',
    items: [item1, item2, item3, item4],
    taxAndServiceAmount: 10500, // Misal pajak & layanan 10%
    mainPayerId: userA.id,
  );

  print("Total Tagihan Kasir: Rp${bill.totalAmount} (Subtotal: Rp${bill.subtotal}, Pajak: Rp${bill.taxAndServiceAmount})\n");

  // 3. Akbar Menalangi (Initial Payment)
  service.processInitialPayment(bill, userA, akbarFoodBudget);
  print("Akbar menalangi seluruh tagihan...");
  print("Kondisi Akbar Sekarang: Saldo Rp${userA.balance}, Budget Terpakai Rp${akbarFoodBudget.currentSpending}\n");

  // 4. Hitung Hutang Tiap Orang
  var debts = service.calculateDebts(bill);
  print("Rincian Hutang:");
  for (var debt in debts) {
    print("User ${debt.userId}: Harga Dasar = Rp${debt.itemsTotal.toStringAsFixed(0)}, Pajak = Rp${debt.taxShare.toStringAsFixed(0)} -> TOTAL = Rp${debt.grandTotal.toStringAsFixed(0)}");
  }
  print("");

  // 5. Teman Melunasi
  var debtB = debts.firstWhere((d) => d.userId == userB.id);
  var debtC = debts.firstWhere((d) => d.userId == userC.id);

  print("Budi melunasi hutangnya sebesar Rp${debtB.grandTotal.toStringAsFixed(0)}...");
  service.payDebt(debtor: userB, mainPayer: userA, amount: debtB.grandTotal, mainPayerBudget: akbarFoodBudget);
  
  print("Citra melunasi hutangnya sebesar Rp${debtC.grandTotal.toStringAsFixed(0)}...\n");
  service.payDebt(debtor: userC, mainPayer: userA, amount: debtC.grandTotal, mainPayerBudget: akbarFoodBudget);

  // 6. Cek Kondisi Akhir Akbar
  print("Kondisi Akhir Akbar (Setelah dilunasi teman):");
  print("Saldo: Rp${userA.balance.toStringAsFixed(0)}");
  print("Budget Terpakai: Rp${akbarFoodBudget.currentSpending.toStringAsFixed(0)} (Pulih!)");
}
