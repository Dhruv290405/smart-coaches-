import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/core/widgets/custom_text_field.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/domain/entities/train_configs_entity.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class SearchParams {
  final List<TrainConfigsEntity> trainList;
  final String query;

  SearchParams(this.trainList, this.query);
}

List<TrainConfigsEntity> _filterTrain(SearchParams params) {
  final query = params.query.toLowerCase();
  return params.trainList.where((trainItem) {
    return [
      trainItem.trainNumber,
      trainItem.trainName,
      trainItem.departureStationName,
      trainItem.destinationStationName,
      trainItem.line,
      trainItem.regionName,
      trainItem.numberOfCoaches,
    ].any((field) => field.toString().toLowerCase().contains(query) ?? false);
  }).toList();
}

class TrainTable extends StatefulWidget {
  final List<TrainConfigsEntity> items;
  final Function(TrainConfigsEntity trainEntity) onTapEdit;
  final Function(TrainConfigsEntity trainEntity) onTapView;
  final Function(TrainConfigsEntity trainEntity) onTapDelete;

  const TrainTable(
      {super.key,
      required this.items,
      required this.onTapEdit,
      required this.onTapView,
      required this.onTapDelete});

  @override
  State<TrainTable> createState() => _TrainTableState();
}

class _TrainTableState extends State<TrainTable> {
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
  void didUpdateWidget(covariant TrainTable oldWidget) {
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
    final trainListToFilter = widget.items;

    List<TrainConfigsEntity> filteredItems;
    if (_searchText.isEmpty) {
      filteredItems = trainListToFilter;
    } else {
      filteredItems = await compute(
          _filterTrain, SearchParams(trainListToFilter, _searchText));
    }

    // Whitelist of user-facing columns; internal IDs are excluded
    const _visibleColumns = {
      'train_number', 'train_name',
      'origination_region_name', 'region_name',
      'departure_station_name', 'destination_station_name',
      'line', 'train_operator', 'engine_number',
      'no_of_coaches', 'coach_display_id', 'entity_type', 'position',
      'created_at', 'updated_at', 'created_by', 'updated_by',
    };

    // Collect whitelisted keys preserving first-seen order
    final List<String> orderedKeys = [];
    for (var item in filteredItems) {
      if (item.rawJson != null) {
        for (var key in item.rawJson!.keys) {
          if (_visibleColumns.contains(key) && !orderedKeys.contains(key)) {
            orderedKeys.add(key);
          }
        }
      }
    }

    setState(() {
      _dataSource = TableDataSource(
        items: filteredItems,
        columnNames: orderedKeys,
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

  String _formatHeader(String key) {
    return key
        .split('_')
        .map((word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSearch = _searchText.isNotEmpty;

    // Get columns from data source if initialized
    List<String> columnsToShow = [];
    if (_dataSource is TableDataSource) {
       columnsToShow = (_dataSource as TableDataSource).columnNames;
    }

    return Column(
      children: [
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
                    columnWidthMode: ColumnWidthMode.auto,
                    isScrollbarAlwaysShown: true,
                    onSelectionChanged:
                        (List<DataGridRow> added, List<DataGridRow> removed) {
                      _dataSource.handleSelectionChanged(added, removed);
                    },
                    gridLinesVisibility: GridLinesVisibility.both,
                    headerGridLinesVisibility: GridLinesVisibility.both,
                    columns: [
                      ...columnsToShow.map((key) => Utils.gridColumn(label: _formatHeader(key))),
                      Utils.gridColumn(
                          label: 'Actions', width: 150, allowSorting: false),
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
  final List<TrainConfigsEntity> items;
  final List<String> columnNames;
  final Function(TrainConfigsEntity trainItem) onTapEdit;
  final Function(TrainConfigsEntity trainItem) onTapView;
  final Function(TrainConfigsEntity trainItem) onTapDelete;

  List<DataGridRow> _rows = [];

  @override
  List<DataGridRow> get rows => _rows;
  final List<DataGridRow> _selectedRows = [];

  TableDataSource({
    required this.items,
    required this.columnNames,
    required this.onTapEdit,
    required this.onTapDelete,
    required this.onTapView,
  }) {
    const String emptyText = '-';
    _rows = items.map((trainItem) {
      return DataGridRow(
          cells: columnNames.map((key) {
        final value = trainItem.rawJson?[key];
        String displayValue = emptyText;
        if (value != null) {
          if (value is List) {
            displayValue = '${value.length} items';
          } else if (value is Map) {
            displayValue = '{...}';
          } else {
            displayValue = value.toString();
          }
        }
        return DataGridCell<String>(columnName: key, value: displayValue);
      }).toList()
            ..add(DataGridCell<String>(columnName: 'Actions', value: null)));
    }).toList();
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final int rowIndex = _rows.indexOf(row);
    final item = items[rowIndex];
    return DataGridRowAdapter(
      color: _selectedRows.contains(row) ? Colors.grey.shade200 : null,
      cells: row.getCells().map((cell) {
        if (cell.columnName == 'Actions') {
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
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
              cell.value?.toString() ?? '',
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
