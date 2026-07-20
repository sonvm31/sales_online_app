import 'package:intl/intl.dart';

/// Formats monetary values consistently for the Vietnamese UI.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _vndFormat = NumberFormat('#,##0', 'vi_VN');

  static String vnd(num value) => '${_vndFormat.format(value)}đ';
}
