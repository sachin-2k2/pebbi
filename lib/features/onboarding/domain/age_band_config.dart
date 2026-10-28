import 'age_band.dart';

/// Clock typedef for injectable timestamp testing.
typedef Clock = DateTime Function();

/// Policy governing retry behavior after an under-13 age gate block.
///
/// TODO(question): Confirm with legal/product whether users blocked by the age gate
/// should be allowed to pick a new year immediately (allow), blocked for the app
/// session (lockForSession), or blocked persistently on the device (lockOnDevice).
enum AgeGateRetryPolicy { allow, lockForSession, lockOnDevice }

/// Active age gate retry policy. Defaults to [AgeGateRetryPolicy.allow].
const AgeGateRetryPolicy ageGateRetryPolicy = AgeGateRetryPolicy.allow;

/// Minimum age required to access Pebbi.
const int kMinimumPlatformAge = 13;

/// Static namespace class for age band calculation configuration.
abstract final class AgeBandConfig {
  static const int minimumPlatformAge = kMinimumPlatformAge;
  static const AgeGateRetryPolicy ageGateRetryPolicy = AgeGateRetryPolicy.allow;

  static int calculateYoungestPossibleAge(int birthYear, {Clock? now}) {
    final current = now != null ? now() : DateTime.now();
    return current.year - birthYear - 1;
  }

  static AgeBand? evaluateAgeBand(int birthYear, {Clock? now}) {
    final youngestAge = calculateYoungestPossibleAge(birthYear, now: now);

    if (youngestAge < minimumPlatformAge) {
      return null;
    }
    if (youngestAge <= 17) {
      return AgeBand.band13_17;
    }
    if (youngestAge <= 24) {
      return AgeBand.band18_24;
    }
    if (youngestAge <= 34) {
      return AgeBand.band25_34;
    }
    if (youngestAge <= 44) {
      return AgeBand.band35_44;
    }
    if (youngestAge <= 54) {
      return AgeBand.band45_54;
    }
    return AgeBand.band55Plus;
  }
}

/// Evaluates youngest possible age from a calendar birth year:
/// `youngestPossibleAge = currentYear - birthYear - 1`
int calculateYoungestPossibleAge(int birthYear, {Clock? clock}) =>
    AgeBandConfig.calculateYoungestPossibleAge(birthYear, now: clock);

/// Evaluates the user's canonical [AgeBand] from their birth year.
AgeBand? evaluateAgeBand(int birthYear, {Clock? clock}) =>
    AgeBandConfig.evaluateAgeBand(birthYear, now: clock);
