import 'package:flutter/widgets.dart';
import 'package:money_exchange/money_exchange/exchange_board/countries/countries.dart';
import 'package:money_exchange/money_exchange/exchange_board/countries/country.dart';
import 'package:money_exchange/money_exchange/exchange_board/currencies/currencies.dart';
import 'package:money_exchange/money_exchange/math_expression/shunting_yard.dart';

class CurrencyController extends ChangeNotifier {
  CurrencyController._internal();

  static final CurrencyController _instance = CurrencyController._internal();

  factory CurrencyController() {
    return _instance;
  }

  Country inputCountry = Countries().countries.firstWhere(
    (country) => country.alpha2Code.toLowerCase() == 'us',
  );
  Country outputCountry = Countries().countries.firstWhere(
    (country) => country.alpha2Code.toLowerCase() == 'vn',
  );

  String inputAmount = '0';
  String outputAmount = '0';

  double _parseAmount(String value) {
    try {
      return ShuntingYard.evaluate(value.replaceAll(' ', ''));
    } catch (e) {
      return 0;
    }
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

  void update({Country? inputCountry, Country? outputCountry, String? amount}) {
    if (inputCountry != null) {
      this.inputCountry = inputCountry;
    }
    if (outputCountry != null) {
      this.outputCountry = outputCountry;
    }

    if (amount != null) {
      inputAmount = amount;
    }

    double? inputRate = Currencies().rateOf(this.inputCountry.currencyCode);
    double? outputRate = Currencies().rateOf(this.outputCountry.currencyCode);
    if (inputRate != null && outputRate != null) {
      double inputAmountDouble = _parseAmount(inputAmount);
      double outputAmountDouble = inputAmountDouble * (outputRate / inputRate);
      outputAmount = _formatAmount(outputAmountDouble);
    } else {
      outputAmount = '0';
    }
    notifyListeners();
  }
}
