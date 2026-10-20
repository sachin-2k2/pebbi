import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/forgot_password_form_provider.dart';
import '../widgets/forgot_password_body.dart';

/// Forgot Password screen ("Reset password").
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// thin composition screen, zero email retention beyond disposal.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail});

  /// Optional pre-filled email from login screen.
  final String? initialEmail;

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  late final TextEditingController _emailController;
  late final FocusNode _emailFocusNode;

  @override
  void initState() {
    super.initState();
    final sanitized = ref
        .read(forgotPasswordFormProvider.notifier)
        .sanitizeInitialEmail(widget.initialEmail);
    _emailController = TextEditingController(text: sanitized ?? '');
    _emailFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailController.clear();
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(forgotPasswordFormProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.background,
        resizeToAvoidBottomInset: true,
        body: ForgotPasswordBody(
          formState: formState,
          emailController: _emailController,
          emailFocusNode: _emailFocusNode,
          onSubmit: _handleSubmit,
          onResend: () =>
              ref.read(forgotPasswordFormProvider.notifier).resend(),
          onBackToLogIn: _handleBackToLogIn,
        ),
      ),
    );
  }

  void _handleSubmit() {
    ref
        .read(forgotPasswordFormProvider.notifier)
        .submit(email: _emailController.text);
  }

  void _handleBackToLogIn() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/login');
    }
  }
}
