import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('No hardcoded colors outside lib/core/theme/', () {
    final libDir = Directory('lib');
    final dartFiles = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();

    // Documented allow-list with explanations:
    // Any entry here must be strictly justified.
    final allowedFiles = <String, String>{
      'lib/core/design_system/pebbi_mascot.dart':
          'Vector mascot character art illustration with character-specific feature colors '
          '(pink inner ears, eyes, blush cheeks, backpack/scarf straps).',
    };

    final violations = <String, List<String>>{};

    for (final file in dartFiles) {
      final relativePath = file.path.replaceAll('\\', '/');

      // Skip files in core/theme as that is where color tokens & palettes are defined
      if (relativePath.startsWith('lib/core/theme/')) {
        continue;
      }

      if (allowedFiles.containsKey(relativePath)) {
        continue;
      }

      final lines = file.readAsLinesSync();
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        final lineNum = i + 1;

        // Strip comments
        final trimmed = line.trim();
        if (trimmed.startsWith('//') || trimmed.startsWith('/*')) continue;

        // Check for Colors.* (except Colors.transparent)
        final colorsMatch =
            RegExp(r'\bColors\.(?!transparent\b)[a-zA-Z0-9]+').allMatches(line);
        for (final m in colorsMatch) {
          violations.putIfAbsent(relativePath, () => []).add(
                'L$lineNum: ${m.group(0)}',
              );
        }

        // Check for raw Color(0x... hex literals
        if (RegExp(r'\bColor\(0[xX][0-9a-fA-F]+\)').hasMatch(line)) {
          violations.putIfAbsent(relativePath, () => []).add(
                'L$lineNum: raw Color hex literal',
              );
        }

        // Check for Color.fromARGB or Color.fromRGBO
        if (line.contains('Color.fromARGB') || line.contains('Color.fromRGBO')) {
          violations.putIfAbsent(relativePath, () => []).add(
                'L$lineNum: Color.from* constructor',
              );
        }

        // Check for AppColors.* outside theme
        final appColorsMatch =
            RegExp(r'\bAppColors\.[a-zA-Z0-9]+').allMatches(line);
        for (final m in appColorsMatch) {
          violations.putIfAbsent(relativePath, () => []).add(
                'L$lineNum: ${m.group(0)}',
              );
        }
      }
    }

    if (violations.isNotEmpty) {
      final buffer = StringBuffer();
      buffer.writeln(
        'Found hardcoded color references in ${violations.length} files outside lib/core/theme/:\n',
      );
      for (final entry in violations.entries) {
        buffer.writeln('${entry.key}:');
        for (final issue in entry.value) {
          buffer.writeln('  $issue');
        }
      }
      fail(buffer.toString());
    }
  });
}
