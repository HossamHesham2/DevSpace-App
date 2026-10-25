import 'package:bloc/bloc.dart';
import 'package:dev_space/features/profile/domain/entities/github_profile_entity.dart';
import 'package:dev_space/features/profile/domain/usecases/get_github_profile_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'profile_state.dart';
@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final GetGithubProfileUseCase _getGithubProfileUseCase;

  ProfileCubit({required this._getGithubProfileUseCase})
    : super(ProfileInitial());

  Future<void> getProfile(String username) async {
    emit(ProfileLoading());
    final result = await _getGithubProfileUseCase(username);
    result.fold(
      (failure) {
        emit(ProfileError(failure.errorMessage));
      },
      (profile) {
        emit(ProfileLoaded(profile));
      },
    );
  }
}
