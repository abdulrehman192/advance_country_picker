import 'package:flutter/material.dart';
import '../advance_country_picker.dart';

/// A widget that provides a text field with a customizable country code input.
/// Allows getting and setting the phone number and country programmatically.
class AdvanceCountryCodeInputField extends StatefulWidget {
  final Function(String phoneNumber, Country? country)? onPhoneNumberChanged;
  final double flagIconWidth;
  final double flagIconHeight;
  final TextStyle textStyle;
  final String? hintText;
  final SelectorType selectorType;
  final List<String> filteredCountries;
  final Country? initialCountry;
  final String? initialPhoneNumber;
  final Color? borderColor;
  final Color? dividerColor;
  final double? borderRadius;

  const AdvanceCountryCodeInputField({
    super.key,
    this.onPhoneNumberChanged,
    this.flagIconWidth = 32,
    this.flagIconHeight = 22,
    this.textStyle = const TextStyle(fontSize: 16),
    this.selectorType = SelectorType.bottomSheet,
    this.filteredCountries = const [],
    this.initialCountry,
    this.initialPhoneNumber,
    this.borderColor,
    this.dividerColor,
    this.borderRadius,
    this.hintText,
  });

  @override
  PhoneNumberInputState createState() => PhoneNumberInputState();
}

class PhoneNumberInputState extends State<AdvanceCountryCodeInputField> {
  final TextEditingController _phoneNumberController = TextEditingController();
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
    super.initState();
    _loadInitialCountry();

    if (widget.initialCountry != null) {
      _selectedCountry = widget.initialCountry;
    }
    if (widget.initialPhoneNumber != null) {
      _phoneNumberController.text = widget.initialPhoneNumber!;
    }
  }

  /// Gets the input phone number.
  String get phoneNumber => _phoneNumberController.text;

  /// Sets the country and phone number programmatically.
  void setCountryAndPhoneNumber(Country country, String phoneNumber) {
    setState(() {
      _selectedCountry = country;
      _phoneNumberController.text = phoneNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.initialCountry != null) {
      _selectedCountry = widget.initialCountry;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
          border: Border.all(color: widget.borderColor ?? Colors.grey)),
      child: Row(
        children: [
          CountryCodeWidget(
            country: _selectedCountry,
            flagIconWidth: widget.flagIconWidth,
            flagIconHeight: widget.flagIconHeight,
            textStyle: widget.textStyle,
            onTap: (country) {
              setState(() {
                _selectedCountry = country;
              });
              if (widget.onPhoneNumberChanged != null) {
                widget.onPhoneNumberChanged!(
                  _phoneNumberController.text,
                  _selectedCountry,
                );
              }
            },
            selectorType: widget.selectorType,
            filteredCountries: widget.filteredCountries,
          ),
          Container(
            width: 1,
            height: 30,
            color: widget.dividerColor ?? Colors.grey,
            margin: const EdgeInsets.symmetric(horizontal: 5),
          ),
          Expanded(
            child: TextField(
              controller: _phoneNumberController,
              style: widget.textStyle,
              keyboardType: TextInputType.phone,
              maxLines: 1,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hintText,
              ),
              onChanged: (value) {
                if (widget.onPhoneNumberChanged != null) {
                  widget.onPhoneNumberChanged!(
                    value,
                    _selectedCountry,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
