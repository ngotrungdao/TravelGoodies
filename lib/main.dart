import 'package:flutter/material.dart';
import 'package:money_exchange/currency_choice_dialog/currency_choice_dialog.dart';
import 'package:money_exchange/exchange_board/countries/countries.dart';
import 'package:money_exchange/exchange_board/countries/country.dart';
import 'package:money_exchange/exchange_board/currencies/currencies.dart';
import 'package:money_exchange/file_reader/file_reader.dart';
import 'package:money_exchange/value_notifier/currency_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var jsonList = await FileReader.readCountriesList();
  final List<Country> countries = Countries().getCountriesFromJsonList(
    jsonList,
  );
  print('Loaded ${countries.length} countries');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'chuyển đổi tiền tệ'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController inputAmountController = TextEditingController(
    text: '1',
  );
  final TextEditingController outputAmountController = TextEditingController(
    text: '23,000',
  );
  String inputCurrency = 'USD';
  String outputCurrency = 'VND';
  String initialInputAmount = '1';
  String initialOutputAmount = '23,000';

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Center(
          child: Text(
            widget.title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: FileReader.getCurrencyData(
          'https://ea0dc643-c905-4319-91a3-262f08ad520d.mock.pstmn.io/currency_rate',
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          }

          final currencyData = snapshot.data!;
          final currencies = Currencies();
          currencies.loadFromJson(currencyData);
          CurrencyController().update(
            inputCurrency: 'USD',
            outputCurrency: 'VND',
            amount: '1',
            inputCountryCode: 'us',
            outputCountryCode: 'vn',
          );
          outputAmountController.text = CurrencyController().outputAmount;
          return ListenableBuilder(
            listenable: CurrencyController(),
            builder: (context, child) {
              return Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        spacing: 32,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/countries_flags/256x192/${CurrencyController().inputCountryCode.toLowerCase()}.png',
                                  width: 32,
                                ),
                                SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    showCurrencyChoiceDialog(context).then((
                                      resultTuple,
                                    ) {
                                      if (resultTuple != null) {
                                        CurrencyController().update(
                                          inputCurrency: resultTuple[1],
                                          inputCountryCode: resultTuple[0],
                                        );
                                        outputAmountController.text =
                                            CurrencyController().outputAmount;
                                      }
                                    });
                                  },
                                  child: Text(
                                    CurrencyController().inputCurrency,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              CurrencyController().update(
                                inputCurrency:
                                    CurrencyController().outputCurrency,
                                outputCurrency:
                                    CurrencyController().inputCurrency,
                                inputCountryCode:
                                    CurrencyController().outputCountryCode,
                                outputCountryCode:
                                    CurrencyController().inputCountryCode,
                                amount: CurrencyController().outputAmount,
                              );
                              inputAmountController.text =
                                  CurrencyController().inputAmount;
                              outputAmountController.text =
                                  CurrencyController().outputAmount;
                            },
                            child: Icon(Icons.currency_exchange),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/countries_flags/256x192/${CurrencyController().outputCountryCode.toLowerCase()}.png',
                                  width: 32,
                                ),
                                SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    showCurrencyChoiceDialog(context).then((
                                      resultTuple,
                                    ) {
                                      if (resultTuple != null) {
                                        CurrencyController().update(
                                          outputCurrency: resultTuple[1],
                                          outputCountryCode: resultTuple[0],
                                        );
                                        outputAmountController.text =
                                            CurrencyController().outputAmount;
                                      }
                                    });
                                  },
                                  child: Text(
                                    CurrencyController().outputCurrency,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
                      Container(
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.symmetric(horizontal: 32),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: null,
                              child: Text(
                                '${CurrencyController().inputCurrencyRate} ${CurrencyController().inputCurrency} = ${CurrencyController().outputCurrencyRate} ${CurrencyController().outputCurrency}',
                              ),
                            ),
                            SizedBox(height: 32),
                            TextFormField(
                              controller: inputAmountController,
                              //initialValue: initialInputAmount,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText:
                                    'Số tiền (${CurrencyController().inputCurrency})',
                                //border: OutlineInputBorder(),
                                suffixText: CurrencyController().inputCurrency,
                              ),
                              onFieldSubmitted: (value) {
                                CurrencyController().update(amount: value);
                                outputAmountController.text =
                                    CurrencyController().outputAmount;
                              },
                              onChanged: (value) {
                                CurrencyController().update(amount: value);
                                outputAmountController.text =
                                    CurrencyController().outputAmount;
                              },
                            ),
                            SizedBox(height: 16),
                            IconButton(
                              onPressed: () {
                                CurrencyController().update(
                                  inputCurrency:
                                      CurrencyController().outputCurrency,
                                  outputCurrency:
                                      CurrencyController().inputCurrency,
                                  inputCountryCode:
                                      CurrencyController().outputCountryCode,
                                  outputCountryCode:
                                      CurrencyController().inputCountryCode,
                                  amount: CurrencyController().outputAmount,
                                );
                                inputAmountController.text =
                                    CurrencyController().inputAmount;
                                outputAmountController.text =
                                    CurrencyController().outputAmount;
                              },
                              icon: Icon(Icons.swap_vert),
                            ),
                            SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              //decoration: BoxDecoration(
                              //  border: Border.all(
                              //    color: Theme.of(context).colorScheme.outline,
                              //  ),
                              //  borderRadius: BorderRadius.circular(4),
                              //),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    CurrencyController().outputAmount,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  Text(
                                    CurrencyController().outputCurrency,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          CurrencyController().update(
                            amount: inputAmountController.text,
                          );
                          outputAmountController.text =
                              CurrencyController().outputAmount;
                        },
                        child: Text('chuyển đổi'),
                      ),
                      SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      bottomNavigationBar: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {},
              child: Row(
                children: [
                  Icon(
                    Icons.home,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Home',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Settings',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'About',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Xử lý khi người dùng nhấn nút chuyển đổi
        },
        tooltip: 'Chuyển đổi',
        child: Icon(Icons.swap_horiz),
      ),
    );
  }
}
