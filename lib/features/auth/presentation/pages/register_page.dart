import 'package:dev_space/core/constants/app_assets.dart';
import 'package:dev_space/core/helpers/validators.dart';
import 'package:dev_space/core/router/route_names.dart';
import 'package:dev_space/core/widgets/app_snackbar.dart';
import 'package:dev_space/core/widgets/custom_text_field.dart';
import 'package:dev_space/core/widgets/primary_button.dart';
import 'package:dev_space/core/widgets/secondary_button.dart';
import 'package:dev_space/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:dev_space/features/auth/presentation/cubit/auth_state.dart';
import 'package:dev_space/features/auth/presentation/widgets/auth_page_layout.dart';
import 'package:dev_space/features/auth/presentation/widgets/password_strength_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;
  bool _showTermsError = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  void _toggleTerms(bool? value) {
    setState(() {
      _acceptedTerms = value ?? false;
      if (_acceptedTerms) {
        _showTermsError = false;
      }
    });
  }

  void _createAccount() {
    FocusScope.of(context).unfocus();

    final fieldsValid = _formKey.currentState?.validate() ?? false;
    final termsValid = _acceptedTerms;

    if (!termsValid) {
      setState(() {
        _showTermsError = true;
      });
    }

    if (!fieldsValid || !termsValid) return;
    context.read<AuthCubit>().signUp(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _continueWithGitHub() {
    FocusScope.of(context).unfocus();
  }

  void _goToLogin() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        setState(() {
          _isLoading = state is AuthLoading;
        });

        if (state is AuthError) {
          AppSnackBar.error(
            context,
            state.message,
            title: 'Sign Up failed',
          );
        } else if (state is AuthEmailVerificationRequired) {
          AppSnackBar.success(
            context,
            'Account created! Please check your email to verify your account.',
            title: 'Verify your email',
          );
        }
      },
  child: AuthPageLayout(
      badge: 'auth.register:v1',
      title: 'Create your account',
      subtitle:
          'Join the developer services and discover breakthrough open-source '
          'software.',
      form: AutofillGroup(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Full name',
                hintText: 'Enter your full name',
                controller: _fullNameController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                validator: Validators.fullName,
                prefix: Icon(Icons.person_outline_rounded, size: 20.r),
                onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                label: 'Email address',
                hintText: 'you@example.com',
                controller: _emailController,
                focusNode: _emailFocusNode,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: Validators.email,
                prefix: Icon(Icons.email_outlined, size: 20.r),
                onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                label: 'Password',
                hintText: 'Create a password',
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                obscureText: _obscurePassword,
                enableSuggestions: false,
                validator: Validators.password,
                prefix: Icon(Icons.lock_outline_rounded, size: 20.r),
                onFieldSubmitted: (_) =>
                    _confirmPasswordFocusNode.requestFocus(),
                suffix: IconButton(
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20.r,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _passwordController,
                builder: (context, value, _) {
                  return PasswordStrengthIndicator(password: value.text);
                },
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                label: 'Confirm password',
                hintText: 'Re-enter your password',
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocusNode,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                obscureText: _obscureConfirmPassword,
                enableSuggestions: false,
                validator: _validateConfirmPassword,
                prefix: Icon(Icons.lock_outline_rounded, size: 20.r),
                onFieldSubmitted: (_) => _createAccount(),
                suffix: IconButton(
                  tooltip: _obscureConfirmPassword
                      ? 'Show password'
                      : 'Hide password',
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20.r,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Material(
                type: MaterialType.transparency,
                child: CheckboxListTile(
                  value: _acceptedTerms,
                  onChanged: _toggleTerms,
                  title: Text(
                    'I accept the terms and conditions',
                    style: text.bodySmall,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              if (_showTermsError)
                Padding(
                  padding: EdgeInsets.only(left: 12.w, top: 2.h),
                  child: Text(
                    'Please accept the terms and conditions to continue.',
                    style: text.bodySmall?.copyWith(color: colors.error),
                  ),
                ),
              SizedBox(height: 8.h),
              PrimaryButton(
                text: 'Create account',
                icon: const Icon(Icons.arrow_forward_rounded),
                onPressed: _createAccount,
                isLoading: _isLoading,
              ),
              SizedBox(height: 20.h),
              const AuthDivider(label: 'OR REGISTER WITH'),
              SizedBox(height: 16.h),
              SecondaryButton(
                text: 'Continue with GitHub',
                icon: SvgPicture.asset(
                  AppSvgs.githubIcon,
                  width: 20.r,
                  height: 20.r,
                  colorFilter: ColorFilter.mode(
                    colors.onSurface,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: _continueWithGitHub,
              ),
            ],
          ),
        ),
      ),
      footer: AuthFooterPrompt(
        prompt: 'Already have an account?',
        actionLabel: 'Sign in',
        onPressed: _goToLogin,
      ),
    ),
);
  }
}
