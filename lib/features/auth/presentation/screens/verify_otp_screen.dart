import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_strings.dart';
import '../providers/verify_otp_form_provider.dart';
import '../widgets/verify_otp_body.dart';

/// Screen allowing the user to enter the 6-digit email verification OTP.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines.
class VerifyOtpScreen extends ConsumerStatefulWidget {
  const VerifyOtpScreen({
    super.key,
    required this.email,
    this.returnTo,
  });

  final String email;
  final String? returnTo;

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  late final TextEditingController _otpController;
  late final FocusNode _otpFocusNode;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _otpFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(verifyOtpFormProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<VerifyOtpFormState>(verifyOtpFormProvider, (prev, next) {
      if (next.isSuccess && !(prev?.isSuccess ?? false)) {
        TextInput.finishAutofillContext();
        final returnTo = widget.returnTo;
        final target = (returnTo != null && !returnTo.startsWith('/lesson'))
            ? returnTo
            : '/path';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.authSuccessLogin),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go(target);
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        resizeToAvoidBottomInset: true,
        body: VerifyOtpBody(
          email: widget.email,
          formState: formState,
          otpController: _otpController,
          otpFocusNode: _otpFocusNode,
          onOtpChanged: (val) =>
              ref.read(verifyOtpFormProvider.notifier).setOtp(val),
          onVerify: () => ref
              .read(verifyOtpFormProvider.notifier)
              .submitOtp(email: widget.email),
          onResend: () => ref
              .read(verifyOtpFormProvider.notifier)
              .resendOtp(email: widget.email),
          onChangeEmail: () => context.go('/register'),
        ),
      ),
    );
  }
}
