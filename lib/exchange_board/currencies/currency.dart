class Currency{
  final String code;
  final double valueOn1USD;

  Currency({
    required this.code,
    required this.valueOn1USD,
  });
  
  @override
  String toString() {
    return '$code: $valueOn1USD';
  }
}