import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/enums.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/core/widgets/custom_text_field.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_type_entity.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class SearchParams {
  final List<SensorTypeEntity> sensorList;
  final String query;

  SearchParams(this.sensorList, this.query);
}

List<SensorTypeEntity> _filterSensor(SearchParams params) {
  final query = params.query.toLowerCase();
  return params.sensorList.where((sensorItem) {
    return [
      sensorItem.sensorTypeId,
      sensorItem.sensorTypeName,
      sensorItem.valueType,
      sensorItem.name,
      sensorItem.description,
      sensorItem.valueFormat,
      sensorItem.isActive,
      sensorItem.createdAt,
      sensorItem.createdBy,
    ].any((field) => field.toString().toLowerCase().contains(query) ?? false);
  }).toList();
}

class SensorTypeTable extends StatefulWidget {
  final List<SensorTypeEntity> items;
  final Function(SensorTypeEntity sensorItem) onTapEdit;
  final Function(SensorTypeEntity sensorItem) onTapView;
  final Function(SensorTypeEntity sensorItem) onTapDelete;

  const SensorTypeTable(
      {super.key,
      required this.items,
      required this.onTapEdit,
      required this.onTapView,
      required this.onTapDelete});

  @override
  State<SensorTypeTable> createState() => _SensorTypeTableState();
}

class _SensorTypeTableState extends State<SensorTypeTable> {
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
  void didUpdateWidget(covariant SensorTypeTable oldWidget) {
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
    final sensorListToFilter = widget.items;

    List<SensorTypeEntity> filteredItems;
    if (_searchText.isEmpty) {
      filteredItems = sensorListToFilter;
    } else {
      filteredItems = await compute(
          _filterSensor, SearchParams(sensorListToFilter, _searchText));
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
                      Utils.gridColumn(label: 'Sensor Type'),
                      Utils.gridColumn(label: 'Name'),
                      Utils.gridColumn(label: 'Category'),
                      Utils.gridColumn(label: 'Devices'),
                      Utils.gridColumn(label: 'Format'),
                      Utils.gridColumn(label: 'SI Units'),
                      Utils.gridColumn(label: 'Status'),
                      Utils.gridColumn(label: 'Created'),
                      Utils.gridColumn(label: 'Created By'),
                      Utils.gridColumn(label: 'Updated'),
                      Utils.gridColumn(label: 'Updated By'),
                      Utils.gridColumn(label: 'Actions',width: 50.w, allowSorting: false),
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
  final List<SensorTypeEntity> items;
  final Function(SensorTypeEntity sensorItem) onTapEdit;
  final Function(SensorTypeEntity sensorItem) onTapView;
  final Function(SensorTypeEntity sensorItem) onTapDelete;

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
    _rows = items.map((sensorItem) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'Sensor Type', value: sensorItem.sensorTypeName ?? emptyText),
        DataGridCell<String>(columnName: 'Name', value: sensorItem.name ?? emptyText),
        DataGridCell<String>(columnName: 'Category', value: sensorItem.category?.name ?? emptyText),
        DataGridCell<String>(
            columnName: 'Devices',
            value:
                '${(sensorItem.devices ?? []).length.toString()} devices'),
        DataGridCell<String>(
            columnName: 'Format', value: sensorItem.valueFormat ?? emptyText),
        DataGridCell<String>(
            columnName: 'SI Units',
            value: (sensorItem.unitsNames ?? []).toString()),
        DataGridCell<String>(columnName: 'Status', value: DeviceStatusHelper.fromBool(sensorItem.isActive).name),
        DataGridCell<String>(columnName: 'Created', value: sensorItem.createdAt ?? emptyText),
        DataGridCell<String>(columnName: 'Created By', value: sensorItem.createdBy ?? emptyText),
        DataGridCell<String>(columnName: 'Updated', value: sensorItem.updatedAt ?? emptyText),
        DataGridCell<String>(columnName: 'Updated By', value: sensorItem.updatedBy ?? emptyText),
        DataGridCell<String>(columnName: 'Actions', value: null),
      ]);
    }).toList();
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final int rowIndex = _rows.indexOf(row);
    final item = items[rowIndex];
    return DataGridRowAdapter(
      color: _selectedRows.contains(row) ? Colors.grey.shade200 : null,
      cells: row.getCells().map((cell) {
        if (cell.columnName == 'Status') {
          bool isActive = cell.value.toLowerCase() ==
              DeviceStatus.active.name.toLowerCase();
          bool isPending = cell.value.toLowerCase() ==
              DeviceStatus.pending.name.toLowerCase();
          bool isInActive = cell.value.toLowerCase() ==
              DeviceStatus.inactive.name.toLowerCase();
          Color textColor = Colors.black;

          if (isActive) {
            textColor = Colors.green;
          } else if (isPending) {
            textColor = Colors.red.shade900;
          } else if (isInActive) {
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

  @override
  void handleSelectionChanged(
      List<DataGridRow> addedRows, List<DataGridRow> removedRows) {
    _selectedRows
      ..removeWhere((row) => removedRows.contains(row))
      ..addAll(addedRows);

    notifyListeners();
  }
}
