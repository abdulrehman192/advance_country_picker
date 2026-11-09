import 'package:flutter/material.dart';

import '../advance_country_picker.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class AdvanceCountryPicker {
  static final AdvanceCountryPicker _instance =
      AdvanceCountryPicker._internal();
  AdvanceCountryPicker._internal() {
    loadCountries();
  }

  factory AdvanceCountryPicker() {
    return _instance;
  }

  List<Country> _countries = [];
  List<Country> get countries => _countries;

  Future<List<Country>> loadCountries(
      {List<String> filterCountries = const []}) async {
    // Load the JSON string from the asset
    String jsonString = await rootBundle.loadString(
        'packages/advance_country_picker/assets/json/countries.json');

    // Decode the JSON string into a Dart object
    List<dynamic> jsonList = jsonDecode(jsonString);

    // Cast the dynamic list to a list of maps
    List<Map<String, dynamic>> data = jsonList.cast<Map<String, dynamic>>();

    // Convert the list of maps to a list of Country objects
    var list = data.map((e) => Country.fromJson(e)).toList();
    if (filterCountries.isEmpty) {
      _countries = list;
      return _countries;
    }

    // Build the filtered list separately: clearing `list` itself would leave
    // nothing to search. Entries that match no country are skipped.
    final filtered = <Country>[];
    for (var c in filterCountries) {
      final key = c.toLowerCase();
      for (final e in list) {
        if (e.name.toLowerCase() == key || e.countryCode.toLowerCase() == key) {
          if (!filtered.contains(e)) filtered.add(e);
          break;
        }
      }
    }
    _countries = filtered;
    return _countries;
  }

  Future<Country?> getCountryByCountryCode(String countryCode) async {
    List<Country> list = await loadCountries();
    return list.firstWhere((element) =>
        element.countryCode.toLowerCase() == countryCode.toLowerCase());
  }

  Future<Country?> getCountryByCountryName(String countryName) async {
    List<Country> list = await loadCountries();
    return list.firstWhere(
        (element) => element.name.toLowerCase() == countryName.toLowerCase());
  }

  Future<Country?> getCountryByNationality(String nationality) async {
    List<Country> list = await loadCountries();
    return list.firstWhere((element) =>
        element.nationality.toLowerCase() == nationality.toLowerCase());
  }

  /// Returns the country for [dialCode] (e.g. `+1`, `1`, `+44`), or `null`
  /// if no country uses it.
  ///
  /// When several countries share a dial code (e.g. `+1`, `+7`, `+44`), the
  /// main country for that code is returned (US for `+1`, RU for `+7`, ...).
  Future<Country?> getCountryByDialCode(String dialCode) async {
    List<Country> list = await loadCountries();
    final digits = dialCode.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    final normalized = '+$digits';
    final matches = list.where((e) => e.dialCode == normalized).toList();
    if (matches.isEmpty) return null;
    final mainIso = countryCodeToIsoCode[digits]?.first.name;
    if (mainIso != null) {
      for (final c in matches) {
        if (c.alpha2.toUpperCase() == mainIso) return c;
      }
    }
    return matches.first;
  }

  Future<Country?> showCountryPickerSheet(BuildContext context,
      {Widget? title,
      Widget? cancelWidget,
      double cornerRadius = 25,
      bool focusSearchBox = false,
      double heightFactor = 0.9,
      List<String> filteredCountries = const [],
      TextStyle itemTextStyle = const TextStyle(fontSize: 16),
      TextStyle searchInputStyle = const TextStyle(fontSize: 16),
      InputDecoration? searchInputDecoration,
      double flagIconWidth = 32,
      double flagIconHeight = 22,
      bool showSeparator = false,
      String searchHintText = "Search country name, code"}) async {
    assert(heightFactor <= 0.9 && heightFactor >= 0.4,
        'heightFactor must be between 0.4 and 0.9');
    return await showModalBottomSheet<Country?>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(cornerRadius),
                topRight: Radius.circular(cornerRadius))),
        builder: (_) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * heightFactor,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 12),
                Stack(
                  children: <Widget>[
                    cancelWidget ??
                        Positioned(
                          right: 8,
                          top: 0,
                          bottom: 0,
                          child: TextButton(
                            style: const ButtonStyle(
                                padding: WidgetStatePropertyAll(
                                    EdgeInsets.symmetric(vertical: 4))),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                    Center(
                      child: title ??
                          const Text(
                            'Choose country',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: AdvanceCountryPickerWidget(
                    onSelected: (country) => Navigator.of(context).pop(country),
                    filteredCountries: filteredCountries,
                    itemTextStyle: itemTextStyle,
                    searchHintText: searchHintText,
                    searchInputDecoration: searchInputDecoration,
                    searchInputStyle: searchInputStyle,
                    showSeparator: showSeparator,
                    flagIconWidth: flagIconWidth,
                    flagIconHeight: flagIconHeight,
                    focusSearchBox: focusSearchBox,
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<Country?> showCountryPickerDialog(BuildContext context,
      {Widget? title,
      double cornerRadius = 20,
      bool focusSearchBox = false,
      List<String> filteredCountries = const [],
      TextStyle itemTextStyle = const TextStyle(fontSize: 16),
      TextStyle searchInputStyle = const TextStyle(fontSize: 16),
      InputDecoration? searchInputDecoration,
      double flagIconWidth = 32,
      double flagIconHeight = 22,
      bool showSeparator = false,
      String searchHintText = "Search country name, code"}) async {
    return await showDialog<Country?>(
        context: context,
        barrierDismissible: true,
        builder: (_) => Dialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                Radius.circular(cornerRadius),
              )),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 12),
                  Stack(
                    children: <Widget>[
                      Positioned(
                        right: 8,
                        top: 0,
                        bottom: 0,
                        child: TextButton(
                            style: const ButtonStyle(
                                padding: WidgetStatePropertyAll(
                                    EdgeInsets.symmetric(vertical: 4))),
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel")),
                      ),
                      Center(
                        child: title ??
                            const Text(
                              'Choose country',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: AdvanceCountryPickerWidget(
                      onSelected: (country) =>
                          Navigator.of(context).pop(country),
                      filteredCountries: filteredCountries,
                      itemTextStyle: itemTextStyle,
                      searchHintText: searchHintText,
                      searchInputDecoration: searchInputDecoration,
                      searchInputStyle: searchInputStyle,
                      showSeparator: showSeparator,
                      flagIconWidth: flagIconWidth,
                      flagIconHeight: flagIconHeight,
                      focusSearchBox: focusSearchBox,
                    ),
                  ),
                ],
              ),
            ));
  }
}
