import 'dart:math' as math;

enum _TokenType { number, operator, function, leftParen, rightParen, comma }

class _Token {
  final _TokenType type;
  final String value;

  const _Token(this.type, this.value);
}

class _OperatorInfo {
  final int precedence;
  final bool leftAssociative;

  const _OperatorInfo(this.precedence, this.leftAssociative);
}

class ShuntingYard {
  static const Map<String, _OperatorInfo> _operators = {
    '+': _OperatorInfo(2, true),
    '-': _OperatorInfo(2, true),
    '*': _OperatorInfo(3, true),
    '/': _OperatorInfo(3, true),
    '^': _OperatorInfo(4, false),
  };

  // Unary minus ('neg') binds tighter than the binary operators (+ - * /) but
  // looser than '^', so that -3+2 == -1 while -3^2 == -9.
  static const int _unaryMinusPrecedence = 3;

  static final Map<String, double Function(double)> _functions = {
    'sin': math.sin,
    'cos': math.cos,
    'tan': math.tan,
    'sqrt': math.sqrt,
    'abs': (x) => x.abs(),
    'ln': math.log,
    'log10': (x) => math.log(x) / math.ln10,
  };

  static double evaluate(String expression) {
    final tokens = _tokenize(expression);
    final rpn = _toRpn(tokens);
    return _evaluateRpn(rpn);
  }

  static List<_Token> _toRpn(List<_Token> tokens) {
    final output = <_Token>[];
    final stack = <_Token>[];

    for (final token in tokens) {
      switch (token.type) {
        case _TokenType.number:
          output.add(token);
          break;

        case _TokenType.function:
          stack.add(token);
          break;

        case _TokenType.operator:
          final o1 = _operators[token.value]!;

          while (stack.isNotEmpty) {
            final top = stack.last;

            int topPrecedence;

            if (top.type == _TokenType.operator) {
              topPrecedence = _operators[top.value]!.precedence;
            } else if (top.type == _TokenType.function && top.value == 'neg') {
              // Unary minus is a prefix (right-associative) operator.
              topPrecedence = _unaryMinusPrecedence;
            } else {
              break;
            }

            final shouldPop =
                topPrecedence > o1.precedence ||
                (o1.leftAssociative && o1.precedence == topPrecedence);

            if (!shouldPop) {
              break;
            }

            output.add(stack.removeLast());
          }

          stack.add(token);
          break;

        case _TokenType.comma:
          while (stack.isNotEmpty && stack.last.type != _TokenType.leftParen) {
            output.add(stack.removeLast());
          }

          if (stack.isEmpty) {
            throw FormatException('Misplaced comma');
          }

          break;

        case _TokenType.leftParen:
          stack.add(token);
          break;

        case _TokenType.rightParen:
          while (stack.isNotEmpty && stack.last.type != _TokenType.leftParen) {
            output.add(stack.removeLast());
          }

          if (stack.isEmpty) {
            throw FormatException('Mismatched parentheses');
          }

          stack.removeLast();

          if (stack.isNotEmpty && stack.last.type == _TokenType.function) {
            output.add(stack.removeLast());
          }

          break;
      }
    }

    while (stack.isNotEmpty) {
      final token = stack.removeLast();

      if (token.type == _TokenType.leftParen ||
          token.type == _TokenType.rightParen) {
        throw FormatException('Mismatched parentheses');
      }

      output.add(token);
    }

    return output;
  }

  static List<_Token> _tokenize(String input) {
    final tokens = <_Token>[];
    int i = 0;

    while (i < input.length) {
      final ch = input[i];

      if (ch.trim().isEmpty) {
        i++;
        continue;
      }

      if (RegExp(r'[0-9.]').hasMatch(ch)) {
        final start = i;
        var hasDot = ch == '.';
        i++;

        while (i < input.length) {
          final c = input[i];

          if (c == '.') {
            if (hasDot) {
              throw FormatException('Invalid number near position $i');
            }

            hasDot = true;
            i++;
            continue;
          }

          if (!RegExp(r'[0-9]').hasMatch(c)) {
            break;
          }

          i++;
        }

        tokens.add(_Token(_TokenType.number, input.substring(start, i)));
        continue;
      }

      if (RegExp(r'[A-Za-z_]').hasMatch(ch)) {
        final start = i;
        i++;

        while (i < input.length && RegExp(r'[A-Za-z0-9_]').hasMatch(input[i])) {
          i++;
        }

        final name = input.substring(start, i);
        int j = i;
        while (j < input.length && input[j].trim().isEmpty) {
          j++;
        }

        if (j < input.length && input[j] == '(') {
          tokens.add(_Token(_TokenType.function, name.toLowerCase()));
        } else {
          throw FormatException(
            'Unknown identifier "$name" at position $start. Only function calls are supported.',
          );
        }

        continue;
      }

      if ('+-*/^'.contains(ch)) {
        final unary =
            ch == '-' &&
            (tokens.isEmpty ||
                tokens.last.type == _TokenType.operator ||
                tokens.last.type == _TokenType.function ||
                tokens.last.type == _TokenType.leftParen ||
                tokens.last.type == _TokenType.comma);

        if (unary) {
          tokens.add(const _Token(_TokenType.function, 'neg'));
        } else {
          tokens.add(_Token(_TokenType.operator, ch));
        }

        i++;
        continue;
      }

      if (ch == '(') {
        tokens.add(_Token(_TokenType.leftParen, ch));
        i++;
        continue;
      }

      if (ch == ')') {
        tokens.add(_Token(_TokenType.rightParen, ch));
        i++;
        continue;
      }

      if (ch == ',') {
        tokens.add(_Token(_TokenType.comma, ch));
        i++;
        continue;
      }

      throw FormatException('Unexpected character "$ch" at $i');
    }

    return tokens;
  }

  static double _evaluateRpn(List<_Token> rpn) {
    final stack = <double>[];

    for (final token in rpn) {
      switch (token.type) {
        case _TokenType.number:
          stack.add(double.parse(token.value));
          break;

        case _TokenType.operator:
          if (stack.length < 2) {
            throw FormatException('Invalid expression: missing operand(s)');
          }

          final right = stack.removeLast();
          final left = stack.removeLast();

          switch (token.value) {
            case '+':
              stack.add(left + right);
              break;
            case '-':
              stack.add(left - right);
              break;
            case '*':
              stack.add(left * right);
              break;
            case '/':
              stack.add(left / right);
              break;
            case '^':
              stack.add(math.pow(left, right).toDouble());
              break;
            default:
              throw FormatException('Unknown operator ${token.value}');
          }

          break;

        case _TokenType.function:
          if (stack.isEmpty) {
            throw FormatException(
              'Invalid expression: missing function argument',
            );
          }

          final value = stack.removeLast();

          if (token.value == 'neg') {
            stack.add(-value);
            break;
          }

          final fn = _functions[token.value];
          if (fn == null) {
            throw FormatException('Unknown function ${token.value}');
          }

          stack.add(fn(value));
          break;

        case _TokenType.leftParen:
        case _TokenType.rightParen:
        case _TokenType.comma:
          throw FormatException('Invalid expression');
      }
    }

    if (stack.length != 1) {
      throw FormatException('Invalid expression');
    }

    return stack.single;
  }
}
