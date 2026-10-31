import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/storage/token_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    final active = await globalTokenStorage.getActiveSession();
    if (active == null) {
      await globalTokenStorage.saveSession(
        '6ae1949fc2c6b58d06d9b6c1',
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2YWUxOTQ5ZmMyYzZiNThkMDZkOWI2YzEiLCJleHAiOjE3OTM5NDkyODJ9.QbPaiA3LIgNgBwKlipIGDmokJ3Bl7V33kxDNvSyvwj4',
      );
    }
  }
  runApp(const ProviderScope(child: PebbiApp()));
}
