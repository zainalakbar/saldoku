import 'package:flutter/material.dart';

class StatistikScreen extends StatelessWidget {
  const StatistikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Stack(
        children: [
          // Background Gradient Header
          Container(
            height: 300,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE2EDFF),
                  Color(0xFFF2F5FB),
                  Color(0xFFF2F5FB),
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text('Statistik', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0D1C44))),
                  const SizedBox(height: 4),
                  const Text('Analisis keuangan bulanan', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
                  const SizedBox(height: 32),
                  const Text('SALDO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF), letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  
                  // Empty Chart State
                  Container(
                    height: 150,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Belum ada transaksi.', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
                        SizedBox(height: 4),
                        Text('Grafik akan muncul setelah ada transaksi.', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Month Selector
                  _buildMonthSelector(),
                  const SizedBox(height: 24),
                  
                  // Summary Cards
                  _buildSummaryItem(icon: Icons.south_west, iconColor: const Color(0xFF1E60FE), iconBgColor: const Color(0xFFE8F0FF), title: 'Pendapatan bulan ini', amount: 'Rp0'),
                  const SizedBox(height: 16),
                  _buildSummaryItem(icon: Icons.north_east, iconColor: const Color(0xFFE53935), iconBgColor: const Color(0xFFFFEBEE), title: 'Pengeluaran bulan ini', amount: 'Rp0'),
                  const SizedBox(height: 16),
                  
                  // Asset & Debt Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildSmallBalanceCard(icon: Icons.account_balance_wallet, iconColor: const Color(0xFF1E60FE), iconBgColor: const Color(0xFFE8F0FF), title: 'Total Aset', amount: 'Rp0'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSmallBalanceCard(icon: Icons.credit_card, iconColor: const Color(0xFF4A4A4A), iconBgColor: const Color(0xFFF0F0F0), title: 'Total Hutang', amount: 'Rp0'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Cash Flow Card
                  _buildCashFlowCard(),
                  const SizedBox(height: 32),
                  
                  // Financial Planner
                  _buildFinancialPlanner(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.chevron_left, color: Color(0xFF0D1C44)),
          Column(
            children: const [
              Text('April 2026', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D1C44))),
              SizedBox(height: 2),
              Text('0 transaksi', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
            ],
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({required IconData icon, required Color iconColor, required Color iconBgColor, required String title, required String amount}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.w500))),
          Text(amount, style: const TextStyle(color: Color(0xFF0D1C44), fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9CA3AF), size: 18),
        ],
      ),
    );
  }

  Widget _buildSmallBalanceCard({required IconData icon, required Color iconColor, required Color iconBgColor, required String title, required String amount}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9CA3AF), size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(amount, style: const TextStyle(color: Color(0xFF0D1C44), fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildCashFlowCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.account_balance_wallet, color: Colors.green.shade600, size: 20),
              ),
              const Text('Cash Flow Bulan Ini', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('+Rp0', style: TextStyle(color: Color(0xFF0D1C44), fontWeight: FontWeight.w800, fontSize: 24)),
          const SizedBox(height: 4),
          const Text('0% dari pemasukan tersisa', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFinancialPlanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.auto_awesome, color: Colors.purple.shade400, size: 20),
                ),
                const SizedBox(width: 12),
                const Text('Financial Planner', style: TextStyle(color: Color(0xFF0D1C44), fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                const Text('👍', style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
          // Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTabItem(Icons.pie_chart, 'Overview', true),
                _buildTabItem(Icons.thumb_up_alt_outlined, 'Tips', false),
                _buildTabItem(Icons.rocket_launch_outlined, 'Roadmap', false),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Health Score Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F7FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade100, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Financial Health Score', style: TextStyle(color: Color(0xFF0D1C44), fontWeight: FontWeight.bold, fontSize: 15)),
                        SizedBox(height: 8),
                        Text('Bagus! Keuangan Anda dalam kondisi baik', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13, height: 1.4)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      const Text('75', style: TextStyle(color: Color(0xFF1E60FE), fontWeight: FontWeight.w800, fontSize: 32)),
                      const Text('/ 100', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
                      const SizedBox(height: 8),
                      Container(
                        width: 50,
                        height: 6,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(3)),
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 37.5,
                          height: 6,
                          decoration: BoxDecoration(color: const Color(0xFF1E60FE), borderRadius: BorderRadius.circular(3)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Debt Ratio / Expense place holders
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Debt Ratio', style: TextStyle(color: Color(0xFF0D1C44), fontWeight: FontWeight.w600, fontSize: 13)),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                          child: Icon(Icons.arrow_outward, color: Colors.green.shade600, size: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Expense', style: TextStyle(color: Color(0xFF0D1C44), fontWeight: FontWeight.w600, fontSize: 13)),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                          child: Icon(Icons.arrow_outward, color: Colors.green.shade600, size: 14),
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
    );
  }

  Widget _buildTabItem(IconData icon, String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: isActive
          ? BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            )
          : null,
      child: Column(
        children: [
          Icon(icon, color: isActive ? const Color(0xFF1E60FE) : const Color(0xFF9CA3AF), size: 20),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: isActive ? const Color(0xFF1E60FE) : const Color(0xFF9CA3AF), fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.w500)),
          if (isActive) ...[
            const SizedBox(height: 4),
            Container(width: 20, height: 2, decoration: BoxDecoration(color: const Color(0xFF1E60FE), borderRadius: BorderRadius.circular(1))),
          ]
        ],
      ),
    );
  }
}
