import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/enums.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/core/widgets/custom_text_field.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/domain/entities/master_module_entity.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class SearchParams {
  final List<MasterModuleEntity> masterModuleList;
  final String query;

  SearchParams(this.masterModuleList, this.query);
}

List<MasterModuleEntity> _filterMasterModule(SearchParams params) {
  final query = params.query.toLowerCase();
  return params.masterModuleList.where((masterModuleItem) {
    return [
      masterModuleItem.moduleUniqueId,
      masterModuleItem.coach?.coachUniqueId,
      masterModuleItem.makeModel,
      masterModuleItem.firmwareVersion,
      masterModuleItem.serialNumber,
      masterModuleItem.installationDate,
      masterModuleItem.location,
      masterModuleItem.placementType,
      masterModuleItem.simNo,
      masterModuleItem.serviceProviderPrimary,
      masterModuleItem.serviceProviderSecondary,
      masterModuleItem.activationDate,
      masterModuleItem.rechargeDate,
      masterModuleItem.simStatus,
      masterModuleItem.batteryReplacementDate,
      masterModuleItem.batteryCapacity,
      masterModuleItem.batteryType,
      masterModuleItem.createdDate,
      masterModuleItem.createdByName,
      masterModuleItem.updatedDate,
      masterModuleItem.updatedByName,
    ].any((field) => field.toString().toLowerCase().contains(query));
  }).toList();
}

class MasterModuleTable extends StatefulWidget {
  final List<MasterModuleEntity> items;
  final Function(MasterModuleEntity masterModuleEntity) onTapEdit;
  final Function(MasterModuleEntity masterModuleEntity) onTapView;
  final Function(MasterModuleEntity masterModuleEntity) onTapDelete;

  const MasterModuleTable(
      {super.key,
      required this.items,
      required this.onTapEdit,
      required this.onTapView,
      required this.onTapDelete});

  @override
  State<MasterModuleTable> createState() => _MasterModuleTableState();
}

class _MasterModuleTableState extends State<MasterModuleTable> {
  late TableDataSource _dataSource;
  final DataGridController _controller = DataGridController();
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  Timer? _debounce;

  @override
  void initState() {
    _buildDataSource();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MasterModuleTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      _buildDataSource();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _buildDataSource() async {
    final masterModuleListToFilter = widget.items;

    List<MasterModuleEntity> filteredItems;
    if (_searchText.isEmpty) {
      filteredItems = masterModuleListToFilter;
    } else {
      filteredItems = await compute(_filterMasterModule,
          SearchParams(masterModuleListToFilter, _searchText));
    }

    setState(() {
      _dataSource = TableDataSource(
        items: filteredItems,
        onTapEdit: widget.onTapEdit,
        onTapView: widget.onTapView,
        onTapDelete: widget.onTapDelete,
      );
    });
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 300), () {
      setState(() {
        _searchText = value.toLowerCase();
      });
      _buildDataSource();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool showSearch = true;
    final bool hasSearch = _searchText.isNotEmpty;
    return Column(
      children: [
        if (showSearch)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: CustomTextField(
              controller: _searchController,
              hintText: 'Search by any field...',
              labelText: 'Search',
              prefixIcon: Icons.search,
              onChanged: _onSearchChanged,
              showShadowOnTextField: true,
              suffixIcon: hasSearch
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                      child: Icon(Icons.clear, color: Colors.black, size: 18),
                    )
                  : null,
            ),
          ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(2.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2.w),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2.w),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SfDataGridTheme(
                  data: SfDataGridThemeData(
                    headerColor: Colors.grey.shade100,
                    headerHoverColor: Colors.grey.shade200,
                  ),
                  child: SfDataGrid(
                    controller: _controller,
                    source: _dataSource,
                    allowSorting: true,
                    selectionMode: SelectionMode.multiple,
                    showCheckboxColumn: true,
                    columnWidthMode: ColumnWidthMode.fitByCellValue,
                    isScrollbarAlwaysShown: true,
                    onSelectionChanged:
                        (List<DataGridRow> added, List<DataGridRow> removed) {
                      _dataSource.handleSelectionChanged(added, removed);
                    },
                    gridLinesVisibility: GridLinesVisibility.both,
                    headerGridLinesVisibility: GridLinesVisibility.both,
                    columns: [
                      Utils.gridColumn(label: 'Coach Number'),
                      Utils.gridColumn(label: 'Coach ID'),
                      Utils.gridColumn(label: 'Make/Model'),
                      Utils.gridColumn(label: 'Firmware'),
                      Utils.gridColumn(label: 'Serial No'),
                      Utils.gridColumn(label: 'Install Date'),
                      Utils.gridColumn(label: 'Location'),
                      Utils.gridColumn(label: 'Placement'),
                      Utils.gridColumn(label: 'Sim Status'),
                      Utils.gridColumn(label: 'Sim No'),
                      Utils.gridColumn(label: 'Primary Prov'),
                      Utils.gridColumn(label: 'Secondary Prov'),
                      Utils.gridColumn(label: 'Activation Date'),
                      Utils.gridColumn(label: 'Recharge Date'),
                      Utils.gridColumn(label: 'Battery Cap'),
                      Utils.gridColumn(label: 'Battery Type'),
                      Utils.gridColumn(label: 'Battery Replace'),
                      Utils.gridColumn(label: 'Battery Recharge'),
                      Utils.gridColumn(label: 'Lora'),
                      Utils.gridColumn(label: 'E-Sim'),
                      Utils.gridColumn(label: 'Dual Profile'),
                      Utils.gridColumn(label: 'No. Of Devices'),
                      Utils.gridColumn(label: 'Created'),
                      Utils.gridColumn(label: 'Created By'),
                      Utils.gridColumn(label: 'Updated'),
                      Utils.gridColumn(label: 'Updated By'),
                      Utils.gridColumn(
                          label: 'Actions', width: 50.w, allowSorting: false),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TableDataSource extends DataGridSource {
  final List<MasterModuleEntity> items;
  final Function(MasterModuleEntity masterModuleItem) onTapEdit;
  final Function(MasterModuleEntity masterModuleItem) onTapView;
  final Function(MasterModuleEntity masterModuleItem) onTapDelete;

  List<DataGridRow> _rows = [];

  @override
  List<DataGridRow> get rows => _rows;
  final List<DataGridRow> _selectedRows = [];

  TableDataSource({
    required this.items,
    required this.onTapEdit,
    required this.onTapDelete,
    required this.onTapView,
  }) {
    String emptyText = '----';
    _rows = items.map((masterModuleItem) {
      return DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'Coach Number',
            value: masterModuleItem.moduleUniqueId ?? emptyText),
        DataGridCell<String>(
            columnName: 'Coach ID',
            value: masterModuleItem.coach?.coachUniqueId ?? emptyText),
        DataGridCell<String>(
            columnName: 'Make/Model',
            value: masterModuleItem.makeModel ?? emptyText),
        DataGridCell<String>(
            columnName: 'Firmware',
            value: masterModuleItem.firmwareVersion ?? emptyText),
        DataGridCell<String>(
            columnName: 'Serial No',
            value: masterModuleItem.serialNumber ?? emptyText),
        DataGridCell<String>(
            columnName: 'Install Date',
            value: _formatDate(masterModuleItem.installationDate)),
        DataGridCell<String>(
            columnName: 'Location', value: masterModuleItem.location ?? emptyText),
        DataGridCell<String>(
            columnName: 'Placement',
            value: masterModuleItem.placementType ?? emptyText),
        DataGridCell<String>(
            columnName: 'Sim Status',
            value: masterModuleItem.simStatus ?? emptyText),
        DataGridCell<String>(
            columnName: 'Sim No', value: masterModuleItem.simNo ?? emptyText),
        DataGridCell<String>(
            columnName: 'Primary Prov',
            value: masterModuleItem.serviceProviderPrimary ?? emptyText),
        DataGridCell<String>(
            columnName: 'Secondary Prov',
            value: masterModuleItem.serviceProviderSecondary ?? emptyText),
        DataGridCell<String>(
            columnName: 'Activation Date',
            value: _formatDate(masterModuleItem.activationDate)),
        DataGridCell<String>(
            columnName: 'Recharge Date',
            value: _formatDate(masterModuleItem.rechargeDate)),
        DataGridCell<String>(
            columnName: 'Battery Cap',
            value: masterModuleItem.batteryCapacity?.toString() ?? emptyText),
        DataGridCell<String>(
            columnName: 'Battery Type',
            value: masterModuleItem.batteryType ?? emptyText),
        DataGridCell<String>(
            columnName: 'Battery Replace',
            value: _formatDate(masterModuleItem.batteryReplacementDate)),
        DataGridCell<String>(
            columnName: 'Battery Recharge',
            value: _formatDate(masterModuleItem.batteryRechargeDate)),
        DataGridCell<String>(
            columnName: 'Lora', value: masterModuleItem.loraEnabled ? 'Yes' : 'No'),
        DataGridCell<String>(
            columnName: 'E-Sim',
            value: masterModuleItem.esimEnabled ? 'Yes' : 'No'),
        DataGridCell<String>(
            columnName: 'Dual Profile',
            value: masterModuleItem.dualProfileSupported ? 'Yes' : 'No'),
        DataGridCell<String>(
            columnName: 'No. Of Devices',
            value: masterModuleItem.deviceNames.length.toString()),
        DataGridCell<String>(
            columnName: 'Created',
            value: _formatDate(masterModuleItem.createdDate)),
        DataGridCell<String>(
            columnName: 'Created By',
            value: masterModuleItem.createdByName ?? emptyText),
        DataGridCell<String>(
            columnName: 'Updated',
            value: _formatDate(masterModuleItem.updatedDate)),
        DataGridCell<String>(
            columnName: 'Updated By',
            value: masterModuleItem.updatedByName ?? emptyText),
        DataGridCell<String>(columnName: 'Actions', value: null),
      ]);
    }).toList();
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '----';
    return Utils.formatReadableDate(date,
            dateFormat: Constants.dateTimeFormatToShowInTable) ??
        '----';
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final int rowIndex = _rows.indexOf(row);
    final item = items[rowIndex];
    return DataGridRowAdapter(
      color: _selectedRows.contains(row) ? Colors.grey.shade200 : null,
      cells: row.getCells().map((cell) {
        if (cell.columnName == 'Sim Status') {
          bool isActive = cell.value.toLowerCase() ==
              DeviceStatus.active.name.toLowerCase();
          bool isInActive = cell.value.toLowerCase() ==
              DeviceStatus.inactive.name.toLowerCase();
          bool isRegistration = cell.value.toLowerCase() ==
              DeviceStatus.registration.name.toLowerCase();
          Color textColor = Colors.black;

          if (isActive) {
            textColor = Colors.green;
          } else if (isInActive) {
            textColor = Colors.red.shade900;
          } else if (isRegistration) {
            textColor = Color(0xFFC0AF6A);
          }

          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(2.h),
                  ),
                  child: Text(
                    cell.value,
                    style: TextStyle(
                      fontSize: 9.5.sp,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (cell.columnName == 'Actions') {
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 1.w),
                GestureDetector(
                  onTap: () {
                    onTapView.call(item);
                  },
                  child: Icon(
                    Icons.remove_red_eye_outlined,
                    size: 18.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
                SizedBox(width: 1.5.w),
                GestureDetector(
                  onTap: () {
                    onTapEdit.call(item);
                  },
                  child: Icon(
                    Icons.mode_edit_outlined,
                    size: 18.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
                SizedBox(width: 1.5.w),
                GestureDetector(
                  onTap: () {
                    onTapDelete.call(item);
                  },
                  child: Icon(
                    Icons.delete_forever_outlined,
                    size: 18.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return Center(
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: Text(
              cell.value.toString(),
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void handleSelectionChanged(
      List<DataGridRow> addedRows, List<DataGridRow> removedRows) {
    _selectedRows
      ..removeWhere((row) => removedRows.contains(row))
      ..addAll(addedRows);

    notifyListeners();
  }
}
