import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/transaction.dart';
import '../services/db_helper.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});
  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  TxnType _type = TxnType.expense;
  String _category = 'Supplies';
  DateTime _date = DateTime.now();

  final _categories = const [
    'Rent', 'Salaries', 'Supplies', 'Utilities', 'Marketing', 'Travel', 'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add transaction')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<TxnType>(
                segments: const [
                  ButtonSegment(value: TxnType.expense, label: Text('Expense')),
                  ButtonSegment(value: TxnType.income, label: Text('Income')),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder()),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter an amount';
                  if (double.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(labelText: 'Note (optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text('${_date.day}/${_date.month}/${_date.year}'),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Save transaction'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final txn = Transaction(
      id: const Uuid().v4(),
      amount: double.parse(_amountCtrl.text),
      type: _type,
      category: _category,
      note: _noteCtrl.text,
      source: TxnSource.manual,
      date: _date,
    );
    await DbHelper.instance.insertTransaction(txn);
    if (!mounted) return;
    _amountCtrl.clear();
    _noteCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction saved')),
    );
  }
}
