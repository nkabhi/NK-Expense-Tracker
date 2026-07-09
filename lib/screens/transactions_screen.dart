import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import '../services/db_helper.dart';
import '../theme.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});
  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<Transaction> _txns = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final txns = await DbHelper.instance.getTransactions();
    setState(() => _txns = txns);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: _txns.isEmpty
          ? const Center(child: Text('No transactions yet'))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _txns.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final t = _txns[i];
                  final isExpense = t.type == TxnType.expense;
                  return Dismissible(
                    key: ValueKey(t.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: AppColors.expense.withValues(alpha: 0.15),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete_outline, color: AppColors.expense),
                    ),
                    onDismissed: (_) async {
                      await DbHelper.instance.deleteTransaction(t.id);
                      setState(() => _txns.removeAt(i));
                    },
                    child: ListTile(
                      title: Text(t.note.isEmpty ? t.category : t.note),
                      subtitle: Text(
                        '${t.category} · ${t.source == TxnSource.sms ? "SMS" : "Manual"} · ${DateFormat.yMMMd().add_jm().format(t.date)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Text(
                        '${isExpense ? "-" : "+"}${fmt.format(t.amount)}',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                          color: isExpense ? AppColors.expense : AppColors.income,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
