import 'package:smart_coach_new/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;
  final String message;

  ProfileLoaded(this.profile, this.message);
}

class ProfileFailure extends ProfileState {
  final String message;

  ProfileFailure({required this.message});
}

class ProfileLogoutSuccess extends ProfileState {}