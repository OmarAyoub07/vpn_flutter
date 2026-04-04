import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/app_localizations.dart';
import 'package:app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MyApp(
        initialLocalizations: AppLocalizations('en', {'app_name': 'VPN'}),
        deviceId: 'test-device-id',
      ),
    );
    await tester.pump();
  });
}
