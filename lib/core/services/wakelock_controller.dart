import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Abstract interface for controlling screen keep-awake state.
///
/// Follows AGENTS.md §2.1 & §2.4: Keeps wakelock behind an interface for unit & widget tests.
abstract interface class WakelockController {
  Future<void> enable();
  Future<void> disable();
}

/// Production implementation backed by [WakelockPlus].
class RealWakelockController implements WakelockController {
  @override
  Future<void> enable() async {
    try {
      await WakelockPlus.enable();
    } catch (_) {}
  }

  @override
  Future<void> disable() async {
    try {
      await WakelockPlus.disable();
    } catch (_) {}
  }
}

/// In-memory test double for unit and widget testing.
class FakeWakelockController implements WakelockController {
  bool isEnabled = false;
  int enableCount = 0;
  int disableCount = 0;

  @override
  Future<void> enable() async {
    isEnabled = true;
    enableCount++;
  }

  @override
  Future<void> disable() async {
    isEnabled = false;
    disableCount++;
  }
}

/// Riverpod provider for the active [WakelockController].
final wakelockControllerProvider = Provider<WakelockController>((ref) {
  return RealWakelockController();
});
