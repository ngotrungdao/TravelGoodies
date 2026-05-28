import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

class FileReader {
	static const String _countriesListPath =
			'assets/json/countries/countries_list.json';

	static Future<dynamic> readCountriesListJson() async {
		final String jsonString = await rootBundle.loadString(_countriesListPath);
		return jsonDecode(jsonString);
	}

	static Future<List<Map<String, dynamic>>> readCountriesList() async {
		final dynamic decodedJson = await readCountriesListJson();
		if (decodedJson is! List) {
			throw const FormatException('countries_list.json must contain a JSON list');
		}

		return decodedJson
				.map<Map<String, dynamic>>((dynamic item) {
					if (item is! Map<String, dynamic>) {
						throw const FormatException(
							'countries_list.json list items must be JSON objects',
						);
					}
					return item;
				})
				.toList(growable: false);
	}

	static Future<Map<String, dynamic>> getCurrencyData(String url) async {
    HttpClient httpClient = HttpClient();
    try {
      HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
      HttpClientResponse response = await request.close();
      if (response.statusCode == 200) {
				final String responseBody = await response.transform(utf8.decoder).join();
				final dynamic decodedJson = jsonDecode(responseBody);
				if (decodedJson is! Map<String, dynamic>) {
					throw const FormatException('Currency API response must be a JSON object');
				}
				return decodedJson;
      } else {
        throw HttpException('Failed to load JSON file: ${response.statusCode}');
      }
    } finally {
      httpClient.close();
    }
  }
}
