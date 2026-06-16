import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:money_exchange/money_exchange/exchange_board/countries/countries.dart';
import 'package:money_exchange/money_exchange/exchange_board/countries/country.dart';
import 'package:money_exchange/money_exchange/exchange_board/currencies/currencies.dart';

List<Country> _getChoiceItems() {
  var countries = Countries().countries;
  var currencies = Currencies().currencies;

  List<Country> items = [];

  for (var country in countries) {
    for (var currency in currencies) {
      if (country.currencyCode.toLowerCase() == currency.code.toLowerCase()) {
        items.add(
          Country(
            name: country.name,
            alpha2Code: country.alpha2Code,
            currencyCode: country.currencyCode,
            currencyName: country.currencyName,
            currencySymbol: country.currencySymbol,
            flagIcon: country.flagIcon,
            capital: country.capital,
            continent: country.continent,
            population: country.population,
          ),
        );
        break;
      }
    }
  }

  return items;
}

List<Country> _allItems = [];

Future<Country?> showCurrencyChoiceDialog(BuildContext context) {
  if (_allItems.isEmpty) {
    _allItems = _getChoiceItems();
  }
  final Map<String, Country> itemsByCode = {
    for (final item in _allItems) item.alpha2Code: item,
  };
  final listChangeNotifier = ValueNotifier<List<String>>(
    _allItems.map((item) => item.alpha2Code).toList(growable: false),
  );
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Center(child: Text('chọn loại tiền tệ')),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('hủy'),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Tìm kiếm',
                    prefixIcon: Icon(Icons.search),
                    isCollapsed: false,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                    ),
                  ),
                  onChanged: (value) {
                    final query = value.trim().toLowerCase();
                    if (query.isEmpty) {
                      listChangeNotifier.value = _allItems
                          .map((item) => item.alpha2Code)
                          .toList(growable: false);
                      return;
                    }

                    listChangeNotifier.value = _allItems
                        .where((item) {
                          return item.currencyCode.toLowerCase().contains(
                                query,
                              ) ||
                              item.name.toLowerCase().contains(query);
                        })
                        .map((item) => item.alpha2Code)
                        .toList(growable: false);
                  },
                ),
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
                          leading: Container(
                            height: 32,
                            width: 32,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                            ),
                            child: SvgPicture.asset(
                              'assets/images/countries_flags/svg/${item.alpha2Code.toLowerCase()}.svg',
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 50,
                                child: Text(item.currencyCode),
                              ),
                              Expanded(
                                child: Text(
                                  item.name,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).pop(item);
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
