import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();
}

class IdTypeToggled extends RegisterEvent {
  final bool isIdTypeIsPan;
  const IdTypeToggled(this.isIdTypeIsPan);
  @override
  List<Object?> get props => [isIdTypeIsPan];
}

class LoadZonesDropdowns extends RegisterEvent {
  @override
  List<Object?> get props => [];
}

class LoadDivisionsDropdowns extends RegisterEvent {
  final int zoneId;
  const LoadDivisionsDropdowns({required this.zoneId});
  @override
  List<Object?> get props => [];
}

class LoadRegionsDropdowns extends RegisterEvent {
  final int divisionId;
  const LoadRegionsDropdowns({required this.divisionId});
  @override
  List<Object?> get props => [];
}

class LoadAllRoles extends RegisterEvent {
  const LoadAllRoles();
  @override
  List<Object?> get props => [];
}

class LoadTrainsDropdowns extends RegisterEvent {
  final int? zoneId;
  final int? divisionId;
  final List<int>? regionId;
  const LoadTrainsDropdowns({
    required this.zoneId,
    required this.divisionId,
    required this.regionId,
  });
  @override
  List<Object?> get props => [];
}

class LoadRolesDropdowns extends RegisterEvent {
  final int? zoneId;
  final int? divisionId;
  final List<int>? regionId;
  final List<int>? trainIds;
  const LoadRolesDropdowns({
    required this.zoneId,
    required this.divisionId,
    required this.regionId,
    required this.trainIds,
  });
  @override
  List<Object?> get props => [zoneId, divisionId, regionId, trainIds];
} // class LoadRolesDropdowns extends RegisterEvent { //   int? zoneId; //   int? divisionId; //   List<int>? regionId; //   List<int>? trainIds; // //   LoadRolesDropdowns( //       {this.zoneId, this.divisionId, this.regionId, this.trainIds}); // //   @override //   List<Object?> get props => [zoneId, divisionId, regionId, trainIds]; // }

class UpdateDropdownValue extends RegisterEvent {
  final String key;
  final dynamic value; //int or string or list<int>
  const UpdateDropdownValue({required this.key, this.value});
  @override
  List<Object?> get props => [key, value];
}

class SubmitRegister extends RegisterEvent {
  const SubmitRegister();
  @override
  List<Object?> get props => [];
}

class SendOtp extends RegisterEvent {
  final String mobileNumber;
  const SendOtp(this.mobileNumber);
  @override
  List<Object?> get props => [mobileNumber];
}

class VerifyOtp extends RegisterEvent {
  final String mobileNumber;
  final String otp;
  const VerifyOtp(this.mobileNumber, this.otp);
  @override
  List<Object?> get props => [mobileNumber, otp];
}
