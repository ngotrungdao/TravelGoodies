class Country {
  const Country({
    required this.name,
    required this.alpha2Code,
    required this.currencyName,
    required this.currencyCode,
    required this.currencySymbol,
    required this.flagIcon,
    required this.capital,
    required this.continent,
    required this.population,
  });

  final String name;
  final String alpha2Code;
  final String currencyName;
  final String currencyCode;
  final String currencySymbol;
  final String flagIcon;
  final String capital;
  final String continent;
  final int population;

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'] as String,
      alpha2Code: json['alpha2code'] as String,
      currencyName: json['currency_name'] as String,
      currencyCode: json['currency_code'] as String,
      currencySymbol:
          json['currency_symbol'] as String? ?? json['currency_code'] as String,
      flagIcon: json['flag_icon'] as String,
      capital: json['capital'] as String,
      continent: json['continent'] as String,
      population: (json['population'] as num).toInt(),
    );
  }
}
