import 'dart:async';
import 'dart:developer' as dev;
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/reports_and_alerts/break_binding/domain/usecases/break_binding_usecases.dart';
import '../../data/cache/brake_binding_cache.dart';
import '../../data/models/coach_by_location_response.dart';
import '../../data/models/pneumatic_status_model.dart';
import 'brake_binding_event.dart';
import 'brake_binding_state.dart';

@injectable
class BrakeBindingBloc extends Bloc<BrakeBindingEvent, BrakeBindingState> {
  final BreakBindingUsecases breakBindingUsecases;
  Timer? _timer;
  String? _currentDeviceId;

  // Analysis Variables
  DateTime? _bbStartTime;
  double _lastBP = 5.0;

  BrakeBindingBloc({required this.breakBindingUsecases}) : super(const BrakeBindingState()) {
    on<LoadInitData>(_onInitData);
    on<SelectCoach>(_onSelectCoach);
    on<SelectDevice>(_onSelectDevice);
    on<TogglePressureFilter>(_onTogglePressureFilter);
    on<ChangeTimeFilter>(_onChangeTimeFilter);
    on<ChangeDateRange>(_onChangeDateRange);
    on<UpdatePneumaticData>(_onUpdatePneumaticData);
    on<FetchPneumaticStatus>(_onFetchPneumaticStatus);
    on<FetchHistoryData>(_onFetchHistoryData);
    on<ResetHistoryFilters>(_onResetHistoryFilters);
    on<ShowMoreHistory>(_onShowMoreHistory);

    add(LoadInitData());
    _startAutoRefresh();
  }
  void _onShowMoreHistory(ShowMoreHistory event, Emitter<BrakeBindingState> emit) {
    final newLimit = state.historyLimit + 10;
    add(FetchHistoryData(
      deviceId: state.historyDeviceId,
      range: state.historyDateRange,
      limit: newLimit,
    ));
  }

  void _startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Live status: fires every second but _onFetchPneumaticStatus
      // returns instantly from cache (5s TTL) — API only hit when cache expires
      if (state.timeFilter != "RANGE" && !state.isLoadingHistory && state.historyPneumaticStatus == null) {
        add(FetchPneumaticStatus(deviceId: _currentDeviceId));
      }

      // History background refresh every 10s
      if (state.historyPneumaticStatus != null && state.historyDateRange == null && !state.isLoadingHistory) {
        if (timer.tick % 10 == 0) {
          add(FetchHistoryData(
            deviceId: state.historyDeviceId,
            isBackground: true,
            limit: state.historyLimit,
          ));
        }
      }

      // Coaches list: re-fetch silently every 5 min when cache expires
      if (timer.tick % 300 == 0 && !BrakeBindingCache.instance.hasValidCoaches) {
        add(LoadInitData());
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  Future<void> _onInitData(LoadInitData event, Emitter<BrakeBindingState> emit) async {
    final cache = BrakeBindingCache.instance;

    // Serve from cache immediately — no loading spinner
    final cachedCoaches = cache.coaches;
    if (cachedCoaches != null && cachedCoaches.isNotEmpty) {
      final firstCoach = cachedCoaches.first;
      final deviceId = firstCoach.deviceId?.toString();
      _currentDeviceId = deviceId;
      emit(state.copyWith(
        coachList: cachedCoaches,
        selectedCoach: firstCoach,
        selectedDeviceId: deviceId,
        isLoadingCoaches: false,
      ));
      // Also serve cached pneumatic status if available
      if (deviceId != null) {
        final cachedStatus = cache.getStatus(deviceId);
        if (cachedStatus != null) {
          _applyPneumaticResponse(cachedStatus, emit);
        }
      }
      add(FetchPneumaticStatus(deviceId: deviceId));
      return;
    }

    // No cache — show loading and hit API
    emit(state.copyWith(isLoadingCoaches: true));
    try {
      final List<CoachByLocationItem> coaches = await breakBindingUsecases.getCoachesByLocation();
      cache.setCoaches(coaches);
      if (coaches.isNotEmpty) {
        final firstCoach = coaches.first;
        final deviceId = firstCoach.deviceId?.toString();
        _currentDeviceId = deviceId;
        emit(state.copyWith(
          coachList: coaches,
          selectedCoach: firstCoach,
          selectedDeviceId: deviceId,
          isLoadingCoaches: false,
        ));
        add(FetchPneumaticStatus(deviceId: deviceId));
      } else {
        emit(state.copyWith(coachList: [], isLoadingCoaches: false));
      }
    } catch (e) {
      dev.log("❌ LoadInitData Error: $e");
      emit(state.copyWith(isLoadingCoaches: false));
    }
  }

  void _onSelectCoach(SelectCoach event, Emitter<BrakeBindingState> emit) {
    final deviceId = event.coach.deviceId?.toString();
    _currentDeviceId = deviceId;
    emit(state.copyWith(
      selectedCoach: event.coach,
      selectedDeviceId: deviceId,
      readingsHistory: [],
    ));
    // Serve cached status instantly if available
    if (deviceId != null) {
      final cached = BrakeBindingCache.instance.getStatus(deviceId);
      if (cached != null) _applyPneumaticResponse(cached, emit);
    }
    add(FetchPneumaticStatus(deviceId: deviceId));
  }

  void _onSelectDevice(SelectDevice event, Emitter<BrakeBindingState> emit) {
    _currentDeviceId = event.deviceId;
    emit(state.copyWith(
      selectedDeviceId: event.deviceId,
      readingsHistory: [],
    ));
    add(FetchPneumaticStatus(deviceId: event.deviceId));
  }

  void _onTogglePressureFilter(TogglePressureFilter event, Emitter<BrakeBindingState> emit) {
    if (event.pressureType == "ALL") {
      final bool currentlyAllOn = state.showBP && state.showFP && state.showBC && state.showCR;
      emit(state.copyWith(
        showBP: !currentlyAllOn,
        showFP: !currentlyAllOn,
        showBC: !currentlyAllOn,
        showCR: !currentlyAllOn,
      ));
    } else {
      switch (event.pressureType) {
        case "BP": emit(state.copyWith(showBP: !state.showBP)); break;
        case "FP": emit(state.copyWith(showFP: !state.showFP)); break;
        case "BC": emit(state.copyWith(showBC: !state.showBC)); break;
        case "CR": emit(state.copyWith(showCR: !state.showCR)); break;
      }
    }
  }

  void _onChangeTimeFilter(ChangeTimeFilter event, Emitter<BrakeBindingState> emit) async {
    emit(state.copyWith(timeFilter: event.timeFilter, selectedDateRange: null));
    add(FetchPneumaticStatus(deviceId: _currentDeviceId));
  }

  void _onChangeDateRange(ChangeDateRange event, Emitter<BrakeBindingState> emit) async {
    emit(state.copyWith(
      timeFilter: "RANGE",
      selectedDateRange: event.range,
    ));
    // Here we would fetch data for the specific range
    add(FetchPneumaticStatus(deviceId: _currentDeviceId));
  }

  void _onUpdatePneumaticData(UpdatePneumaticData event, Emitter<BrakeBindingState> emit) {
    emit(state.copyWith(
      bpValue: event.bp,
      fpValue: event.fp,
      bcValue: event.bc,
      crValue: event.cr,
      status: event.status,
      statusTime: event.time,
    ));
  }

  Future<void> _onFetchPneumaticStatus(FetchPneumaticStatus event, Emitter<BrakeBindingState> emit) async {
    final cache = BrakeBindingCache.instance;
    final deviceId = event.deviceId ?? _currentDeviceId;
    if (deviceId == null) return;

    // Serve stale cache instantly while fresh data loads in background
    final cached = cache.getStatus(deviceId);
    if (cached != null) {
      _applyPneumaticResponse(cached, emit);
      return; // timer will call again when cache expires
    }

    try {
      final response = await breakBindingUsecases.getPneumaticStatus(deviceId: deviceId, limit: 10);
      if (response.success) {
        cache.setStatus(deviceId, response);
        _applyPneumaticResponse(response, emit);
      }
    } catch (e) {
      dev.log("❌ BLoC Fetch Error: $e");
    }
  }

  void _applyPneumaticResponse(PneumaticStatusResponse response, Emitter<BrakeBindingState> emit) {
    final readings = response.readings ?? PneumaticReadings();

    final List<PneumaticReadings> newHistory = List.from(state.readingsHistory);
    newHistory.add(readings);

    int maxPoints = 60;
    switch (state.timeFilter) {
      case "15s": maxPoints = 15; break;
      case "1m":  maxPoints = 60; break;
      case "10m": maxPoints = 600; break;
      case "1h":  maxPoints = 3600; break;
      case "24h": maxPoints = 86400; break;
    }
    if (newHistory.length > maxPoints) newHistory.removeAt(0);

    String? anomaly;
    final double currentBP = readings.bp?.toDouble() ?? 5.0;
    if (_lastBP - currentBP >= 0.6) anomaly = "EMERGENCY BRAKE";
    _lastBP = currentBP;

    if ((readings.bc?.toDouble() ?? 0.0) > 0.0 && (readings.bp?.toDouble() ?? 0.0) >= 4.8) {
      _bbStartTime ??= DateTime.now();
      if (DateTime.now().difference(_bbStartTime!).inSeconds > 20) anomaly = "BB SUSPECTED";
    } else {
      _bbStartTime = null;
    }
    if ((readings.bc?.toDouble() ?? 0.0) >= 3.1) anomaly = "SEVERE BB WARNING";

    String finalStatus = response.state ?? "NORMAL";
    if (finalStatus.toUpperCase() == "NORMAL" && anomaly != null) finalStatus = anomaly;

    final faults = response.activeFaults ?? [];
    final String activeFaultType =
        faults.isNotEmpty ? (faults[0].type?.toString().toUpperCase() ?? "") : "";

    final Map<String, String> diagFlags = {
      "Pneumatic Leakage":             activeFaultType == "PNEUMATIC LEAKAGE"   ? "DETECTED" : "OK",
      "Probably Brake Binding":        activeFaultType == "BRAKE BINDING"        ? "DETECTED" : "OK",
      "Probably Severe Brake Binding": activeFaultType == "SEVERE BRAKE BINDING" ? "DETECTED" : "OK",
      "CR Overcharge":                 activeFaultType == "CR OVERCHARGING"      ? "ALARM"    : "NORMAL",
      "DV/BC Defect":                  activeFaultType == "DV BC DEFECT"         ? "ALARM"    : "NORMAL",
      "Emergency Brake":               activeFaultType == "EMERGENCY BRAKE"      ? "ALARM"    : "NORMAL",
    };

    emit(state.copyWith(
      pneumaticStatus: response,
      readingsHistory: newHistory,
      bpValue: readings.bp?.toDouble() ?? 0.0,
      fpValue: readings.fp?.toDouble() ?? 0.0,
      bcValue: readings.bc?.toDouble() ?? 0.0,
      crValue: readings.cr?.toDouble() ?? 0.0,
      status: finalStatus.toUpperCase(),
      localAnomaly: anomaly,
      statusTime: DateTime.tryParse(response.lastUpdated ?? "") ?? DateTime.now(),
      statusDuration: "${readings.brakeDuration ?? 0} sec",
      diagnosticFlags: diagFlags,
    ));
  }

  Future<void> _onFetchHistoryData(FetchHistoryData event, Emitter<BrakeBindingState> emit) async {
    final int limit = event.limit ?? state.historyLimit;

    emit(state.copyWith(
      isLoadingHistory: !event.isBackground, 
      historyDeviceId: event.deviceId, 
      historyDateRange: event.range,
      historyLimit: limit,
    ));
    try {
      String? fromDate;
      String? toDate;
      if (event.range != null) {
        fromDate = DateFormat('yyyy-MM-dd').format(event.range!.start);
        toDate = DateFormat('yyyy-MM-dd').format(event.range!.end);
      }

      final response = await breakBindingUsecases.getPneumaticStatus(
        deviceId: event.deviceId,
        fromDate: fromDate,
        toDate: toDate,
        limit: limit,
      );

      emit(state.copyWith(
        historyPneumaticStatus: response,
        isLoadingHistory: false,
      ));
    } catch (e) {
      dev.log("❌ History Fetch Error: $e");
      emit(state.copyWith(isLoadingHistory: false));
    }
  }

  void _onResetHistoryFilters(ResetHistoryFilters event, Emitter<BrakeBindingState> emit) {
    emit(state.copyWith(
      historyPneumaticStatus: null,
      isLoadingHistory: false,
      historyDeviceId: null,
      historyDateRange: null,
      historyLimit: 10,
    ));
  }
}
