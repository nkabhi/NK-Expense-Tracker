import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import '../services/db_helper.dart';
import '../theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Transaction> _thisMonth = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final txns = await DbHelper.instance.getTransactionsBetween(start, end);
    setState(() {
      _thisMonth = txns;
      _loading = false;
    });
  }

  double get _income => _thisMonth
      .where((t) => t.type == TxnType.income)
      .fold(0.0, (s, t) => s + t.amount);

  double get _expense => _thisMonth
      .where((t) => t.type == TxnType.expense)
      .fold(0.0, (s, t) => s + t.amount);

  Map<String, double> get _byCategory {
    final map = <String, double>{};
    for (final t in _thisMonth.where((t) => t.type == TxnType.expense)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final profit = _income - _expense;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('This month', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              _statCard('Income', fmt.format(_income), AppColors.income),
              const SizedBox(width: 8),
              _statCard('Expenses', fmt.format(_expense), AppColors.expense),
              const SizedBox(width: 8),
              _statCard('Profit', fmt.format(profit),
                  profit >= 0 ? AppColors.income : AppColors.expense),
            ],
          ),
          const SizedBox(height: 24),
          Text('Expense by category', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: _byCategory.isEmpty
                ? const Center(child: Text('No expenses logged yet'))
                : _CategoryBarChart(data: _byCategory, formatter: fmt),
          ),
          const SizedBox(height: 24),
          Text('Recent transactions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ..._thisMonth.take(6).map((t) => _txnTile(t, fmt)),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _txnTile(Transaction t, NumberFormat fmt) {
    final isExpense = t.type == TxnType.expense;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: (isExpense ? AppColors.expense : AppColors.income)
            .withValues(alpha: 0.12),
        child: Icon(
          isExpense ? Icons.arrow_upward : Icons.arrow_downward,
          color: isExpense ? AppColors.expense : AppColors.income,
          size: 18,
        ),
      ),
      title: Text(t.note.isEmpty ? t.category : t.note, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        '${t.source == TxnSource.sms ? "Auto-read from SMS" : "Added manually"} · ${DateFormat.MMMd().format(t.date)}',
        style: const TextStyle(fontSize: 11, color: AppColors.muted),
      ),
      trailing: Text(
        '${isExpense ? "-" : "+"}${fmt.format(t.amount)}',
        style: TextStyle(
            fontFamily: 'monospace',
            color: isExpense ? AppColors.expense : AppColors.income,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _CategoryBarChart extends StatelessWidget {
  final Map<String, double> data;
  final NumberFormat formatter;
  const _CategoryBarChart({required this.data, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(6).toList();
    final maxVal = top.first.value;

    return BarChart(
      BarChartData(
        maxY: maxVal * 1.2,
        barGroups: [
          for (int i = 0; i < top.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: top[i].value,
                color: AppColors.accent,
                width: 18,
                borderRadius: BorderRadius.circular(4),
              ),
            ]),
        ],
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= top.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(top[i].key,
                      style: const TextStyle(fontSize: 10, color: AppColors.muted)),
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
