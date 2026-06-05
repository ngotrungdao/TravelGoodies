import 'package:flutter/material.dart';
import 'package:money_exchange/currency_choice_dialog/currency_choice_dialog.dart';
import 'package:money_exchange/exchange_board/countries/countries.dart';
import 'package:money_exchange/exchange_board/currencies/currencies.dart';
import 'package:money_exchange/file_reader/file_reader.dart';
import 'package:money_exchange/money_text_field/money_text_field.dart';
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
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
      fontFamily: 'Roboto',
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Currency Converter',
      theme: theme.copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
          titleTextStyle: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(textStyle: theme.textTheme.titleLarge),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.zero,
        ),
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
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

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MoneyTextField(
                    labelText:
                        'Amount in ${CurrencyController().inputCurrency.toUpperCase()}',
                    countriesCode: CurrencyController().inputCountryCode,
                    initialValue: CurrencyController().inputAmount,
                    enabled: true,
                  ),
                  const SizedBox(height: 16),
                  IconButton(
                    icon: const Icon(Icons.swap_vert),
                    onPressed: _swapCurrencies,
                  ),
                  const SizedBox(height: 16),
                  MoneyTextField(
                    labelText:
                        'Amount in ${CurrencyController().outputCurrency.toUpperCase()}',
                    countriesCode: CurrencyController().outputCountryCode,
                    initialValue: CurrencyController().outputAmount,
                    enabled: false,
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _convert,
                    child: const Text('Convert'),
                  ),
                ],
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
