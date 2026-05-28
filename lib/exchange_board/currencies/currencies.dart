import 'dart:convert';

import 'package:money_exchange/exchange_board/currencies/currency.dart';

class Currencies {
	Currencies._internal();

	static final Currencies _instance = Currencies._internal();

	factory Currencies() => _instance;

	String result = '';
	String documentation = '';
	String termsOfUse = '';
	int timeLastUpdateUnix = 0;
	String timeLastUpdateUtc = '';
	int timeNextUpdateUnix = 0;
	String timeNextUpdateUtc = '';
	String baseCode = '';
	Map<String, double> conversionRates = <String, double>{};
	List<Currency> currencies = <Currency>[];

	void loadFromJson(Map<String, dynamic> json) {
		result = json['result'] as String? ?? '';
		documentation = json['documentation'] as String? ?? '';
		termsOfUse = json['terms_of_use'] as String? ?? '';
		timeLastUpdateUnix = (json['time_last_update_unix'] as num?)?.toInt() ?? 0;
		timeLastUpdateUtc = json['time_last_update_utc'] as String? ?? '';
		timeNextUpdateUnix = (json['time_next_update_unix'] as num?)?.toInt() ?? 0;
		timeNextUpdateUtc = json['time_next_update_utc'] as String? ?? '';
		baseCode = json['base_code'] as String? ?? '';

		final Map<String, dynamic> ratesJson =
				(json['conversion_rates'] as Map<String, dynamic>?) ??
						<String, dynamic>{};

		conversionRates = ratesJson.map<String, double>((String code, dynamic rate) {
			return MapEntry(code, (rate as num).toDouble());
		});

		currencies = conversionRates.entries
				.map(
					(MapEntry<String, double> entry) => Currency(
						code: entry.key,
						valueOn1USD: entry.value,
					),
				)
				.toList(growable: false);
	}

	void loadFromJsonString(String jsonString) {
		final dynamic decodedJson = jsonDecode(jsonString);
		if (decodedJson is! Map<String, dynamic>) {
			throw const FormatException('Currency payload must be a JSON object');
		}

		loadFromJson(decodedJson);
	}

	double? rateOf(String currencyCode) {
		return conversionRates[currencyCode.toUpperCase()];
	}
}