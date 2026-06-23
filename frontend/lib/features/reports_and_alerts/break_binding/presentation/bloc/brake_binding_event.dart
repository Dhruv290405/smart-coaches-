import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../data/models/coach_by_location_response.dart';

abstract class BrakeBindingEvent extends Equatable {
  const BrakeBindingEvent();

  @override
  List<Object?> get props => [];
}

class LoadInitData extends BrakeBindingEvent {}

class SelectCoach extends BrakeBindingEvent {
  final CoachByLocationItem coach;
  const SelectCoach(this.coach);

  @override
  List<Object?> get props => [coach.deviceId];
}

class SelectDevice extends BrakeBindingEvent {
  final String deviceId;
  const SelectDevice(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

class TogglePressureFilter extends BrakeBindingEvent {
  final String pressureType; // "BP", "FP", "BC", "CR", "ALL"
  const TogglePressureFilter(this.pressureType);

  @override
  List<Object?> get props => [pressureType];
}

class ChangeTimeFilter extends BrakeBindingEvent {
  final String timeFilter; // "15s", "1m", "10m", "1h", "24h"
  const ChangeTimeFilter(this.timeFilter);

  @override
  List<Object?> get props => [timeFilter];
}

class ChangeDateRange extends BrakeBindingEvent {
  final DateTimeRange range;
  const ChangeDateRange(this.range);

  @override
  List<Object?> get props => [range];
}

class UpdatePneumaticData extends BrakeBindingEvent {
  final double bp;
  final double fp;
  final double bc;
  final double cr;
  final String status;
  final DateTime time;
  final String duration;

  const UpdatePneumaticData({
    required this.bp,
    required this.fp,
    required this.bc,
    required this.cr,
    required this.status,
    required this.time,
    required this.duration,
  });

  @override
  List<Object?> get props => [bp, fp, bc, cr, status, time, duration];
}

class FetchPneumaticStatus extends BrakeBindingEvent {
  final String? trainNo;
  final String? coachNo;
  final String? deviceId;

  const FetchPneumaticStatus({this.trainNo, this.coachNo, this.deviceId});

  @override
  List<Object?> get props => [trainNo, coachNo, deviceId];
}

class FetchHistoryData extends BrakeBindingEvent {
  final String? deviceId;
  final DateTimeRange? range;
  final bool isBackground;
  final int? limit;
  const FetchHistoryData({this.deviceId, this.range, this.isBackground = false, this.limit});

  @override
  List<Object?> get props => [deviceId, range, isBackground, limit];
}

class ResetHistoryFilters extends BrakeBindingEvent {}

class ShowMoreHistory extends BrakeBindingEvent {}