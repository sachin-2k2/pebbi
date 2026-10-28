/// Operational mode for backend-backed feature repositories.
///
/// Follows AGENTS.md §1 & §2: Allows seamless switching between realistic local
/// mock repositories and remote HTTP API implementations.
enum ApiMode {
  mock,
  real;

  static ApiMode fromString(String? value, {ApiMode defaultValue = mock}) {
    if (value == null) return defaultValue;
    return value.toLowerCase().trim() == 'real' ? ApiMode.real : ApiMode.mock;
  }
}
