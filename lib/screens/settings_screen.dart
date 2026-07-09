import 'package:flutter/material.dart';

import '../services/db_helper.dart';
import '../services/excel_export.dart';
import '../services/sms_service.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _smsService = SmsService();
  bool _importing = false;
  String? _status;

  Future<void> _setupSms() async {
    setState(() => _status = 'Requesting SMS permission...');
    final granted = await _smsService.requestPermission();
    if (!granted) {
      setState(() => _status = 'Permission denied. You can still add transactions manually.');
      return;
    }
    setState(() {
      _importing = true;
      _status = 'Scanning existing messages...';
    });
    final count = await _smsService.importExistingInbox();
    _smsService.startListening();
    setState(() {
      _importing = false;
      _status = 'Imported $count transactions from SMS. New messages will be captured automatically.';
    });
  }

  Future<void> _exportExcel() async {
    setState(() => _status = 'Building report...');
    final txns = await DbHelper.instance.getTransactions();
    final export = ExcelExportService();
    final file = await export.exportTransactions(txns);
    await export.shareFile(file);
    setState(() => _status = 'Report ready to save or share.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lock_outline, size: 18, color: AppColors.income),
                      SizedBox(width: 8),
                      Text('This app has no internet permission', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'All data stays on this device in an encrypted database. Nothing is uploaded, and nothing outside this app can connect to it.',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            tileColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const Icon(Icons.sms_outlined),
            title: const Text('Set up SMS auto-capture'),
            subtitle: const Text('Reads bank transaction alerts to log expenses and income automatically'),
            trailing: _importing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.chevron_right),
            onTap: _importing ? null : _setupSms,
          ),
          const SizedBox(height: 8),
          ListTile(
            tileColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('Export report to Excel'),
            subtitle: const Text('Generates an .xlsx file you can save or share'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _exportExcel,
          ),
          if (_status != null) ...[
            const SizedBox(height: 16),
            Text(_status!, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          ],
        ],
      ),
    );
  }
}
