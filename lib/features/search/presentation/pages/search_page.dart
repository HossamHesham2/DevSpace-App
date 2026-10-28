import 'dart:async';

import 'package:dev_space/core/di/dependency_injection.dart';
import 'package:dev_space/core/models/user_model.dart';
import 'package:dev_space/core/widgets/custom_text_field.dart';
import 'package:dev_space/core/widgets/d_scaffold.dart';
import 'package:dev_space/core/widgets/repository_card.dart';
import 'package:dev_space/core/widgets/secondary_button.dart';
import 'package:dev_space/features/search/presentation/cubit/search_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SearchCubit>(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  static const Duration _debounceDuration = Duration(milliseconds: 450);

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _debounce;
  SearchMode _mode = SearchMode.repositories;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();

    // Rebuild so the clear button reflects whether there is any text.
    setState(() {});

    final query = value.trim();

    if (query.isEmpty) {
      context.read<SearchCubit>().reset();
      return;
    }

    _debounce = Timer(_debounceDuration, () {
      if (!mounted) return;
      _search(query, _mode);
    });
  }

  void _submit() {
    _debounce?.cancel();
    FocusScope.of(context).unfocus();

    final query = _controller.text.trim();

    if (query.isEmpty) {
      context.read<SearchCubit>().reset();
      return;
    }

    _search(query, _mode);
  }

  void _search(String query, SearchMode mode) {
    _debounce?.cancel();

    if (mode != _mode) {
      setState(() => _mode = mode);
    }

    final cubit = context.read<SearchCubit>();

    if (mode == SearchMode.repositories) {
      cubit.searchRepositories(query);
    } else {
      cubit.searchUsers(query);
    }
  }

  void _selectMode(SearchMode mode) {
    if (mode == _mode) return;

    setState(() => _mode = mode);

    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      _search(query, mode);
    }
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    setState(() {});
    context.read<SearchCubit>().reset();
    _focusNode.requestFocus();
  }

  Future<void> _openProfile(UserModel user) async {
    final rawUrl = user.htmlUrl.trim().isNotEmpty
        ? user.htmlUrl.trim()
        : 'https://github.com/${user.username}';
    final url = Uri.tryParse(rawUrl);

    if (url != null && (url.scheme == 'https' || url.scheme == 'http')) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DScaffold(
      body: ListView(
        padding: EdgeInsets.only(bottom: 24.h),
        children: [
          const _SearchHeader(),
          SizedBox(height: 10.h),
          CustomTextField(
            controller: _controller,
            focusNode: _focusNode,
            hintText: 'Search repositories, developers, topics...',
            textInputAction: TextInputAction.search,
            onChanged: _onQueryChanged,
            onFieldSubmitted: (_) => _submit(),
            prefix: Icon(Icons.search, size: 18.sp),
            suffix: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_controller.text.isNotEmpty)
                  IconButton(
                    onPressed: _clear,
                    tooltip: 'Clear search',
                    icon: Icon(Icons.close_rounded, size: 18.sp),
                  ),
                IconButton(
                  onPressed: _submit,
                  tooltip: 'Search',
                  icon: Icon(Icons.arrow_forward_rounded, size: 18.sp),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          _ModeSelector(mode: _mode, onChanged: _selectMode),
          SizedBox(height: 16.h),
          BlocBuilder<SearchCubit, SearchState>(
            builder: (context, state) {
              return _SearchResults(
                state: state,
                onRetry: _search,
                onOpenProfile: _openProfile,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Text(
      'Search',
      style: text.headlineMedium?.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.mode, required this.onChanged});

  final SearchMode mode;
  final ValueChanged<SearchMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          _ModeTab(
            label: 'Repositories',
            icon: Icons.folder_outlined,
            selected: mode == SearchMode.repositories,
            onTap: () => onChanged(SearchMode.repositories),
          ),
          SizedBox(width: 4.w),
          _ModeTab(
            label: 'Developers',
            icon: Icons.people_outline_rounded,
            selected: mode == SearchMode.users,
            onTap: () => onChanged(SearchMode.users),
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final foreground = selected ? colors.onPrimary : colors.onSurfaceVariant;

    return Expanded(
      child: Material(
        color: selected ? colors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(10.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18.sp, color: foreground),
                SizedBox(width: 6.w),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.labelLarge?.copyWith(
                      color: foreground,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.state,
    required this.onRetry,
    required this.onOpenProfile,
  });

  final SearchState state;
  final void Function(String query, SearchMode mode) onRetry;
  final Future<void> Function(UserModel user) onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final current = state;

    if (current is SearchLoadingState) {
      return _StatusCard(
        icon: Icons.manage_search_rounded,
        title: current.mode == SearchMode.repositories
            ? 'Searching repositories'
            : 'Searching developers',
        message: 'Looking for "${current.query}"...',
        isLoading: true,
      );
    }

    if (current is SearchErrorState) {
      return _StatusCard(
        icon: Icons.cloud_off_rounded,
        title: 'Search failed',
        message: current.errorMessage,
        isError: true,
        actionLabel: 'Retry',
        onAction: () => onRetry(current.query, current.mode),
      );
    }

    if (current is LoadedRepositories) {
      if (current.repositories.isEmpty) {
        return _StatusCard(
          icon: Icons.search_off_rounded,
          title: 'No repositories found',
          message: 'No repositories matched "${current.query}".',
        );
      }

      return _ResultsSection(
        title: 'Repositories',
        subtitle:
            '${current.repositories.length} results for '
            '"${current.query}"',
        children: [
          for (final repository in current.repositories)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: RepositoryCard(repository: repository),
            ),
        ],
      );
    }

    if (current is LoadedUsers) {
      if (current.users.isEmpty) {
        return _StatusCard(
          icon: Icons.person_search_rounded,
          title: 'No developers found',
          message: 'No developers matched "${current.query}".',
        );
      }

      return _ResultsSection(
        title: 'Developers',
        subtitle: '${current.users.length} results for "${current.query}"',
        children: [
          for (final user in current.users)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _UserResultCard(
                user: user,
                onOpenProfile: () => onOpenProfile(user),
              ),
            ),
        ],
      );
    }

    return const _StatusCard(
      icon: Icons.travel_explore_rounded,
      title: 'Start searching',
      message:
          'Find repositories and developers on GitHub by name, topic, or '
          'keyword.',
    );
  }
}

class _ResultsSection extends StatelessWidget {
  const _ResultsSection({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: text.titleMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
        SizedBox(height: 12.h),
        ...children,
      ],
    );
  }
}

class _UserResultCard extends StatelessWidget {
  const _UserResultCard({required this.user, required this.onOpenProfile});

  final UserModel user;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final hasAvatar = user.avatarUrl.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundColor: colors.surfaceContainerHighest,
            foregroundImage: hasAvatar ? NetworkImage(user.avatarUrl) : null,
            onForegroundImageError: hasAvatar ? (_, _) {} : null,
            child: Icon(
              Icons.person_rounded,
              size: 24.r,
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username.isEmpty ? 'Unknown developer' : user.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  user.type.isEmpty ? 'GitHub developer' : user.type,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          SecondaryButton(
            text: 'Profile',
            onPressed: onOpenProfile,
            borderColor: colors.primary,
            borderRadius: 999,
            width: 92,
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.title,
    required this.message,
    this.isError = false,
    this.isLoading = false,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool isError;
  final bool isLoading;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(28.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          if (isLoading)
            SizedBox(
              width: 28.r,
              height: 28.r,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colors.primary,
              ),
            )
          else
            Icon(
              icon,
              size: 34.r,
              color: isError ? colors.error : colors.onSurfaceVariant,
            ),
          SizedBox(height: 12.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: text.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          if (actionLabel != null) ...[
            SizedBox(height: 16.h),
            SecondaryButton(
              text: actionLabel!,
              onPressed: onAction,
              borderColor: colors.primary,
              width: 140,
            ),
          ],
        ],
      ),
    );
  }
}
