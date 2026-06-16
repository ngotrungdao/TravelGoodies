import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:money_exchange/money_exchange/currency_choice_dialog/currency_choice_dialog.dart';
import 'package:money_exchange/money_exchange/exchange_board/countries/country.dart';
import 'package:money_exchange/money_exchange/math_expression/shunting_yard.dart';
import 'package:money_exchange/money_exchange/value_notifier/currency_model.dart';

class MoneyTextField extends StatefulWidget {
  const MoneyTextField({
    super.key,
    required this.initialValue,
    required this.enabled,
    required this.isInput,
    required this.textController,
  });
  final String initialValue;
  final bool enabled;
  final bool isInput;
  final TextEditingController textController;

  @override
  MoneyTextFieldState createState() => MoneyTextFieldState();
}

class MoneyTextFieldState extends State<MoneyTextField> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MoneyTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue &&
        widget.textController.text != widget.initialValue) {
      widget.textController.text = widget.initialValue;
    }
  }

  Future<void> _chooseCurrency({required bool isInput}) async {
    final Country? country = await showCurrencyChoiceDialog(context);
    if (country == null) {
      return;
    }

    if (isInput) {
      CurrencyController().update(inputCountry: country);
    } else {
      CurrencyController().update(outputCountry: country);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CurrencyController(),
      builder: (context, w) {
        Country currentCountry = widget.isInput
            ? CurrencyController().inputCountry
            : CurrencyController().outputCountry;
        if (!widget.isInput) {
          widget.textController.text = CurrencyController().outputAmount;
        }

        String? helperText;
        if (widget.isInput) {
          final input = CurrencyController().inputAmount;
          if (input.trim().isNotEmpty) {
            try {
              helperText = ShuntingYard.evaluate(input).toString();
            } catch (_) {
              helperText = 'vui lòng nhập số tiền hợp lệ';
            }
          } else {
            helperText = 'nhập số tiền cần quy đổi';
          }
        } else {
          helperText = '';
        }
        return Card(
          elevation: 4,
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        _chooseCurrency(isInput: widget.isInput);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: SvgPicture.asset(
                                  'assets/images/countries_flags/svg/${currentCountry.alpha2Code.toLowerCase()}.svg',
                                  fit: BoxFit.cover,
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              currentCountry.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "đơn vị: ",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${currentCountry.currencyName.toUpperCase()} (${currentCountry.currencySymbol})',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: TextFormField(
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    overflow: TextOverflow.visible,
                                  ),
                              controller: widget.textController,
                              keyboardType: TextInputType.number,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                isCollapsed: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 12,
                                ),
                                border: InputBorder.none,
                                suffixIcon:
                                    widget.enabled &&
                                        widget.textController.text.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          widget.textController.clear();
                                          if (widget.isInput) {
                                            CurrencyController().update(
                                              amount: '',
                                            );
                                          }
                                        },
                                        icon: const Icon(Icons.clear, size: 20),
                                      )
                                    : null,
                                suffixText: currentCountry.currencySymbol,
                                suffixStyle: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              autofocus: widget.isInput,
                              enabled: widget.enabled,
                              onChanged: (value) {
                                if (widget.isInput) {
                                  CurrencyController().update(amount: value);
                                }
                              },
                              onFieldSubmitted: (value) {
                                if (widget.isInput) {
                                  CurrencyController().update(amount: value);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (helperText.isNotEmpty)
                  Text(
                    "= $helperText ${currentCountry.currencyCode}",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
