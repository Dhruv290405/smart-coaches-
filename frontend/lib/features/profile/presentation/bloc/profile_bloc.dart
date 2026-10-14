import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/permissions/bloc/permission_bloc.dart';
import 'package:smart_coach_new/core/permissions/bloc/permission_event.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';
import 'package:smart_coach_new/features/profile/domain/usecases/profile_usecase.dart';
import 'package:smart_coach_new/services/fcm_service.dart';
import 'package:http/http.dart' as http;
import 'package:smart_coach_new/core/network/api_constants.dart';
import 'package:smart_coach_new/features/profile/presentation/bloc/profile_event.dart';
import 'package:smart_coach_new/features/profile/presentation/bloc/profile_state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileUseCase profileUseCase;
  final Prefs prefs;
  final PermissionBloc permissionBloc;

  ProfileBloc({
    required this.profileUseCase,
    required this.prefs,
    required this.permissionBloc,
  }) : super(ProfileInitial()) {
    on<FetchProfile>(_onFetchProfile);
    on<LogoutRequested>(_onLogoutRequested);
  }

  void _onFetchProfile(FetchProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final (profile, message) = await profileUseCase();

      // Update permissions based on profile role
      permissionBloc.add(UpdatePermissions(
        roleId: profile.roleId,
        roleName: null, // You can add roleName from profile if available
      ));
    
      emit(ProfileLoaded(profile, message));
    } catch (e) {
      emit(ProfileFailure(message: e.toString()));
    }
  }

  void _onLogoutRequested(
      LogoutRequested event, Emitter<ProfileState> emit) async {
    try {
      final token = prefs.token;
      final fcmToken = await FCMService.getToken();
      if (token != null && fcmToken != null) {
        await http.delete(Uri.parse('${ApiConstants.devUrl}/fcm/fcm-token'), headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}, body: '{"fcm_token":"$fcmToken"}');
      }
      await prefs.clear();

      // Clear permissions on logout
      permissionBloc.add(const ClearPermissions());

      emit(ProfileLogoutSuccess());
    } catch (e) {
      emit(ProfileFailure(message: e.toString()));
    }
  }
}