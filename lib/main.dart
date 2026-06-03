import 'package:flutter/material.dart';
import 'package:money_exchange/currency_choice_dialog/currency_choice_dialog.dart';
import 'package:money_exchange/exchange_board/countries/countries.dart';
import 'package:money_exchange/exchange_board/currencies/currencies.dart';
import 'package:money_exchange/file_reader/file_reader.dart';
import 'package:money_exchange/value_notifier/currency_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final jsonList = await FileReader.readCountriesList();
  Countries().getCountriesFromJsonList(jsonList);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Currency Converter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const MyHomePage(title: 'đổi tiền'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final Future<Map<String, dynamic>> _currencyDataFuture;
  final TextEditingController inputAmountController = TextEditingController(
    text: '1',
  );
  final TextEditingController outputAmountController = TextEditingController(
    text: '23,000',
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
    inputAmountController.dispose();
    outputAmountController.dispose();
    super.dispose();
  }

  void _swapCurrencies() {
    CurrencyController().update(
      inputCurrency: CurrencyController().outputCurrency,
      outputCurrency: CurrencyController().inputCurrency,
      inputCountryCode: CurrencyController().outputCountryCode,
      outputCountryCode: CurrencyController().inputCountryCode,
      amount: CurrencyController().outputAmount.replaceAll(' ', ''),
    );
    inputAmountController.text = CurrencyController().inputAmount;
    outputAmountController.text = CurrencyController().outputAmount;
  }

  void _convert() {
    CurrencyController().update(amount: inputAmountController.text);
    outputAmountController.text = CurrencyController().outputAmount;
  }

  String _currencyName(String currencyCode) {
    for (final country in Countries().countries) {
      if (country.currencyCode.toUpperCase() == currencyCode.toUpperCase()) {
        return country.currencyName;
      }
    }

    return currencyCode;
  }

  Future<void> _chooseCurrency({required bool isInput}) async {
    final resultTuple = await showCurrencyChoiceDialog(context);
    if (resultTuple == null) {
      return;
    }

    if (isInput) {
      CurrencyController().update(
        inputCurrency: resultTuple[1],
        inputCountryCode: resultTuple[0],
      );
    } else {
      CurrencyController().update(
        outputCurrency: resultTuple[1],
        outputCountryCode: resultTuple[0],
      );
    }

    outputAmountController.text = CurrencyController().outputAmount;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        toolbarHeight: 104,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.25),
        titleSpacing: 24,
        foregroundColor: scheme.onPrimary,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, size: 32),
            tooltip: 'More options',
          ),
          const SizedBox(width: 16),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                scheme.primary,
                Color.lerp(scheme.primary, scheme.primaryContainer, 0.25)!,
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _currencyDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: scheme.primary),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          if (!_hasLoadedCurrencyData) {
            Currencies().loadFromJson(snapshot.data!);
            CurrencyController().update(
              inputCurrency: 'USD',
              outputCurrency: 'VND',
              amount: inputAmountController.text,
              inputCountryCode: 'us',
              outputCountryCode: 'vn',
            );
            outputAmountController.text = CurrencyController().outputAmount;
            _hasLoadedCurrencyData = true;
          }

          return ListenableBuilder(
            listenable: CurrencyController(),
            builder: (context, child) {
              return SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 52, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AmountCard(
                        controller: inputAmountController,
                        label: 'Amount',
                        currencySymbol:
                            CurrencyController().inputCurrencySymbol,
                        onChanged: (value) {
                          CurrencyController().update(amount: value);
                          outputAmountController.text =
                              CurrencyController().outputAmount;
                        },
                      ),
                      const SizedBox(height: 28),
                      _CurrencySelector(
                        countryCode: CurrencyController().inputCountryCode,
                        currencyCode: CurrencyController().inputCurrency,
                        currencyName: _currencyName(
                          CurrencyController().inputCurrency,
                        ),
                        onTap: () => _chooseCurrency(isInput: true),
                      ),
                      const SizedBox(height: 28),
                      _SwapDivider(onPressed: _swapCurrencies),
                      const SizedBox(height: 28),
                      _CurrencySelector(
                        countryCode: CurrencyController().outputCountryCode,
                        currencyCode: CurrencyController().outputCurrency,
                        currencyName: _currencyName(
                          CurrencyController().outputCurrency,
                        ),
                        onTap: () => _chooseCurrency(isInput: false),
                      ),
                      const SizedBox(height: 28),
                      _ConvertedAmountCard(
                        amount: CurrencyController().outputAmount,
                        currencyCode: CurrencyController().outputCurrency,
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        height: 76,
                        child: FilledButton(
                          onPressed: _convert,
                          style: FilledButton.styleFrom(
                            backgroundColor: scheme.primary,
                            foregroundColor: scheme.onPrimary,
                            elevation: 6,
                            shadowColor: scheme.primary.withValues(alpha: 0.35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0,
                            ),
                          ),
                          child: const Text('Convert'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({
    required this.controller,
    required this.label,
    required this.currencySymbol,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String currencySymbol;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return _OutlinedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: scheme.primary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  currencySymbol,
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: onChanged,
                  style: const TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrencySelector extends StatelessWidget {
  const _CurrencySelector({
    required this.countryCode,
    required this.currencyCode,
    required this.currencyName,
    required this.onTap,
  });

  final String countryCode;
  final String currencyCode;
  final String currencyName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: _OutlinedPanel(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/images/countries_flags/256x192/${countryCode.toLowerCase()}.png',
                  width: 62,
                  height: 46,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 28),
              Expanded(
                child: Text(
                  '$currencyCode - $currencyName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.arrow_drop_down, color: scheme.primary, size: 36),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwapDivider extends StatelessWidget {
  const _SwapDivider({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(child: Divider(color: scheme.outlineVariant, thickness: 2)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Material(
            color: scheme.primary.withValues(alpha: 0.1),
            elevation: 8,
            shadowColor: Colors.black.withValues(alpha: 0.28),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: SizedBox(
                width: 88,
                height: 88,
                child: Icon(Icons.swap_vert, color: scheme.primary, size: 46),
              ),
            ),
          ),
        ),
        Expanded(child: Divider(color: scheme.outlineVariant, thickness: 2)),
      ],
    );
  }
}

class _ConvertedAmountCard extends StatelessWidget {
  const _ConvertedAmountCard({
    required this.amount,
    required this.currencyCode,
  });

  final String amount;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return _OutlinedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Converted Amount',
            style: TextStyle(
              color: scheme.primary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 24),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 64,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(width: 18),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    currencyCode,
                    style: TextStyle(
                      color: scheme.primary,
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlinedPanel extends StatelessWidget {
  const _OutlinedPanel({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.primary, width: 1.5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
