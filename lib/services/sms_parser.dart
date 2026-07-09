import '../models/transaction.dart';

class ParsedSms {
  final double amount;
  final TxnType type;
  final double? balanceAfter;
  final String guessedNote;

  ParsedSms({
    required this.amount,
    required this.type,
    this.balanceAfter,
    required this.guessedNote,
  });
}

/// Best-effort parser for common Indian bank transaction SMS wording.
/// Real bank SMS formats vary a lot and change over time, so this is a
/// starting point, not a finished product — it should be tuned against
/// actual messages from your bank(s) and always leaves a manual-edit path
/// for anything it gets wrong or can't parse.
class SmsParser {
  static final _amountRegex = RegExp(
    r'(?:Rs\.?|INR|₹)\s?([0-9,]+(?:\.[0-9]{1,2})?)',
    caseSensitive: false,
  );

  static final _balanceRegex = RegExp(
    r'(?:Avl\s?Bal|Available\s?Balance|Bal)\s?:?\s?(?:Rs\.?|INR|₹)?\s?([0-9,]+(?:\.[0-9]{1,2})?)',
    caseSensitive: false,
  );

  static final _debitWords = RegExp(
    r'\b(debited|spent|withdrawn|paid|purchase of|debit)\b',
    caseSensitive: false,
  );

  static final _creditWords = RegExp(
    r'\b(credited|received|deposit|credit)\b',
    caseSensitive: false,
  );

  /// Returns null if the message doesn't look like a bank transaction alert
  /// at all (promotional SMS, OTPs, etc. are deliberately ignored).
  static ParsedSms? tryParse(String body) {
    final amountMatch = _amountRegex.firstMatch(body);
    if (amountMatch == null) return null;

    final isDebit = _debitWords.hasMatch(body);
    final isCredit = _creditWords.hasMatch(body);
    if (!isDebit && !isCredit) return null; // not a transaction alert

    final amountStr = amountMatch.group(1)!.replaceAll(',', '');
    final amount = double.tryParse(amountStr);
    if (amount == null) return null;

    double? balance;
    final balMatch = _balanceRegex.firstMatch(body);
    if (balMatch != null) {
      balance = double.tryParse(balMatch.group(1)!.replaceAll(',', ''));
    }

    return ParsedSms(
      amount: amount,
      type: isDebit ? TxnType.expense : TxnType.income,
      balanceAfter: balance,
      guessedNote: isDebit ? 'Bank debit (SMS)' : 'Bank credit (SMS)',
    );
  }
}
