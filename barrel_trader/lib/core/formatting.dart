import 'package:intl/intl.dart';

/// Shared number/price/date formatting helpers.
class Fmt {
  static final NumberFormat _money0 = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 0,
  );
  static final NumberFormat _money2 = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );
  static final NumberFormat _compact = NumberFormat.compactCurrency(
    symbol: '\$',
    decimalDigits: 1,
  );

  /// Currency with no decimals, e.g. "$100,000".
  static String money0(num v) => _money0.format(v);

  /// Currency with two decimals, e.g. "$1,234.56".
  static String money2(num v) => _money2.format(v);

  /// Compact currency for large balances, e.g. "$1.2M".
  static String compactMoney(num v) => _compact.format(v);

  /// Signed currency, e.g. "+$120.50" / "-$40.00".
  static String signedMoney(num v) {
    final sign = v > 0 ? '+' : (v < 0 ? '-' : '');
    return '$sign${_money2.format(v.abs())}';
  }

  /// Signed percentage, e.g. "+1.24%".
  static String signedPercent(num v) {
    final sign = v > 0 ? '+' : (v < 0 ? '-' : '');
    return '$sign${v.abs().toStringAsFixed(2)}%';
  }

  /// A price with the right number of decimals for its tick size.
  static String price(num value, double tickSize) {
    final decimals = _decimalsFor(tickSize);
    return NumberFormat.decimalPatternDigits(decimalDigits: decimals)
        .format(value);
  }

  static int _decimalsFor(double tickSize) {
    if (tickSize >= 1) return 0;
    if (tickSize >= 0.01) return 2;
    if (tickSize >= 0.001) return 3;
    return 4;
  }

  /// Compact lot count, e.g. "3" or "1.5".
  static String lots(num v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  static String timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inSeconds < 60) return '${d.inSeconds}s ago';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  static String dateTime(DateTime t) => DateFormat('MMM d, HH:mm').format(t);
}
