import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static final NumberFormat _numberFormat = NumberFormat.decimalPattern('pt_BR');

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  /// Formata valor monetário (ex: R$ 1.250,50)
  static String formatCurrency(double value) {
    return _currencyFormat.format(value);
  }

  /// Formata moeda compacta (ex: R$ 318 mil)
  static String formatCurrencyCompact(double value) {
    if (value >= 1000000) {
      return 'R\$ ${(value / 1000000).toStringAsFixed(1).replaceAll('.', ',')} mi';
    } else if (value >= 1000) {
      return 'R\$ ${(value / 1000).toStringAsFixed(0)} mil';
    }
    return formatCurrency(value);
  }

  static String formatCompactCurrency(double value) => formatCurrencyCompact(value);

  /// Formata número decimal ou inteiro (ex: 1.240)
  static String formatNumber(num value, {int decimalDigits = 0}) {
    if (decimalDigits > 0) {
      return value.toStringAsFixed(decimalDigits).replaceAll('.', ',');
    }
    return _numberFormat.format(value);
  }

  /// Formata data (ex: 14/10/2026)
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Formata data e hora
  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  /// Formata percentual (ex: +28,4%)
  static String formatPercent(double value, {bool includeSign = false}) {
    final prefix = (includeSign && value > 0) ? '+' : '';
    return '$prefix${value.toStringAsFixed(1).replaceAll('.', ',')}%';
  }
}
