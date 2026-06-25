import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// A generic searchable dropdown widget.
/// [items] is the full list of options.
/// [itemBuilder] builds the display widget for each item.
/// [onChanged] is called with the selected item.
/// [hint] optional placeholder text.
class SearchableDropdown<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(T) itemBuilder;
  final void Function(T?) onChanged;
  final String? hint;
  final T? selectedItem;

  const SearchableDropdown({
    Key? key,
    required this.items,
    required this.itemBuilder,
    required this.onChanged,
    this.hint,
    this.selectedItem,
  }) : super(key: key);

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  late TextEditingController _searchController;
  late List<T> _filteredItems;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.items;
    _searchController.addListener(_filter);
  }

  void _filter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items.where((item) {
        final display = widget.itemBuilder(item).toString().toLowerCase();
        return display.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filter);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: widget.hint ?? 'Search...',
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          constraints: BoxConstraints(maxHeight: 30.h),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(1.w),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _filteredItems.length,
            itemBuilder: (context, index) {
              final item = _filteredItems[index];
              final isSelected = item == widget.selectedItem;
              return InkWell(
                onTap: () {
                  widget.onChanged(item);
                },
                child: Container(
                  color: isSelected ? Colors.blue.shade100 : Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  child: widget.itemBuilder(item),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
