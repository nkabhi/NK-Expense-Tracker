import 'package:telephony/telephony.dart';
import 'package:uuid/uuid.dart';

import '../models/transaction.dart';
import 'db_helper.dart';
import 'sms_parser.dart';

class SmsService {
  final Telephony _telephony = Telephony.instance;
  static const _uuid = Uuid();

  Future<bool> requestPermission() async {
    final granted = await _telephony.requestSmsPermissions;
    return granted ?? false;
  }

  /// One-time scan of existing inbox on first setup, so the app doesn't
  /// start empty. Only parsed, structured fields are ever saved — the raw
  /// SMS body is read into memory to extract numbers, then discarded.
  Future<int> importExistingInbox() async {
    final messages = await _telephony.getInboxSms(
      columns: [SmsColumn.BODY, SmsColumn.DATE, SmsColumn.ADDRESS],
    );

    int imported = 0;
    for (final msg in messages) {
      final body = msg.body;
      if (body == null) continue;
      final parsed = SmsParser.tryParse(body);
      if (parsed == null) continue;

      final date = msg.date != null
          ? DateTime.fromMillisecondsSinceEpoch(msg.date!)
          : DateTime.now();

      await DbHelper.instance.insertTransaction(
        Transaction(
          id: _uuid.v4(),
          amount: parsed.amount,
          type: parsed.type,
          category: 'Uncategorized',
          note: parsed.guessedNote,
          source: TxnSource.sms,
          date: date,
          balanceAfter: parsed.balanceAfter,
        ),
      );
      imported++;
    }
    return imported;
  }

  /// Starts listening for new incoming SMS while the app is running, so
  /// new transactions are captured automatically without reopening the app.
  void startListening() {
    _telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) async {
        final body = message.body;
        if (body == null) return;
        final parsed = SmsParser.tryParse(body);
        if (parsed == null) return;

        await DbHelper.instance.insertTransaction(
          Transaction(
            id: _uuid.v4(),
            amount: parsed.amount,
            type: parsed.type,
            category: 'Uncategorized',
            note: parsed.guessedNote,
            source: TxnSource.sms,
            date: DateTime.now(),
            balanceAfter: parsed.balanceAfter,
          ),
        );
      },
      listenInBackground: false,
    );
  }
}
