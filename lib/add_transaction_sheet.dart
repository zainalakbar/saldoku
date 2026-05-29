import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'logic/transaction_model.dart';
import 'logic/transaction_provider.dart';
import 'logic/financial_provider.dart';
import 'logic/financial_models.dart';
import 'logic/notification_provider.dart';
import 'utils/app_notification.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  
  TransactionType _type = TransactionType.expense;
  TransactionCategory? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  FinancialGoal? _selectedGoal;
  FinancialAsset? _selectedAsset;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedCategory = AppCategories.expenseCategories.first;
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final amountText = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final amount = double.tryParse(amountText) ?? 0.0;

      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nominal harus lebih dari 0')),
        );
        return;
      }

      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        amount: amount,
        date: _selectedDate,
        type: _type,
        category: _selectedCategory!,
        imagePath: _selectedImage?.path,
        assetId: _selectedAsset?.id,
      );

      Provider.of<TransactionProvider>(context, listen: false).addTransaction(transaction);

      // Show in-app notification if enabled
      final notifProvider = Provider.of<NotificationProvider>(context, listen: false);
      if (notifProvider.transactionNotif) {
        final isIncome = _type == TransactionType.income;
        final notifTitle = isIncome ? 'Pemasukan Dicatat' : 'Pengeluaran Dicatat';
        final notifMsg = '${_titleController.text} — ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(amount)}';
        final notifIcon = isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
        final notifColor = isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444);

        // Popup in-app
        AppNotification.show(
          context,
          message: isIncome ? '✅ Pemasukan berhasil dicatat!' : '✅ Pengeluaran berhasil dicatat!',
          type: isIncome ? AppNotificationType.success : AppNotificationType.info,
        );

        // Simpan ke riwayat notifikasi
        notifProvider.addToHistory(
          title: notifTitle,
          message: notifMsg,
          icon: notifIcon,
          color: notifColor,
        );
      }

      
      // Update asset balance if selected
      if (_selectedAsset != null) {
        final financialProvider = Provider.of<FinancialProvider>(context, listen: false);
        final updatedAmount = _type == TransactionType.income 
            ? _selectedAsset!.amount + amount 
            : _selectedAsset!.amount - amount;
            
        financialProvider.updateAssetAmount(_selectedAsset!.id, updatedAmount);
      }

      // If category is "Menabung", also update the goal
      if (_selectedCategory?.name == 'Menabung' && _selectedGoal != null) {
        Provider.of<FinancialProvider>(context, listen: false).updateGoalAmount(_selectedGoal!.id, amount);
      }
      
      Navigator.pop(context);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E60FE),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0D1C44),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? Theme.of(context).scaffoldBackgroundColor 
            : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Catat Transaksi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Theme.of(context).colorScheme.surface 
                            : Colors.grey.shade100, 
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 18, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Type Toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Theme.of(context).colorScheme.surface 
                      : const Color(0xFFF2F5FB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildTypeButton(TransactionType.expense, 'Pengeluaran'),
                    _buildTypeButton(TransactionType.income, 'Pemasukan'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Amount Input
              const Text('Nominal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E60FE).withOpacity(0.18),
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    prefixText: 'Rp ',
                    prefixStyle: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark 
                        ? Theme.of(context).colorScheme.surface 
                        : const Color(0xFFF9FAFB),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: const Color(0xFF1E60FE).withOpacity(0.45), width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: const Color(0xFF1E60FE), width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.red, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.red, width: 1.5),
                    ),
                    hintText: '0',
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                  ),
                  validator: (value) => value!.isEmpty ? 'Masukkan nominal' : null,
                ),
              ),
              const SizedBox(height: 24),

              // Description
              Text(_type == TransactionType.expense ? 'Keterangan' : 'Sumber Pemasukan', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: _type == TransactionType.expense ? 'Beli apa hari ini?' : 'Dapat uang dari mana?',
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark 
                      ? Theme.of(context).colorScheme.surface 
                      : const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (value) => value!.isEmpty ? 'Masukkan keterangan' : null,
              ),
              const SizedBox(height: 24),

              // Asset Selector (Account/Wallet)
              const Text('Pilih Rekening / Dompet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
              const SizedBox(height: 8),
              Consumer<FinancialProvider>(
                builder: (context, finProvider, child) {
                  final assets = finProvider.assets;
                  if (assets.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                      child: const Text('Kamu belum punya rekening. Buat di tab Akun/Profil gess!', style: TextStyle(fontSize: 12, color: Colors.orange)),
                    );
                  }
                  
                  if (_selectedAsset == null && assets.isNotEmpty) {
                    _selectedAsset = assets.first;
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Theme.of(context).colorScheme.surface 
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<FinancialAsset>(
                        value: _selectedAsset,
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        items: assets.map((asset) {
                          return DropdownMenuItem(
                            value: asset,
                            child: Row(
                              children: [
                                Icon(Icons.account_balance_wallet_outlined, color: const Color(0xFF1E60FE), size: 18),
                                const SizedBox(width: 12),
                                Text(asset.name, style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (asset) {
                          setState(() => _selectedAsset = asset);
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Category & Date Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kategori', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _showCategoryPicker,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? Theme.of(context).colorScheme.surface 
                                  : const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(_selectedCategory?.icon ?? Icons.category, color: _selectedCategory?.color ?? Colors.grey, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedCategory?.name ?? 'Pilih',
                                    style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF9CA3AF)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tanggal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? Theme.of(context).colorScheme.surface 
                                  : const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Color(0xFF1E60FE), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    DateFormat('dd/MM/yy').format(_selectedDate),
                                    style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Goal Selector for "Menabung" category
              if (_selectedCategory?.name == 'Menabung') ...[
                const Text('Pilih Target Tabungan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
                const SizedBox(height: 8),
                Consumer<FinancialProvider>(
                  builder: (context, finProvider, child) {
                    final goals = finProvider.goals;
                    if (goals.isEmpty) {
                      return const Text('Belum ada target tabungan. Buat dulu di Dashboard!', style: TextStyle(fontSize: 12, color: Colors.red));
                    }
                    
                    // Auto-select first goal if none selected
                    if (_selectedGoal == null && goals.isNotEmpty) {
                      _selectedGoal = goals.first;
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Theme.of(context).colorScheme.surface 
                            : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<FinancialGoal>(
                          value: _selectedGoal,
                          isExpanded: true,
                          dropdownColor: Theme.of(context).colorScheme.surface,
                          hint: const Text('Pilih Target'),
                          items: goals.map((goal) {
                            return DropdownMenuItem(
                              value: goal,
                              child: Row(
                                children: [
                                  Icon(goal.icon, color: goal.color, size: 18),
                                  const SizedBox(width: 12),
                                  Text(goal.name, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (goal) {
                            setState(() => _selectedGoal = goal);
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],

              const SizedBox(height: 24),
              // Image Picker Section
              const Text('Foto Struk (Opsional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
              const SizedBox(height: 12),
              if (_selectedImage != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_selectedImage!, height: 120, width: double.infinity, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedImage = null),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt, color: Color(0xFF1E60FE)),
                        label: const Text('Kamera', style: TextStyle(color: Color(0xFF1E60FE))),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: Color(0xFF1E60FE)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library, color: Color(0xFF1E60FE)),
                        label: const Text('Galeri', style: TextStyle(color: Color(0xFF1E60FE))),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: Color(0xFF1E60FE)),
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E60FE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Simpan Transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(TransactionType type, String label) {
    final isActive = _type == type;
    final color = type == TransactionType.income ? Colors.green : const Color(0xFFFF5252);
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _type = type;
            _selectedCategory = type == TransactionType.income 
                ? AppCategories.incomeCategories.first 
                : AppCategories.expenseCategories.first;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive ? [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
            ] : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? color : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    final categories = _type == TransactionType.income 
        ? AppCategories.incomeCategories 
        : AppCategories.expenseCategories;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Pilih Kategori', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D1C44))),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategory = cat);
                      Navigator.pop(context);
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cat.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(cat.icon, color: cat.color, size: 24),
                        ),
                        const SizedBox(height: 8),
                        Text(cat.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// Fixed BorderSide issue in previous snippet
class BorderBorderSide {
  static const none = BorderSide.none;
}
