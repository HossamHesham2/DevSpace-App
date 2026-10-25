import 'package:dev_space/core/router/route_names.dart';
import 'package:dev_space/core/widgets/app_snackbar.dart';
import 'package:dev_space/core/widgets/d_scaffold.dart';
import 'package:dev_space/core/widgets/primary_button.dart';
import 'package:dev_space/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:dev_space/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.goNamed(RouteNames.auth);
          return;
        }

        if (state is AuthError) {
          AppSnackBar.error(context, state.message, title: 'Sign out failed');
        }
      },
      child: DScaffold(
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final isSigningOut = state is AuthLoading;

            return Column(
              children: [
                _SettingsHeader(),
                Spacer(),
                PrimaryButton(
                  text: "LogOut",
                  icon: Icon(Icons.logout),
                  isLoading: isSigningOut,
                  onPressed: isSigningOut
                      ? null
                      : () {
                          context.read<AuthCubit>().signOut();
                        },
                ),
                SizedBox(height: 20.h),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Row(
      children: [
        IconButton(
          iconSize: 35,
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.chevron_left_outlined, color: colors.onSurface),
        ),
        SizedBox(width: 16.w),
        Text(
          'Settings',
          style: text.headlineMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
