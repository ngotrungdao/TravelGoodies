class Currency {
  final String code;
  final double valueOn1USD;
  final String symbol;

  Currency({
    required this.code,
    required this.valueOn1USD,
    required this.symbol,
  });

  @override
  String toString() {
    return '$symbol $code: $valueOn1USD';
  }
}
