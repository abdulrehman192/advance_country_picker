import 'package:flutter/material.dart';

import '../advance_country_picker.dart';

class CountryCodeWidget extends StatefulWidget {
  final Country? country;
  final double flagIconWidth;
  final double flagIconHeight;
  final TextStyle? textStyle;
  final Function(Country?) onTap;
  final SelectorType selectorType;
  final List<String> filteredCountries;
  const CountryCodeWidget(
      {super.key,
      this.country,
      this.flagIconWidth = 32,
      this.flagIconHeight = 22,
      this.textStyle,
      required this.onTap,
      this.selectorType = SelectorType.bottomSheet,
      this.filteredCountries = const []});

  @override
  State<CountryCodeWidget> createState() => _CountryCodeWidgetState();
}

class _CountryCodeWidgetState extends State<CountryCodeWidget> {
  Country? _selectedCountry;
  AdvanceCountryPicker picker = AdvanceCountryPicker();

  _loadInitialCountry() async {
    final countries =
        await picker.loadCountries(filterCountries: widget.filteredCountries);
    if (!mounted) return;
    if (countries.isNotEmpty) {
      _selectedCountry = countries.firstWhere((e) => e.name == "Pakistan",
          orElse: () => countries.first);

      setState(() {});
    }
  }

  @override
  void initState() {
    _loadInitialCountry();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.country != null) {
      _selectedCountry = widget.country;
    }
    return GestureDetector(
      onTap: () async {
        if (widget.selectorType == SelectorType.dialogue) {
          _selectedCountry = await picker.showCountryPickerDialog(context,
              filteredCountries: widget.filteredCountries);
        } else {
          _selectedCountry = await picker.showCountryPickerSheet(context,
              filteredCountries: widget.filteredCountries);
        }
        setState(() {});
        widget.onTap(_selectedCountry);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            (_selectedCountry?.flag) ?? "assets/flags/pak.png",
            package: countryCodePackageName,
            width: widget.flagIconWidth,
            height: widget.flagIconHeight,
          ),
          const SizedBox(
            width: 6,
          ),
          Text(
            _selectedCountry?.dialCode ?? "+92",
            style: widget.textStyle ??
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }
}

enum SelectorType { dialogue, bottomSheet }
