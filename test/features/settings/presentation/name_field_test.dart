import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/settings/presentation/widgets/name_field.dart';

void main() {
  group('NameField auto-save & blur tests', () {
    testWidgets('automatically saves name after typing (debounce)', (tester) async {
      String? savedName;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NameField(
              initialName: 'OldName',
              onSaved: (name) => savedName = name,
            ),
          ),
        ),
      );

      // Enter new text without pressing Done
      await tester.enterText(find.byType(TextField), 'Farsana');
      expect(savedName, isNull);

      // Advance debounce timer (600ms)
      await tester.pump(const Duration(milliseconds: 700));

      expect(savedName, equals('Farsana'));
    });

    testWidgets('saves name on dispose when navigating back without tapping Done', (tester) async {
      String? savedName;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: savedName == 'DESTROYED'
                    ? const SizedBox()
                    : NameField(
                        initialName: 'OldName',
                        onSaved: (name) => savedName = name,
                      ),
              );
            },
          ),
        ),
      );

      // User types and immediately leaves the screen
      await tester.enterText(find.byType(TextField), 'NewName');

      // Unmount the widget immediately (simulating back navigation / pop)
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );

      expect(savedName, equals('NewName'));
    });
  });
}
