import 'dart:io';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_coach_new/core/utils/device_id_mapper.dart';
import '../data/models/pneumatic_status_model.dart';
import 'bloc/brake_binding_event.dart';
import 'bloc/brake_binding_state.dart';
import 'bloc/break_binding_bloc.dart';

class BrakeBindingHistoryScreen extends StatefulWidget {
  final String trainNo;
  final String deviceId;
  final List<PneumaticEvent>? initialEvents;
  final List<PneumaticHistoryData>? historyData;
  final List<PneumaticFault>? activeFaults;
  final int initialTabIndex;

  const BrakeBindingHistoryScreen({
    super.key,
    this.trainNo = "N/A",
    this.deviceId = "N/A",
    this.initialEvents,
    this.historyData,
    this.activeFaults,
    this.initialTabIndex = 0,
  });

  @override
  State<BrakeBindingHistoryScreen> createState() => _BrakeBindingHistoryScreenState();
}

class _BrakeBindingHistoryScreenState extends State<BrakeBindingHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late BrakeBindingBloc _bloc;
  String? _selectedDeviceId;
  DateTimeRange? _selectedDateRange;

  String _getActualId(String? deviceId) {
    if (deviceId == null) return 'N/A';
    final coaches = context.read<BrakeBindingBloc>().state.coachList;
    final match = coaches.where((c) => c.deviceId?.toString() == deviceId).firstOrNull;
    if (match != null && match.actualId != null) return match.actualId.toString();
    return DeviceIdMapper.resolve(deviceId);
  }

  @override
  void initState() {
    super.initState();
    _bloc = context.read<BrakeBindingBloc>();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
    _selectedDeviceId = null; // Default to 'All'
    
    // Trigger initial fetch from API
    WidgetsBinding.instance.addPostFrameCallback((_) {
       _bloc.add(FetchHistoryData(
         deviceId: _selectedDeviceId,
         range: _selectedDateRange,
       ));
    });
  }

  @override
  void dispose() {
    _bloc.add(ResetHistoryFilters());
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E293B),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
      _onFilterChanged();
    }
  }

  void _onFilterChanged() {
    context.read<BrakeBindingBloc>().add(FetchHistoryData(
      deviceId: _selectedDeviceId,
      range: _selectedDateRange,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<BrakeBindingBloc>().add(ResetHistoryFilters());
        }
      },
      child: BlocBuilder<BrakeBindingBloc, BrakeBindingState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF9FAFC),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF111111)),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                "Pneumatic Diagnostics",
                style: GoogleFonts.poppins(color: const Color(0xFF111111), fontSize: 16, fontWeight: FontWeight.w700),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.date_range, color: _selectedDateRange == null ? const Color(0xFF64748B) : const Color(0xFF1A9DF8)),
                  onPressed: _selectDateRange,
                ),
                if (_selectedDateRange != null)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red, size: 20),
                    onPressed: () {
                      setState(() => _selectedDateRange = null);
                      _onFilterChanged();
                    },
                  ),
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (ctx, _) {
                    final isHistoryTab = _tabController.index == 0;
                    final history = state.historyPneumaticStatus?.history?.data ?? [];
                    final faults = state.historyPneumaticStatus?.activeFaults ?? [];
                    final isEmpty = isHistoryTab ? history.isEmpty : faults.isEmpty;
                    return IconButton(
                      tooltip: 'Download Excel',
                      icon: const Icon(Icons.download, color: Color(0xFF059669)),
                      onPressed: isEmpty
                          ? null
                          : () {
                              if (isHistoryTab) {
                                _pickAndDownloadExcel(history);
                              } else {
                                _downloadFaultsExcel(faults);
                              }
                            },
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
              bottom: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF1A9DF8),
                unselectedLabelColor: const Color(0xFF64748B),
                indicatorColor: const Color(0xFF1A9DF8),
                indicatorWeight: 3,
                labelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700),
                tabs: const [
                  Tab(text: "LOG HISTORY"),
                  Tab(text: "ACTIVE FAULTS"),
                ],
              ),
            ),
            body: Column(
              children: [
                if (state.isLoadingHistory)
                  const LinearProgressIndicator(
                    color: Color(0xFF1A9DF8),
                    backgroundColor: Color(0xFFE0F2FE),
                    minHeight: 3,
                  ),
                _buildInfoBanner(state),
                if (_selectedDateRange != null || _selectedDeviceId != null)
                  _buildFilterChip(state),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLogHistoryTab(state),
                      _buildActiveFaultsTab(state),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(BrakeBindingState state) {
    final df = DateFormat('dd MMM');
    final parts = <String>[];
    if (_selectedDeviceId != null) {
      parts.add("Device: ${_getActualId(_selectedDeviceId)}");
    }
    if (_selectedDateRange != null) {
      parts.add("Date: ${df.format(_selectedDateRange!.start)} – ${df.format(_selectedDateRange!.end)}");
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFEFF6FF),
      child: Row(
        children: [
          const Icon(Icons.filter_alt, size: 14, color: Color(0xFF1A9DF8)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Filters: ${parts.join('  |  ')}",
              style: GoogleFonts.poppins(color: const Color(0xFF1A9DF8), fontSize: 11, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (state.isLoadingHistory)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A9DF8)),
            )
          else
            const Icon(Icons.check_circle, size: 14, color: Color(0xFF059669)),
        ],
      ),
    );
  }

  Future<void> _pickAndDownloadExcel(List<PneumaticHistoryData> allHistory) async {
    DateTimeRange? range = _selectedDateRange;

    if (range == null) {
      range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2024),
        lastDate: DateTime.now().add(const Duration(days: 1)),
        helpText: 'SELECT DATE RANGE FOR EXPORT',
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF1E293B),
                onPrimary: Colors.white,
                onSurface: Color(0xFF0F172A),
              ),
            ),
            child: child!,
          );
        },
      );
    }

    if (range == null) return;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
              SizedBox(width: 12),
              Text('Fetching data for download...'),
            ],
          ),
          duration: Duration(seconds: 30),
          backgroundColor: Color(0xFF1A9DF8),
        ),
      );
    }

    try {
      final fromDate = DateFormat('yyyy-MM-dd').format(range.start);
      final toDate = DateFormat('yyyy-MM-dd').format(range.end);

      // Fetch full data from API with date params and high limit
      final response = await _bloc.breakBindingUsecases.getPneumaticStatus(
        deviceId: _selectedDeviceId,
        fromDate: fromDate,
        toDate: toDate,
        limit: 10000,
      );

      if (mounted) ScaffoldMessenger.of(context).hideCurrentSnackBar();

      final fetched = response.history?.data ?? [];

      if (fetched.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No data found for selected date range'), backgroundColor: Colors.orange),
          );
        }
        return;
      }

      await _buildAndSaveExcel(fetched, range);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _buildAndSaveExcel(List<PneumaticHistoryData> history, DateTimeRange range) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['History'];
    excel.setDefaultSheet('History');
    for (final s in excel.sheets.keys.toList()) {
      if (s != 'History') excel.delete(s);
    }
    final df = DateFormat('dd/MM/yyyy');

    // Title row
    sheet.appendRow([TextCellValue('Brake Binding History — ${df.format(range.start)} to ${df.format(range.end)}')]);
    sheet.appendRow([TextCellValue('')]);

    // Header row — same order as table
    final headers = [
      'SR. NO', 'TIMESTAMP', 'DEVICE ID', 'TRAIN NO', 'LOCATION',
      'BP', 'FP', 'CR', 'BC', 'BRAKE STATUS',
      'BRAKE APPLIED TIME', 'BRAKE RELEASED TIME', 'BRAKE DURATION', 'BRAKE FAULT'
    ];
    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    for (int i = 0; i < history.length; i++) {
      final item = history[i];
      String timestampStr = '';
      try {
        final dt = DateTime.parse(item.timestamp.toString());
        timestampStr = DateFormat('dd/MM/yyyy HH:mm:ss').format(dt);
      } catch (_) {
        timestampStr = item.timestamp?.toString() ?? '';
      }
      sheet.appendRow([
        IntCellValue(i + 1),
        TextCellValue(timestampStr),
        TextCellValue(_getActualId(item.deviceId?.toString())),
        TextCellValue(item.trainNo?.toString() ?? ''),
        TextCellValue(item.location?.toString() ?? ''),
        DoubleCellValue(item.bp?.toDouble() ?? 0),
        DoubleCellValue(item.fp?.toDouble() ?? 0),
        DoubleCellValue(item.cr?.toDouble() ?? 0),
        DoubleCellValue(item.bc?.toDouble() ?? 0),
        TextCellValue(item.brakeStatus?.toString() ?? ''),
        TextCellValue('${item.brakeAppliedTime ?? 0}s'),
        TextCellValue('${item.brakeReleasedTime ?? 0}s'),
        TextCellValue('${item.brakeDuration ?? 0}s'),
        TextCellValue(item.brakeFault?.toString() ?? 'All parameters OK'),
      ]);
    }

    final dir = await getTemporaryDirectory();
    final fileName = 'brake_binding_history_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(excel.encode()!);
    await OpenFile.open(file.path);
  }

  Future<void> _downloadFaultsExcel(List<PneumaticFault> faults) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Active Faults'];
    excel.setDefaultSheet('Active Faults');
    for (final s in excel.sheets.keys.toList()) {
      if (s != 'Active Faults') excel.delete(s);
    }

    // Title row
    sheet.appendRow([TextCellValue('Active Faults Report — ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}')]);
    sheet.appendRow([TextCellValue('')]);

    // Headers
    final headers = ['SR. NO', 'DEVICE ID', 'FAULT TYPE', 'SEVERITY', 'DESCRIPTION', 'TIMESTAMP'];
    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    for (int i = 0; i < faults.length; i++) {
      final fault = faults[i];
      String timestampStr = '';
      try {
        final dt = DateTime.parse(fault.timestamp.toString());
        timestampStr = DateFormat('dd/MM/yyyy HH:mm:ss').format(dt);
      } catch (_) {
        timestampStr = fault.timestamp?.toString() ?? '';
      }
      sheet.appendRow([
        IntCellValue(i + 1),
        TextCellValue(_getActualId(fault.deviceId?.toString())),
        TextCellValue(fault.type?.toString() ?? ''),
        TextCellValue(fault.severity?.toString() ?? ''),
        TextCellValue(fault.description?.toString() ?? ''),
        TextCellValue(timestampStr),
      ]);
    }

    final dir = await getTemporaryDirectory();
    final fileName = 'active_faults_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(excel.encode()!);
    await OpenFile.open(file.path);
  }

  Widget _buildInfoBanner(BrakeBindingState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF5FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset("assets/svgs/train_icon.svg", width: 18, colorFilter: const ColorFilter.mode(Color(0xFF1A9DF8), BlendMode.srcIn)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Train: ${_getTrainNo(state)} | Location: ${_getLocation(state)}", 
                          style: GoogleFonts.poppins(color: const Color(0xFF111111), fontSize: 13, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text("DEVICE FILTER", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.w800)),
                    ],
                  ),
                 _buildDeviceDropdown(state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceDropdown(BrakeBindingState state) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedDeviceId,
        isDense: true,
        style: GoogleFonts.poppins(color: const Color(0xFF1A9DF8), fontSize: 12, fontWeight: FontWeight.w700),
        items: [
          const DropdownMenuItem<String>(
            value: null,
            child: Text("ALL DEVICES"),
          ),
          ...state.coachList.map((coach) {
            final deviceId = coach.deviceId?.toString() ?? '';
            final label = coach.actualId?.toString() ?? coach.deviceId?.toString() ?? 'Unknown';
            return DropdownMenuItem<String>(
              value: deviceId,
              child: Text(label),
            );
          }),
        ],
        onChanged: (val) {
          setState(() => _selectedDeviceId = val);
          _onFilterChanged();
        },
      ),
    );
  }

  Widget _buildTableTopBar() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "PNEUMATIC HISTORY MONITOR",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                "STANDARD: V1.2 | INDIAN RAILWAYS COMPLIANT",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF64748B),
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                "LIVE TELEMETRY",
                style: TextStyle(
                  color: Color(0xFF22C55E),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogHistoryTab(BrakeBindingState state) {
    final response = state.historyPneumaticStatus;
    final List<PneumaticHistoryData> history = response?.history?.data ?? [];

    if (state.isLoadingHistory && history.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (history.isEmpty && !state.isLoadingHistory) return _buildEmptyState("No history logs found for this period");

    // Static Column Definition to prevent layout flickering
    final List<String> columns = [
      "id", "timestamp", "device_id", "train_no", "location",
      "bp", "fp", "cr", "bc", "brake_status", "brake_applied_time",
      "brake_released_time", "brake_duration", "brake_fault"
    ];

    return Column(
      children: [
        _buildTableTopBar(),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDynamicHeader(columns),
                      ...List.generate(history.length, (index) => _buildDynamicRow(history[index], columns, index)),
                    ],
                  ),
                ),
                _buildSeeMoreButton(state, history),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeeMoreButton(BrakeBindingState state, List<PneumaticHistoryData> history) {
    // Only show button if we have data and it's equal to or more than current limit
    final bool canShowMore = history.isNotEmpty && history.length >= (state.historyPneumaticStatus?.history?.limit ?? state.historyLimit);
    
    if (!canShowMore) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Center(
        child: TextButton(
          onPressed: () {
            context.read<BrakeBindingBloc>().add(ShowMoreHistory());
          },
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFFEFF6FF),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            side: const BorderSide(color: Color(0xFFBFDBFE)),
          ),
          child: state.isLoadingHistory
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "SEE MORE",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF2563EB),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF2563EB)),
                  ],
                ),
        ),
      ),
    );
  }

  Map<String, dynamic> itemToMap(PneumaticHistoryData item) {
    return item.toJson();
  }

  String labelFor(String key) {
    if (key == 'id') return 'SR. NO';
    return key.replaceAll("_", " ").toUpperCase();
  }

  double widthFor(String key) {
    final Map<String, double> widths = {
      "id": 70,
      "timestamp": 110,
      "time": 110,
      "train_no": 90,
      "coach_no": 80,
      "coach": 80,
      "device_id": 120,
      "location": 100,
      "bp": 60,
      "bp_raw": 75,
      "fp": 60,
      "fp_raw": 75,
      "cr": 60,
      "cr_raw": 75,
      "bc": 60,
      "bc_raw": 75,
      "brake_status": 150,
      "status": 150,
      "brake_fault": 150,
      "reason": 150,
      "brake_applied_time": 100,
      "brake_released_time": 100,
      "brake_duration": 80,
    };
    return widths[key] ?? 100;
  }

  Widget _buildDynamicHeader(List<String> columns) {
    return Container(
      color: const Color(0xFF1E293B),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: columns.map((col) {
          return Container(
            width: widthFor(col),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              labelFor(col),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDynamicRow(PneumaticHistoryData item, List<String> columns, int index) {
    final isEven = index % 2 == 0;
    final Map<String, dynamic> data = itemToMap(item);

    return Container(
      decoration: BoxDecoration(
        color: isEven ? Colors.white : const Color(0xFFF8FAFC),
        border: Border(bottom: BorderSide(color: Colors.grey.withAlpha(30))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: columns.map((col) {
          final val = data[col];
          final w = widthFor(col);

          if (col == "timestamp") {
              String timeStr = "N/A";
              String dateStr = "";
              if (val != null) {
                final dt = DateTime.parse(val.toString());
                timeStr = DateFormat('HH:mm:ss').format(dt);
                dateStr = DateFormat('dd/MM/yyyy').format(dt);
              }
              return _dateTimeCell(w, timeStr, dateStr);
          }

          if (col == "id") return _cell(w, '${index + 1}', color: const Color(0xFF64748B));
          if (col == "bp") return _boldCell(w, (val as num?)?.toStringAsFixed(1) ?? "0.0", color: const Color(0xFF2563EB));
          if (col == "fp") return _boldCell(w, (val as num?)?.toStringAsFixed(1) ?? "0.0", color: const Color(0xFF059669));
          if (col == "cr") return _boldCell(w, (val as num?)?.toStringAsFixed(1) ?? "0.0", color: const Color(0xFFD97706));
          if (col == "bc") return _bcCell(w, (val as num?)?.toStringAsFixed(1) ?? "0.0", color: const Color(0xFFDC2626));
          if (col.contains("status")) return _statusPill(w, val?.toString() ?? "IDLE");
          if (col == "brake_fault") return _italicCell(w, val?.toString() ?? "All parameters OK", color: const Color(0xFF64748B));
          if (col == "brake_applied_time" || col == "brake_released_time") return _cell(w, val != null ? '${val}s' : '--');
          if (col == "brake_duration") return _boldCell(w, "${val ?? 0}s");
          if (col == "device_id") return _cell(w, _getActualId(val?.toString()));

          return _cell(w, val?.toString() ?? "--");
        }).toList(),
      ),
    );
  }


  Widget _buildActiveFaultsTab(BrakeBindingState state) {
    final List<PneumaticFault> faults = state.historyPneumaticStatus?.activeFaults ?? [];
    
    if (faults.isEmpty && !state.isLoadingHistory) return _buildEmptyState("No active faults detected");

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: faults.length,
          itemBuilder: (context, index) => _buildFaultCard(faults[index]),
        ),
        if (state.isLoadingHistory)
          Container(
            color: Colors.white.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1A9DF8),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 48, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 12),
          Text(message, style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildFaultCard(PneumaticFault fault) {
    String formattedTime = "--:--";
    try {
      if (fault.timestamp != null) {
        formattedTime = DateFormat('dd MMM, HH:mm').format(DateTime.parse(fault.timestamp.toString()));
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withAlpha(76)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "${fault.type ?? "FAULT"}",
                        style: GoogleFonts.poppins(color: Colors.red[900], fontSize: 13, fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red[900],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        (fault.severity ?? "ALARM").toString().toUpperCase(),
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // if (fault.description != null)
                //   Text(
                //     fault.description.toString(),
                //     style: GoogleFonts.poppins(color: Colors.red[700], fontSize: 11, fontWeight: FontWeight.w500),
                //   ),
                // const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.router, size: 10, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          "Device: ${_getActualId(fault.deviceId)}",
                          style: GoogleFonts.poppins(color: Colors.red[800], fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Text(
                      formattedTime,
                      style: GoogleFonts.poppins(color: Colors.red[800], fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(double width, String text, {Color? color}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          color: color ?? const Color(0xFF1E293B),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _boldCell(double width, String text, {Color? color}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          color: color ?? const Color(0xFF1E293B),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _bcCell(double width, String text, {Color? color}) {
    bool hasPressure = (double.tryParse(text) ?? 0.0) > 0.05;
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: hasPressure ? const Color(0xFFFFEBEE) : null,
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          color: color ?? const Color(0xFF1E293B),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _italicCell(double width, String text, {Color? color}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          color: color ?? const Color(0xFF64748B),
          fontSize: 10,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _dateTimeCell(double width, String time, String date) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(time, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF111111))),
          Text(date, style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _statusPill(double width, String status) {
    status = status.toUpperCase();
    Color bgColor = const Color(0xFFF1F5F9);
    Color textColor = const Color(0xFF475569);

    if (status.contains("EMERGENCY") || status.contains("FAULT") || status.contains("ALARM") || status.contains("BINDING")) {
      bgColor = const Color(0xFFB91C1C);
      textColor = Colors.white;
    } else if (status.contains("NORMAL") || status.contains("RUNNING")) {
      bgColor = const Color(0xFF059669);
      textColor = Colors.white;
    } else if (status.contains("SUSPECTED") || status.contains("BB")) {
      bgColor = const Color(0xFFD97706);
      textColor = Colors.white;
    } else if (status.contains("IDLE")) {
      bgColor = const Color(0xFFF1F5F9);
      textColor = const Color(0xFF475569);
    }

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          status,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: textColor,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  String _getTrainNo(BrakeBindingState state) {
    if (_selectedDeviceId == null) return "All Trains";
    final ctx = state.historyPneumaticStatus?.context;
    if (ctx == null) return widget.trainNo;
    final t = ctx.trainNo;
    return (t == null || t.toString() == "NULL") ? "N/A" : t.toString();
  }

  String _getLocation(BrakeBindingState state) {
    if (_selectedDeviceId == null) return "Global View";
    final ctx = state.historyPneumaticStatus?.context;
    if (ctx == null) return "N/A";
    final l = ctx.location;
    return (l == null || l.toString() == "NULL") ? "N/A" : l.toString();
  }
}

