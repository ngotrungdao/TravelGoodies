import 'package:flutter/widgets.dart';
import 'package:money_exchange/exchange_board/currencies/currencies.dart';

class CurrencyController extends ChangeNotifier {
  CurrencyController._internal();

  static final CurrencyController _instance = CurrencyController._internal();

  factory CurrencyController() => _instance;

  String inputCurrency = 'USD';
  String outputCurrency = 'VND';
  String inputAmount = '1';
  String outputAmount = '23 000';
  String inputCountryCode = 'us';
  String outputCountryCode = 'vn';
  String inputCurrencyRate = '1';
  String outputCurrencyRate = '23 000';

  double _parseAmount(String value) {
    //String normalized = value.trim().replaceAll(' ', '').replaceAll('.', '');
    //
    //if (normalized.contains(',')) {
    //  // Treat comma as decimal separator and dot as thousands separator.
    //  normalized = normalized.replaceAll('.', '').replaceAll(',', '.');
    //} else {
    //  // If dots are used only as grouped thousands separators, remove them.
    //  final groupedThousandsRegex = RegExp(r'^\d{1,3}(\.\d{3})+$');
    //  if (groupedThousandsRegex.hasMatch(normalized)) {
    //    normalized = normalized.replaceAll('.', '');
    //  }
    //}

    return double.tryParse(value) ?? 0;
  }

  String _formatAmount(double value) {
    final bool isNegative = value < 0;
    final double absolute = value.abs();
    final String fixed = absolute.toStringAsFixed(2);
    final List<String> parts = fixed.split('.');
    final String integerPart = parts[0];
    final String decimalPart = parts[1];

    final StringBuffer grouped = StringBuffer();
    for (int i = 0; i < integerPart.length; i++) {
      final int indexFromRight = integerPart.length - i;
      grouped.write(integerPart[i]);
      if (indexFromRight > 1 && indexFromRight % 3 == 1) {
        grouped.write(' ');
      }
    }

    final String sign = isNegative ? '-' : '';
    if (decimalPart == '00') {
      return '$sign${grouped.toString()}';
    }

    return '$sign${grouped.toString()}.$decimalPart';
  }

  void update({
    String? inputCurrency,
    String? outputCurrency,
    String? amount,
    String? inputCountryCode,
    String? outputCountryCode,
  }) {
    if (inputCurrency != null) {
      this.inputCurrency = inputCurrency;
    }
    if (outputCurrency != null) {
      this.outputCurrency = outputCurrency;
    }
    if (inputCountryCode != null) {
      this.inputCountryCode = inputCountryCode;
    }
    if (outputCountryCode != null) {
      this.outputCountryCode = outputCountryCode;
    }

    if (amount != null) {
      inputAmount = amount;
    }

    double? inputRate = Currencies().rateOf(this.inputCurrency);
    double? outputRate = Currencies().rateOf(this.outputCurrency);
    if (inputRate != null && outputRate != null) {
      double inputAmountDouble = _parseAmount(inputAmount);
      double outputAmountDouble = inputAmountDouble * (outputRate / inputRate);
      outputAmount = _formatAmount(outputAmountDouble);
      inputCurrencyRate = '1';
      outputCurrencyRate = _formatAmount(outputRate / inputRate);
    } else {
      outputAmount = '0';
    }

    notifyListeners();
  }
}
