import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/customer_repository.dart';
import '../../models/customer.dart';
import '../../widgets/money_text.dart';
import 'customer_form_screen.dart';
import 'customer_detail_screen.dart';

/// Danh sách khách hàng, ưu tiên hiển thị khách còn nợ lên trước.
class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  String _query = '';
  int _refreshKey = 0;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<CustomerRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text('Khách hàng')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(hintText: 'Tìm theo tên hoặc SĐT', prefixIcon: Icon(Icons.search, size: 20)),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Customer>>(
              key: ValueKey(_refreshKey),
              future: repo.getAll(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var customers = List<Customer>.from(snapshot.data!);
                if (_query.isNotEmpty) {
                  customers = customers
                      .where((c) => c.name.toLowerCase().contains(_query) || c.phone.contains(_query))
                      .toList();
                }
                customers.sort((a, b) => b.totalDebt.compareTo(a.totalDebt)); // nợ nhiều lên trước

                if (customers.isEmpty) {
                  return const Center(child: Text('Chưa có khách hàng nào', style: TextStyle(color: AppColors.textSecondary)));
                }

                final totalDebt = customers.fold<double>(0, (sum, c) => sum + c.totalDebt);
                final debtorCount = customers.where((c) => c.totalDebt > 0).length;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Tổng công nợ', style: TextStyle(fontSize: 11, color: AppColors.warning)),
                                MoneyText(totalDebt, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.warning)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppColors.surfaceCard, border: Border.all(color: AppColors.border, width: 0.5), borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Khách còn nợ', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                Text('$debtorCount người', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...customers.map((c) {
                      final initials = c.name.isNotEmpty ? c.name.trim().split(' ').map((s) => s[0]).take(2).join().toUpperCase() : '?';
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(backgroundColor: AppColors.primaryLight, child: Text(initials, style: const TextStyle(color: AppColors.primaryDark, fontSize: 12, fontWeight: FontWeight.w600))),
                          title: Text(c.name),
                          subtitle: Text(c.phone, style: const TextStyle(fontSize: 12)),
                          trailing: c.totalDebt > 0
                              ? MoneyText(c.totalDebt, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.warning))
                              : const Text('Không nợ', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          onTap: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerDetailScreen(customer: c)));
                            setState(() => _refreshKey++);
                          },
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final changed = await Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerFormScreen()));
          if (changed == true) setState(() => _refreshKey++);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
