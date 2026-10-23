import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../l10n/app_strings.dart';

/// Round purple 3D send button with paper-plane icon.
///
/// Follows AGENTS.md §4.6 & §8: 48dp minimum touch target.
class SendButton extends StatelessWidget {
  const SendButton({
    super.key,
    required this.onPressed,
    this.isEnabled = true,
  });

  final VoidCallback onPressed;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: AppStrings.sendMessage,
      child: Material(
        color: isEnabled ? palette.brand : palette.brand.withValues(alpha: 0.85),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: isEnabled ? onPressed : null,
          child: SizedBox(
            width: 48.0,
            height: 48.0,
            child: Center(
              child: Transform.rotate(
                angle: 0.1,
                child: Icon(
                  Icons.near_me_rounded,
                  size: 22.0,
                  color: palette.textOnBrand,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
