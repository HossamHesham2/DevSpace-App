import 'dart:async';

import 'package:dev_space/core/constants/app_constants.dart';
import 'package:dev_space/core/extensions/color_extension.dart';
import 'package:dev_space/core/helpers/validators.dart';
import 'package:dev_space/core/router/route_names.dart';
import 'package:dev_space/core/widgets/app_snackbar.dart';
import 'package:dev_space/core/widgets/primary_button.dart';
import 'package:dev_space/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:dev_space/features/auth/presentation/cubit/auth_state.dart';
import 'package:dev_space/features/auth/presentation/widgets/auth_page_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Password recovery screen.
///
/// Collects the account email, delegates the recovery request to
/// [AuthCubit] (which talks to Supabase Auth through the repository layer) and
/// exposes a resend cooldown after every successful request.
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({
    super.key,
    this.initialEmail,
    this.resendCooldown = const Duration(seconds: 60),
    this.now,
  });

  /// Email carried over from the sign-in screen, if available.
  final String? initialEmail;

  /// How long the user has to wait before a token can be resent.
  final Duration resendCooldown;

  /// Injectable clock used by the resend cooldown.
  ///
  /// Defaults to [DateTime.now]. It exists so tests can advance time without
  /// relying on wall-clock delays.
  final DateTime Function()? now;

  static const String badgeLabel = 'auth.recovery:v2';

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  Timer? _countdownTimer;
  DateTime? _resendAvailableAt;
  String? _sentEmail;
  String? _pendingEmail;
  bool _isSubmitting = false;
  bool _showSuccess = false;

  DateTime get _now => widget.now?.call() ?? DateTime.now();

  Duration get _remainingCooldown {
    final deadline = _resendAvailableAt;
    if (deadline == null) return Duration.zero;

    final remaining = deadline.difference(_now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get _isCooldownActive => _remainingCooldown > Duration.zero;

  @override
  void initState() {
    super.initState();

    final initialEmail = widget.initialEmail?.trim();
    if (initialEmail != null && initialEmail.isNotEmpty) {
      _emailController.text = initialEmail;
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _handleAuthStateChange(AuthState state) {
    if (state is AuthPasswordResetEmailSent) {
      if (!mounted) return;

      final email = _pendingEmail ?? _emailController.text.trim();

      setState(() {
        _isSubmitting = false;
        _showSuccess = true;
        _sentEmail = email;
        _startCooldown();
      });
    } else if (state is AuthError) {
      if (!mounted) return;

      setState(() => _isSubmitting = false);

      AppSnackBar.error(context, state.message, title: 'Recovery failed');
    }
  }

  void _startCooldown() {
    _countdownTimer?.cancel();
    _resendAvailableAt = _now.add(widget.resendCooldown);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final deadline = _resendAvailableAt;
      if (deadline == null || !deadline.isAfter(_now)) {
        timer.cancel();
        if (identical(_countdownTimer, timer)) {
          _countdownTimer = null;
        }
        setState(() => _resendAvailableAt = null);
        return;
      }

      setState(() {});
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final email = _emailController.text.trim();

    setState(() {
      _isSubmitting = true;
      _showSuccess = false;
      _sentEmail = null;
      _pendingEmail = email;
      _resendAvailableAt = null;
      _countdownTimer?.cancel();
      _countdownTimer = null;
    });

    await context.read<AuthCubit>().sendPasswordResetEmail(email: email);

    // The cubit emits success/error before this future completes, but guard
    // against any other auth event leaving the button stuck in loading.
    if (!mounted || !_isSubmitting) return;
    setState(() => _isSubmitting = false);
  }

  Future<void> _resend() async {
    if (_isSubmitting || _isCooldownActive) return;

    final email = _sentEmail ?? _emailController.text.trim();

    if (Validators.email(email) != null) {
      AppSnackBar.warning(
        context,
        'Add a valid email address before requesting another link.',
        title: 'Invalid email',
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
      _pendingEmail = email;
    });

    await context.read<AuthCubit>().sendPasswordResetEmail(email: email);

    if (!mounted || !_isSubmitting) return;
    setState(() => _isSubmitting = false);
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(RouteNames.login);
    }
  }

  void _goToLogin() => _handleBack();

  String _formatRemaining() {
    final totalSeconds = _remainingCooldown.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) => _handleAuthStateChange(state),
      child: AuthPageLayout(
        badge: ResetPasswordPage.badgeLabel,
        title: 'Reset Your Password',
        subtitle:
            "Enter your registered email address and we'll send a cryptographic "
            'recovery token or reset link to restore your access.',
        form: AutofillGroup(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _RecoveryFieldLabels(),
                SizedBox(height: 8.h),
                _RecoveryEmailField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  enabled: !_isSubmitting,
                  onSubmitted: (_) => _submit(),
                ),
                SizedBox(height: 20.h),
                PrimaryButton(
                  text: 'Send Reset Link',
                  icon: const Icon(Icons.arrow_forward_rounded),
                  onPressed: _submit,
                  isLoading: _isSubmitting,
                ),
                if (_showSuccess) ...[
                  SizedBox(height: 16.h),
                  _SuccessBanner(email: _sentEmail ?? ''),
                  SizedBox(height: 12.h),
                  _ResendPanel(
                    remainingLabel: _isCooldownActive
                        ? _formatRemaining()
                        : null,
                    isSending: _isSubmitting,
                    onResend: _resend,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Recovery links are generated and verified by Supabase '
                    "Auth. If the email doesn't arrive, check your spam folder "
                    'or resend the token above.',
                    textAlign: TextAlign.center,
                    style: text.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
                SizedBox(height: 24.h),
                Text(
                  'ALTERNATIVE CHANNELS',
                  style: text.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10.h),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cards = [
                      const _UnavailableMethodCard(
                        icon: Icons.fingerprint_rounded,
                        label: 'HARDWARE KEY',
                        value: 'WebAuthn / FIDO2',
                      ),
                      const _UnavailableMethodCard(
                        icon: Icons.terminal_rounded,
                        label: 'CLI FALLBACK',
                        value: 'devspace auth',
                      ),
                    ];

                    if (constraints.maxWidth < 360) {
                      return Column(
                        children: [
                          cards[0],
                          SizedBox(height: 10.h),
                          cards[1],
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: cards[0]),
                        SizedBox(width: 10.w),
                        Expanded(child: cards[1]),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        footer: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            AuthFooterPrompt(
              prompt: 'Remembered your password?',
              actionLabel: 'Back to sign in',
              onPressed: _goToLogin,
            ),
            SizedBox(height: 4.h),
            Text(
              '${AppConstants.appName} v${AppConstants.appVersion}',
              style: text.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The two monospaced labels shown above the email field.
class _RecoveryFieldLabels extends StatelessWidget {
  const _RecoveryFieldLabels();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final labelStyle = text.labelSmall?.copyWith(
      letterSpacing: 0.9,
      fontWeight: FontWeight.w700,
    );

    return Row(
      children: [
        Expanded(
          child: Text(
            'REGISTERED IDENTIFIER',
            style: labelStyle?.copyWith(color: colors.onSurfaceVariant),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          'SECURE_CHANNEL',
          style: labelStyle?.copyWith(color: colors.primary),
        ),
      ],
    );
  }
}

/// Email input styled for the recovery screen, including the GPG badge.
class _RecoveryEmailField extends StatelessWidget {
  const _RecoveryEmailField({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;

    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.06),
            blurRadius: 18.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.email],
        autocorrect: false,
        enableSuggestions: false,
        validator: Validators.email,
        onFieldSubmitted: onSubmitted,
        style: text.bodyLarge?.copyWith(color: colors.onSurface),
        decoration: InputDecoration(
          hintText: 'you@example.com',
          hintStyle: text.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(
            Icons.alternate_email_rounded,
            size: 20.r,
            color: colors.onSurfaceVariant,
          ),
          suffixIcon: Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Center(
              widthFactor: 1,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 12.r,
                      color: colors.primary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'GPG',
                      style: text.labelSmall?.copyWith(
                        color: colors.primary,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          filled: true,
          fillColor: enabled
              ? colors.surface
              : colors.surfaceContainerHighest.withValues(alpha: 0.6),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
          enabledBorder: border(colors.outlineVariant),
          disabledBorder: border(colors.outlineVariant.withValues(alpha: 0.6)),
          focusedBorder: border(colors.primary, width: 2),
          errorBorder: border(colors.error),
          focusedErrorBorder: border(colors.error, width: 2),
        ),
      ),
    );
  }
}

/// Green confirmation banner shown after a successful recovery request.
class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final success = isDark ? colors.successDark : colors.success;
    final background = Color.alphaBlend(
      success.withValues(alpha: isDark ? 0.14 : 0.08),
      colors.surface,
    );

    return Semantics(
      liveRegion: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 12 * (1 - value)),
              child: child,
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: ColoredBox(
            color: background,
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 14.w, 14.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 30.r,
                            height: 30.r,
                            decoration: BoxDecoration(
                              color: success.withValues(alpha: 0.16),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: 18.r,
                              color: success,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'DISPATCH COMPLETED',
                              style: text.labelSmall?.copyWith(
                                color: success,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.verified_rounded,
                            size: 16.r,
                            color: success.withValues(alpha: 0.8),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text.rich(
                        TextSpan(
                          text: 'Verification email dispatched to ',
                          children: [
                            TextSpan(
                              text: email,
                              style: TextStyle(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const TextSpan(
                              text: '. Check your inbox or spam folder.',
                            ),
                          ],
                        ),
                        style: text.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 4,
                  child: ColoredBox(color: success),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Cooldown / resend row shown below the success banner.
class _ResendPanel extends StatelessWidget {
  const _ResendPanel({
    required this.remainingLabel,
    required this.isSending,
    required this.onResend,
  });

  /// `null` when the cooldown has expired.
  final String? remainingLabel;
  final bool isSending;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    final coolingDown = remainingLabel != null;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            coolingDown ? Icons.timer_outlined : Icons.refresh_rounded,
            size: 18.r,
            color: coolingDown ? colors.onSurfaceVariant : colors.primary,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              coolingDown
                  ? 'Resend token in $remainingLabel'
                  : 'Token ready to resend',
              style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ),
          if (isSending)
            SizedBox(
              width: 16.r,
              height: 16.r,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.primary,
              ),
            )
          else if (!coolingDown)
            TextButton(
              onPressed: onResend,
              style: TextButton.styleFrom(
                foregroundColor: colors.primary,
                minimumSize: const Size(0, 36),
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                textStyle: text.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              child: const Text('Resend'),
            ),
        ],
      ),
    );
  }
}

/// Informational card for auth methods this build does not configure.
class _UnavailableMethodCard extends StatelessWidget {
  const _UnavailableMethodCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;

    return Semantics(
      enabled: false,
      label: '$label, $value, not configured',
      child: Opacity(
        opacity: 0.62,
        child: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 34.r,
                height: 34.r,
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Icon(icon, size: 18.r, color: colors.onSurfaceVariant),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: text.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(color: colors.onSurface),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6.w),
              Tooltip(
                message: 'Not configured in this build',
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 14.r,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
