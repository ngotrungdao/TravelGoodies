import 'package:money_exchange/money_exchange/exchange_board/countries/country.dart';

class Countries {
  Countries._internal();

  static final Countries _instance = Countries._internal();

  factory Countries() => _instance;

  List<Country> countries = [];

  List<Country> getCountriesFromJsonList(List<Map<String, dynamic>> jsonList) {
    if (jsonList.isNotEmpty) {
      countries = jsonList.map((json) => Country.fromJson(json)).toList();
    }
    return countries;
  }
}
