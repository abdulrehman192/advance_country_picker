import 'dart:math';

import '../../phone_numbers_parser.dart';
import '../metadata/metadata_finder.dart';
import '../regex/constants.dart';

abstract class CountryCodeParser {
  /// tries to find a country calling code at the start of a phone number
  static (String countryCode, String nsn) extractCountryCode(
    String phoneNumber,
  ) {
    final maxCountryCodeLength = min(
      phoneNumber.length,
      Constants.maxLengthCountryCallingCode,
    );
    var longestPotentialCountryCode =
        phoneNumber.substring(0, maxCountryCodeLength);

    for (var i = 1; i <= longestPotentialCountryCode.length; i++) {
      final potentialCountryCodeFit =
          longestPotentialCountryCode.substring(0, i);
      final nsn = phoneNumber.substring(i);
      final countryMetadata = MetadataFinder.findMetadataForCountryCode(
        potentialCountryCodeFit,
        nsn,
      );
      if (countryMetadata != null) {
        return (countryMetadata.countryCode, nsn);
      }
    }
    throw PhoneNumberException(
        code: Code.notFound,
        description:
            'country calling code not found in phone number $phoneNumber');
  }
}
