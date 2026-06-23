import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../data/models/coach_by_location_response.dart';
import '../../data/models/pneumatic_status_model.dart';

class BrakeBindingState extends Equatable {
  final List<CoachByLocationItem> coachList;
  final CoachByLocationItem? selectedCoach;
  // kept for backward compat — derived from selectedCoach
  final List<String>? deviceList;
  final String? selectedDeviceId;
  final Map<String, String>? diagnosticFlags;
  
  // High-fidelity UI fields
  final String? status;
  final DateTime? statusTime;
  final String? statusDuration;
  final double bpValue;
  final double fpValue;
  final double bcValue;
  final double crValue;

  final bool isLoadingCoaches;

  // Real API status
  final bool isLoadingPneumatic;
  final PneumaticStatusResponse? pneumaticStatus;

  // Graph and Analysis
  final List<PneumaticReadings> readingsHistory;
  final String? localAnomaly;

  // Graph Filters
  final bool showBP;
  final bool showFP;
  final bool showBC;
  final bool showCR;
  final String timeFilter; // "15s", "1m", "10m", "1h", "24h", "RANGE"
  final DateTimeRange? selectedDateRange;

  // History specific
  final PneumaticStatusResponse? historyPneumaticStatus;
  final bool isLoadingHistory;
  final String? historyDeviceId;
  final DateTimeRange? historyDateRange;
  final int historyLimit;

  const BrakeBindingState({
    this.coachList = const [],
    this.selectedCoach,
    this.deviceList,
    this.selectedDeviceId,
    this.isLoadingCoaches = false,
    this.status = "NORMAL",
    this.statusTime,
    this.statusDuration = "0 sec",
    this.diagnosticFlags = const {
      "Brake Binding": "OK",
      "Pneumatic Leakage": "OK",
      "Brake Cylinder": "NORMAL",
      "CR Overcharge": "NORMAL",
    },
    this.bpValue = 0.0,
    this.fpValue = 0.0,
    this.bcValue = 0.0,
    this.crValue = 0.0,
    this.isLoadingPneumatic = false,
    this.pneumaticStatus,
    this.readingsHistory = const [],
    this.localAnomaly,
    this.showBP = true,
    this.showFP = true,
    this.showBC = true,
    this.showCR = true,
    this.timeFilter = "1m",
    this.selectedDateRange,
    // History specific
    this.historyPneumaticStatus,
    this.isLoadingHistory = false,
    this.historyDeviceId,
    this.historyDateRange,
    this.historyLimit = 10,
  });

  BrakeBindingState copyWith({
    List<CoachByLocationItem>? coachList,
    CoachByLocationItem? selectedCoach,
    bool? clearSelectedCoach,
    List<String>? deviceList,
    String? selectedDeviceId,
    bool? isLoadingCoaches,
    String? status,
    DateTime? statusTime,
    String? statusDuration,
    Map<String, String>? diagnosticFlags,
    double? bpValue,
    double? fpValue,
    double? bcValue,
    double? crValue,
    bool? isLoadingPneumatic,
    PneumaticStatusResponse? pneumaticStatus,
    List<PneumaticReadings>? readingsHistory,
    String? localAnomaly,
    bool? showBP,
    bool? showFP,
    bool? showBC,
    bool? showCR,
    String? timeFilter,
    DateTimeRange? selectedDateRange,
    PneumaticStatusResponse? historyPneumaticStatus,
    bool? isLoadingHistory,
    String? historyDeviceId,
    DateTimeRange? historyDateRange,
    int? historyLimit,
  }) {
    return BrakeBindingState(
      coachList: coachList ?? this.coachList,
      selectedCoach: (clearSelectedCoach == true) ? null : (selectedCoach ?? this.selectedCoach),
      deviceList: deviceList ?? this.deviceList,
      selectedDeviceId: selectedDeviceId ?? this.selectedDeviceId,
      isLoadingCoaches: isLoadingCoaches ?? this.isLoadingCoaches,
      status: status ?? this.status,
      statusTime: statusTime ?? this.statusTime,
      statusDuration: statusDuration ?? this.statusDuration,
      diagnosticFlags: diagnosticFlags ?? this.diagnosticFlags,
      bpValue: bpValue ?? this.bpValue,
      fpValue: fpValue ?? this.fpValue,
      bcValue: bcValue ?? this.bcValue,
      crValue: crValue ?? this.crValue,
      isLoadingPneumatic: isLoadingPneumatic ?? this.isLoadingPneumatic,
      pneumaticStatus: pneumaticStatus ?? this.pneumaticStatus,
      readingsHistory: readingsHistory ?? this.readingsHistory,
      localAnomaly: localAnomaly ?? this.localAnomaly,
      showBP: showBP ?? this.showBP,
      showFP: showFP ?? this.showFP,
      showBC: showBC ?? this.showBC,
      showCR: showCR ?? this.showCR,
      timeFilter: timeFilter ?? this.timeFilter,
      selectedDateRange: selectedDateRange ?? this.selectedDateRange,
      historyPneumaticStatus: historyPneumaticStatus ?? this.historyPneumaticStatus,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      historyDeviceId: historyDeviceId ?? this.historyDeviceId,
      historyDateRange: historyDateRange ?? this.historyDateRange,
      historyLimit: historyLimit ?? this.historyLimit,
    );
  }

  @override
  List<Object?> get props => [
    coachList,
    selectedCoach,
    isLoadingCoaches,
    deviceList,
    selectedDeviceId,
    status,
    statusTime,
    statusDuration,
    diagnosticFlags,
    bpValue,
    fpValue,
    bcValue,
    crValue,
    isLoadingPneumatic,
    pneumaticStatus,
    readingsHistory,
    localAnomaly,
    showBP,
    showFP,
    showBC,
    showCR,
    timeFilter,
    selectedDateRange,
    historyPneumaticStatus,
    isLoadingHistory,
    historyDeviceId,
    historyDateRange,
    historyLimit,
  ];
}
