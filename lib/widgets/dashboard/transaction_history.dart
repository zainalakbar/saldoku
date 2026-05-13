import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../logic/transaction_model.dart';
import '../../logic/transaction_provider.dart';
import '../../logic/financial_provider.dart';
import '../../logic/financial_models.dart';
import '../../transaction_view_screen.dart';
import '../../transaction_detail_screen.dart';
import '../../debt_management_screen.dart';

class TransactionHistorySection extends StatefulWidget {
  const TransactionHistorySection({super.key});

  @override
  State<TransactionHistorySection> createState() => _TransactionHistorySectionState();
}

class _TransactionHistorySectionState extends State<TransactionHistorySection> {
  bool _isAsetTab = true;
  bool _isExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Riwayat Transaksi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari transaksi...',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // Toggle (Aset / Hutang)
        Container(
          width: 220,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isAsetTab = true),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: _isAsetTab ? BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ) : null,
                    alignment: Alignment.center,
                    child: Text('Transaksi', style: TextStyle(fontWeight: _isAsetTab ? FontWeight.w600 : FontWeight.w500, color: _isAsetTab ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withOpacity(0.4), fontSize: 14)),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isAsetTab = false),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: !_isAsetTab ? BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ) : null,
                    alignment: Alignment.center,
                    child: Text('Hutang', style: TextStyle(fontWeight: !_isAsetTab ? FontWeight.w600 : FontWeight.w500, color: !_isAsetTab ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withOpacity(0.4), fontSize: 14)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Dynamic Label above the list
        if (_searchQuery.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E60FE),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _isExpanded ? 'Semua Riwayat' : '3 Transaksi Terbaru',
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.w600, 
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                  ),
                ),
              ],
            ),
          ),
        
        // Content
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isAsetTab ? _buildAsetContent() : _buildHutangContent(),
        ),
        
        // Expandable "Lihat Semua" Button
        if (_searchQuery.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                icon: Icon(
                  _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, 
                  size: 16, 
                  color: const Color(0xFF1E60FE)
                ),
                label: Text(
                  _isExpanded ? 'Sembunyikan' : 'Lihat Semua', 
                  style: const TextStyle(color: Color(0xFF1E60FE), fontWeight: FontWeight.bold, fontSize: 13)
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: const Color(0xFF1E60FE).withOpacity(0.05),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAsetContent() {
    return Consumer<TransactionProvider>(
      key: const ValueKey('aset'),
      builder: (context, provider, child) {
        final filteredTransactions = provider.transactions.where((t) {
          final matchesSearch = t.title.toLowerCase().contains(_searchQuery) || 
                               t.category.name.toLowerCase().contains(_searchQuery) ||
                               (t.note?.toLowerCase().contains(_searchQuery) ?? false);
          return matchesSearch;
        }).toList();

        if (filteredTransactions.isEmpty) {
          return _buildEmptyState(
            icon: Icons.edit_document,
            title: _searchQuery.isEmpty ? 'Belum ada transaksi' : 'Transaksi tidak ditemukan',
            subtitle: _searchQuery.isEmpty 
              ? 'Mulai mencatat transaksi harianmu' 
              : 'Coba cari dengan kata kunci lain',
            buttonLabel: 'Catat Transaksi',
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: (_isExpanded || _searchQuery.isNotEmpty) ? filteredTransactions.length : min(3, filteredTransactions.length),
          itemBuilder: (context, index) {
            final t = filteredTransactions[index];
            final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
            final isExpense = t.type == TransactionType.expense;

            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TransactionViewScreen(transaction: t)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'trans_icon_${t.id}',
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: t.category.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(t.category.icon, color: t.category.color, size: 20),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    t.title, 
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (t.imagePath != null && t.imagePath!.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E60FE).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(Icons.image_outlined, size: 10, color: Color(0xFF1E60FE)),
                                  ),
                                ],
                              ],
                            ),
                            Text(DateFormat('dd MMM yyyy').format(t.date), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text(
                        '${isExpense ? '-' : '+'}${currencyFormatter.format(t.amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isExpense ? Colors.red : Colors.green,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHutangContent() {
    return Consumer<FinancialProvider>(
      key: const ValueKey('hutang'),
      builder: (context, provider, child) {
        final allDebts = provider.debts.where((d) {
          final matchesSearch = d.personName.toLowerCase().contains(_searchQuery) || 
                               (d.note?.toLowerCase().contains(_searchQuery) ?? false);
          return matchesSearch;
        }).toList();

        if (allDebts.isEmpty) {
          return _buildEmptyState(
            icon: Icons.receipt_long_outlined,
            title: _searchQuery.isEmpty ? 'Belum ada hutang' : 'Catatan tidak ditemukan',
            subtitle: _searchQuery.isEmpty 
              ? 'Mulai mencatat hutang piutangmu' 
              : 'Coba cari nama orang atau catatan lain',
            buttonLabel: 'Tambah Catatan',
            isDashed: true,
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: (_isExpanded || _searchQuery.isNotEmpty) ? allDebts.length : min(3, allDebts.length),
          itemBuilder: (context, index) {
            final d = allDebts[index];
            final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
            final isToMe = d.type == DebtType.toMe;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isToMe ? Colors.blue.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isToMe ? Icons.arrow_downward : Icons.arrow_upward, 
                        color: isToMe ? Colors.blue : Colors.orange, 
                        size: 20
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.personName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(d.note ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyFormatter.format(d.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: d.isPaid ? Colors.grey : (isToMe ? Colors.blue : Colors.orange),
                            fontSize: 14,
                            decoration: d.isPaid ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        Text(
                          d.isPaid ? 'LUNAS' : (isToMe ? 'PIUTANG' : 'HUTANG'),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: d.isPaid ? Colors.green : Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    bool isDashed = false,
  }) {
    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (buttonLabel == 'Catat Transaksi') {
                // To be implemented or handled in parent
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E60FE),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(buttonLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: isDashed 
          ? CustomPaint(
              painter: DashedRectPainter(
                color: Colors.grey.shade400,
                strokeWidth: 1.2,
                gap: 6.0,
                borderRadius: 16.0,
              ),
              child: content,
            )
          : content,
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double borderRadius;

  DashedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    var path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius)));

    Path dashPath = Path();
    double distance = 0.0;
    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
      distance = 0.0;
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
