import 'financial_models.dart';

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

class SplitBillService {
  // 1. Assign User ke Item
  void assignUserToItem(TransactionItem item, String userId) {
    if (!item.assignedUserIds.contains(userId)) {
      item.assignedUserIds.add(userId);
    }
  }

  // 2. Hitung hutang bagi rata
  List<UserDebt> calculateDebts(BillTransaction bill, List<User> allUsers) {
    if (allUsers.isEmpty) return [];

    double totalPerPerson = bill.totalAmount / allUsers.length;
    double itemsTotalPerPerson = bill.subtotal / allUsers.length;
    double taxPerPerson = bill.taxAndServiceAmount / allUsers.length;

    return allUsers.map((user) => UserDebt(
      userId: user.id,
      itemsTotal: itemsTotalPerPerson,
      taxShare: taxPerPerson,
      grandTotal: totalPerPerson,
    )).toList();
  }

  // 3. Hitung Cepat (Bagi Rata)
  double calculateQuickSplit(double totalAmount, int numberOfPeople) {
    if (numberOfPeople <= 0) return 0.0;
    return totalAmount / numberOfPeople;
  }

  // 4. Proses Pembayaran Awal (Main Payer menalangi kasir)
  void processInitialPayment(BillTransaction bill, User mainPayer, BudgetItem mainPayerBudget) {
    if (bill.mainPayerId != mainPayer.id) return;
    
    // Saldo utama berkurang sebesar total tagihan kasir
    mainPayer.balance -= bill.totalAmount;
    
    // Budget tercatat sebagai pengeluaran (sementara menanggung utang teman)
    mainPayerBudget.currentSpending += bill.totalAmount;
  }

  // 5. Pembayaran Hutang & Pemulihan Budget (Teman melunasi)
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
