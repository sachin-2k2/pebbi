import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';

/// Interactive container displaying an invite URL with a one-tap Copy action.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines), §4.6 (>=48dp touch target),
/// and WCAG AA contrast standards.
class InviteLinkField extends StatefulWidget {
  const InviteLinkField({super.key, required this.url, this.onCopied});

  final String url;
  final VoidCallback? onCopied;

  @override
  State<InviteLinkField> createState() => _InviteLinkFieldState();
}

class _InviteLinkFieldState extends State<InviteLinkField> {
  bool _copied = false;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.url));
    // ignore: deprecated_member_use
    SemanticsService.announce(AppStrings.copiedToClipboard, TextDirection.ltr);

    if (!mounted) return;
    setState(() => _copied = true);
    widget.onCopied?.call();

    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _copied = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? AppColors.darkInviteFieldBackground
        : AppColors.inviteFieldBackground;
    final border = isDark
        ? AppColors.darkInviteFieldBorder
        : AppColors.inviteFieldBorder;
    final textColor = isDark
        ? AppColors.darkInviteFieldText
        : AppColors.inviteFieldText;
    final copyColor = isDark
        ? AppColors.darkInviteCopyText
        : AppColors.inviteCopyText;

    return Container(
      constraints: const BoxConstraints(minHeight: 48.0),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: border, width: 1.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Semantics(
            button: true,
            label: _copied
                ? AppStrings.copiedToClipboard
                : AppStrings.copyInviteLink,
            child: InkWell(
              onTap: _handleCopy,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 48.0,
                  minHeight: 48.0,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_copied) ...[
                          Icon(
                            Icons.check_rounded,
                            size: 16.0,
                            color: copyColor,
                          ),
                          const SizedBox(width: 4.0),
                        ],
                        Text(
                          _copied
                              ? AppStrings.inviteCopied
                              : AppStrings.inviteCopy,
                          style: TextStyle(
                            color: copyColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
