import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/transaction.dart';
import '../services/db_helper.dart';
import '../theme.dart';

class InvestmentsScreen extends StatefulWidget {
  const InvestmentsScreen({super.key});
  @override
  State<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends State<InvestmentsScreen> {
  List<Investment> _investments = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final inv = await DbHelper.instance.getInvestments();
    setState(() => _investments = inv);
  }

  Future<void> _showAddDialog() async {
    final nameCtrl = TextEditingController();
    final investedCtrl = TextEditingController();
    final currentCtrl = TextEditingController();
    String kind = 'SIP';

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add investment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: kind,
              items: const ['SIP', 'PPF', 'FD', 'Stocks', 'Other']
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (v) => kind = v ?? kind,
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            TextField(
              controller: investedCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount invested (₹)'),
            ),
            TextField(
              controller: currentCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Current value (₹)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final invested = double.tryParse(investedCtrl.text) ?? 0;
              final current = double.tryParse(currentCtrl.text) ?? 0;
              if (nameCtrl.text.isEmpty) return;
              await DbHelper.instance.upsertInvestment(Investment(
                id: const Uuid().v4(),
                name: nameCtrl.text,
                kind: kind,
                invested: invested,
                currentValue: current,
                lastUpdated: DateTime.now(),
              ));
              if (ctx.mounted) Navigator.pop(ctx);
              _load();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final totalInvested = _investments.fold(0.0, (s, i) => s + i.invested);
    final totalCurrent = _investments.fold(0.0, (s, i) => s + i.currentValue);

    return Scaffold(
      appBar: AppBar(title: const Text('Investments')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total invested', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                        Text(fmt.format(totalInvested), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Current value', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                        Text(fmt.format(totalCurrent),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: totalCurrent >= totalInvested ? AppColors.income : AppColors.expense)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_investments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text('No investments added yet. Values update manually.')),
            ),
          ..._investments.map((inv) => Card(
                child: ListTile(
                  title: Text(inv.name),
                  subtitle: Text('${inv.kind} · updated ${DateFormat.yMMMd().format(inv.lastUpdated)}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(fmt.format(inv.currentValue), style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        '${inv.returnPct >= 0 ? "+" : ""}${inv.returnPct.toStringAsFixed(1)}%',
                        style: TextStyle(
                            fontSize: 12,
                            color: inv.returnPct >= 0 ? AppColors.income : AppColors.expense),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
