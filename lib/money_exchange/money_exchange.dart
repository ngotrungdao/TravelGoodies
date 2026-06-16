import 'package:flutter/material.dart';
import 'package:money_exchange/file_reader/file_reader.dart';
import 'package:money_exchange/money_exchange/exchange_board/currencies/currencies.dart';
import 'package:money_exchange/money_exchange/money_text_field/money_text_field.dart';
import 'package:money_exchange/money_exchange/value_notifier/currency_model.dart';

class MoneyExchange extends StatefulWidget {
  const MoneyExchange({super.key, required this.title});

  final String title;

  @override
  State<MoneyExchange> createState() => _MoneyExchangeState();
}

class _MoneyExchangeState extends State<MoneyExchange> {
  late final Future<Map<String, dynamic>> _currencyDataFuture;
  TextEditingController inputController = TextEditingController(
    text: CurrencyController().inputAmount,
  );
  TextEditingController outputController = TextEditingController(
    text: CurrencyController().outputAmount,
  );
  bool _hasLoadedCurrencyData = false;

  @override
  void initState() {
    super.initState();
    _currencyDataFuture = FileReader.getCurrencyData(
      'https://ea0dc643-c905-4319-91a3-262f08ad520d.mock.pstmn.io/currency_rate',
    );
  }

  @override
  void dispose() {
    inputController.dispose();
    outputController.dispose();
    super.dispose();
  }

  void _swapCurrencies() {
    inputController.text = '0';
    outputController.text = '0';
    CurrencyController().update(
      inputCountry: CurrencyController().outputCountry,
      outputCountry: CurrencyController().inputCountry,
      amount: '0',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _currencyDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            if (!_hasLoadedCurrencyData) {
              Currencies().loadFromJson(snapshot.data!);
              _hasLoadedCurrencyData = true;
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListenableBuilder(
                        listenable: CurrencyController(),
                        builder: (context, _) {
                          double inputRate = Currencies().rateOf(
                            CurrencyController().inputCountry.currencyCode,
                          )!;
                          double outputRate = Currencies().rateOf(
                            CurrencyController().outputCountry.currencyCode,
                          )!;
                          double usdAmount = Currencies().rateOf('USD')!;
                          double exchangeRate =
                              outputRate / inputRate * usdAmount;
                          String exchangeRateFormatted = exchangeRate
                              .toStringAsFixed(2);
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              spacing: 8,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.area_chart_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                Text(
                                  'Tỷ giá: 1 ${CurrencyController().inputCountry.currencyCode.toUpperCase()} = $exchangeRateFormatted ${CurrencyController().outputCountry.currencyCode.toUpperCase()}',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    MoneyTextField(
                      textController: inputController,
                      initialValue: CurrencyController().inputAmount,
                      enabled: true,
                      isInput: true,
                    ),
                    ElevatedButton(
                      onPressed: _swapCurrencies,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(14),
                        elevation: 0,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                      ),
                      child: Icon(
                        Icons.swap_vert,
                        size: 28,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    MoneyTextField(
                      textController: outputController,
                      initialValue: CurrencyController().outputAmount,
                      enabled: false,
                      isInput: false,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tỷ giá được cập nhật lúc 10:30 - 06/04/2026',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
