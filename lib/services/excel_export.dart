import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/transaction.dart';

class ExcelExportService {
  Future<File> exportTransactions(List<Transaction> txns) async {
    final excel = Excel.createExcel();
    final sheet = excel['Transactions'];
    excel.setDefaultSheet('Transactions');

    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Type'),
      TextCellValue('Category'),
      TextCellValue('Note'),
      TextCellValue('Source'),
      TextCellValue('Amount (INR)'),
      TextCellValue('Balance after'),
    ]);

    for (final t in txns) {
      sheet.appendRow([
        TextCellValue(t.date.toIso8601String().split('T').first),
        TextCellValue(t.type.name),
        TextCellValue(t.category),
        TextCellValue(t.note),
        TextCellValue(t.source.name),
        DoubleCellValue(t.amount),
        t.balanceAfter == null ? TextCellValue('') : DoubleCellValue(t.balanceAfter!),
      ]);
    }

    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/expense_report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File(path);
    final bytes = excel.encode();
    await file.writeAsBytes(bytes!);
    return file;
  }

  Future<void> shareFile(File file) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: 'Expense report'),
    );
  }
}
