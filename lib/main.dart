import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_exchange/money_exchange/exchange_board/countries/countries.dart';
import 'package:money_exchange/file_reader/file_reader.dart';
import 'package:money_exchange/money_exchange/money_exchange.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final jsonList = await FileReader.readCountriesList();
  Countries().getCountriesFromJsonList(jsonList);

  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const MoneyExchange(title: 'Đổi Tiền'),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Money Exchange',
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
