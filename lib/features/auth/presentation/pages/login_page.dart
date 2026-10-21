import 'package:dev_space/core/constants/app_assets.dart';
import 'package:dev_space/core/helpers/validators.dart';
import 'package:dev_space/core/router/route_names.dart';
import 'package:dev_space/core/widgets/custom_text_field.dart';
import 'package:dev_space/core/widgets/primary_button.dart';
import 'package:dev_space/core/widgets/secondary_button.dart';
import 'package:dev_space/features/auth/presentation/widgets/auth_page_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _signIn() {
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    // PrimaryButton.isLoading.
  }

  void _forgotPassword() {
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Password reset is not available yet.')),
      );
  }

  void _continueWithGitHub() {
    FocusScope.of(context).unfocus();

  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return AuthPageLayout(
      badge: 'auth.login:v1',
      title: 'Welcome back',
      subtitle: 'Enter your credentials to access your DevSpace.',
      form: AutofillGroup(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Email address',
                hintText: 'you@example.com',
                controller: _emailController,
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
                hintText: 'Enter your password',
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                obscureText: _obscurePassword,
                enableSuggestions: false,
                validator: Validators.password,
                prefix: Icon(Icons.lock_outline_rounded, size: 20.r),
                onFieldSubmitted: (_) => _signIn(),
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
              SizedBox(height: 4.h),
              Row(
                children: [
                  Expanded(
                    child: Material(
                      type: MaterialType.transparency,
                      child: CheckboxListTile(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        title: Text('Remember me', style: text.bodySmall),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _forgotPassword,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.primary,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      minimumSize: const Size(0, 48),
                      textStyle: text.labelMedium,
                    ),
                    child: const Text('Forgot password?'),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              PrimaryButton(
                text: 'Sign in',
                icon: const Icon(Icons.arrow_forward_rounded),
                onPressed: _signIn,
              ),
              SizedBox(height: 20.h),
              const AuthDivider(label: 'OR CONTINUE WITH'),
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
        prompt: "Don't have an account?",
        actionLabel: 'Sign up',
        onPressed: () => context.pushNamed(RouteNames.register),
      ),
    );
  }
}
