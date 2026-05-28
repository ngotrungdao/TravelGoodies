import 'package:flutter/material.dart';
import 'package:money_exchange/exchange_board/countries/countries.dart';
import 'package:money_exchange/exchange_board/currencies/currencies.dart';

class _CurrencyChoiceItem {
  const _CurrencyChoiceItem({required this.code, required this.name, required this.alpha2Code});

  final String code;
  final String name;
  final String alpha2Code;
}

List<_CurrencyChoiceItem> _getChoiceItems() {
  var countries = Countries().countries;
  var currencies = Currencies().currencies;

  List<_CurrencyChoiceItem> items = [];

  for (var country in countries) {
    for (var currency in currencies) {
      if (country.currencyCode.toLowerCase() == currency.code.toLowerCase()) {
        items.add(
          _CurrencyChoiceItem(
            code: country.currencyCode,
            name: country.name,
            alpha2Code: country.alpha2Code,
          ),
        );
        break;
      }
    }
  }

  return items;
}

Future<List<String>?> showCurrencyChoiceDialog(BuildContext context) {
  final List<_CurrencyChoiceItem> allItems = _getChoiceItems();
  final Map<String, _CurrencyChoiceItem> itemsByCode = {
    for (final item in allItems) item.alpha2Code: item,
  };
  final listChangeNotifier = ValueNotifier<List<String>>(
    allItems.map((item) => item.alpha2Code).toList(growable: false),
  );
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Center(child: Text('chọn loại tiền tệ')),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Tìm kiếm',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  final query = value.trim().toLowerCase();
                  if (query.isEmpty) {
                    listChangeNotifier.value = allItems
                        .map((item) => item.alpha2Code)
                        .toList(growable: false);
                    return;
                  }

                  listChangeNotifier.value = allItems
                      .where((item) {
                        return item.code.toLowerCase().contains(query) ||
                            item.name.toLowerCase().contains(query);
                      })
                      .map((item) => item.alpha2Code)
                      .toList(growable: false);
                },
              ),

              Expanded(
                child: ValueListenableBuilder<List<String>>(
                  valueListenable: listChangeNotifier,
                  builder: (context, value, child) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        final item = itemsByCode[value[index]];
                        if (item == null) {
                          return const SizedBox.shrink();
                        }
                        return ListTile(
                          leading: Image.asset(
                            'assets/images/countries_flags/256x192/${item.alpha2Code.toLowerCase()}.png',
                            width: 32,
                            height: 32,
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(width: 50, child: Text(item.code)),
                              Expanded(
                                child: Text(item.name, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).pop(<String>[item.alpha2Code, item.code]);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
