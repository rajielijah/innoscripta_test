
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

Future<LicenseEntry> _license(String library, String path) async {
  String text = await rootBundle.loadString(path);
  LicenseEntry lic = LicenseEntryWithLineBreaks(<String>[library], text);
  return lic;
}

Stream<LicenseEntry> getFontLicenses() {
  return Stream.fromFutures([
    _license("PublicSans", "fonts/LICENSE-PublicSans.md"),
  ]);
}
