import 'package:advance_country_picker/advance_country_picker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final picker = AdvanceCountryPicker();

  test('dial codes contain no area codes or spaces', () async {
    final countries = await picker.loadCountries();
    for (final c in countries) {
      expect(c.dialCode, matches(RegExp(r'^\+\d{1,3}$')),
          reason: '${c.alpha2} has dialCode ${c.dialCode}');
    }
  });

  test('previously wrong dial codes are corrected', () async {
    final countries = await picker.loadCountries();
    String code(String iso) =>
        countries.firstWhere((c) => c.alpha2 == iso).dialCode;
    expect(code('KZ'), '+7');
    expect(code('VA'), '+39');
    expect(code('BQ'), '+599');
    expect(code('SJ'), '+47');
    for (final iso in ['JM', 'DO', 'PR', 'VI', 'AG', 'BS', 'TT']) {
      expect(code(iso), '+1', reason: iso);
    }
  });

  test('getCountryByDialCode prefers the main country', () async {
    expect((await picker.getCountryByDialCode('+1'))?.alpha2, 'US');
    expect((await picker.getCountryByDialCode('1'))?.alpha2, 'US');
    expect((await picker.getCountryByDialCode('+7'))?.alpha2, 'RU');
    expect((await picker.getCountryByDialCode('+39'))?.alpha2, 'IT');
    expect((await picker.getCountryByDialCode('+47'))?.alpha2, 'NO');
    expect((await picker.getCountryByDialCode('+92'))?.alpha2, 'PK');
  });

  test('getCountryByDialCode returns null for unknown codes', () async {
    expect(await picker.getCountryByDialCode('+1876'), isNull);
    expect(await picker.getCountryByDialCode(''), isNull);
  });

  test('loadCountries applies filterCountries', () async {
    final filtered = await picker.loadCountries(
        filterCountries: ['Pakistan', 'united arab emirates', '44', 'Nowhere']);
    expect(filtered.map((c) => c.alpha2), ['PK', 'AE', 'GB']);
    expect(picker.countries.length, 3);

    final all = await picker.loadCountries();
    expect(all.length, 244);
  });
}
