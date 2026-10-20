import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/path/presentation/widgets/ad_banner.dart';

void main() {
  group('AdBanner Widget', () {
    testWidgets('renders dynamic store price and handles remove ads tap', (
      tester,
    ) async {
      var removeTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdBanner(
              priceString: r'$3.99/month',
              onRemoveAdsTap: () => removeTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('AD'), findsOneWidget);
      expect(find.text('Sponsored'), findsOneWidget);
      expect(find.text(r'Remove ads · Premium $3.99/month'), findsOneWidget);

      await tester.tap(find.text(r'Remove ads · Premium $3.99/month'));
      expect(removeTapped, isTrue);
    });
  });
}
