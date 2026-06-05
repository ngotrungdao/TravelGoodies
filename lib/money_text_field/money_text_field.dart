import 'package:flutter/material.dart';

class MoneyTextField extends StatefulWidget {
  const MoneyTextField({
    super.key,
    this.labelText = 'Nhập số tiền',
    required this.countriesCode,
    required this.initialValue,
    required this.enabled,
  });
  final String labelText;
  final String initialValue;
  final String countriesCode;
  final bool enabled;

  @override
  MoneyTextFieldState createState() => MoneyTextFieldState();
}

class MoneyTextFieldState extends State<MoneyTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextFormField(
                style: Theme.of(context).textTheme.headlineMedium,
                controller: _controller,
                keyboardType: TextInputType.number,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  labelText: widget.labelText,
                  labelStyle: Theme.of(context).textTheme.labelLarge,
                  isCollapsed: false,
                  contentPadding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                ),
                enabled: widget.enabled,
              ),
            ),
            SizedBox(
              width: 32,
              height: 32,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 3,
                  ),
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/countries_flags/256x192/${widget.countriesCode}.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
