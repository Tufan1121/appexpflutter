import 'package:intl/intl.dart';

class Utils {
    static String formatPrice(double price) {
    final NumberFormat formatter =
        NumberFormat.currency(locale: 'en_US', symbol: '\$');
    return formatter.format(price);
  }
}