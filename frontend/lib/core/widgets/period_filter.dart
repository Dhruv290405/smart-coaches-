import 'package:flutter/material.dart';

import '../utils/app_dimensions.dart';
import '../utils/app_text_styles.dart';
import '../utils/color_constants.dart';


class PeriodFilter extends StatelessWidget {
  final String selected;
  final List<String> periods;
  final ValueChanged<String> onChanged;

  const PeriodFilter({
    super.key,
    required this.selected,
    required this.periods,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: periods.asMap().entries.map((entry) {
          final index = entry.key;
          final period = entry.value;
          final isSelected = selected == period;
          return Expanded(
            child: Padding(
              padding:
                  EdgeInsets.only(right: index < periods.length - 1 ? 8 : 0),
              child: GestureDetector(
                onTap: () => onChanged(period),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ColorConstants.white
                        : ColorConstants.cardBackground,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMedium),
                    border: Border.all(
                      color:
                          isSelected ? ColorConstants.primary : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    period,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected
                          ? ColorConstants.primary
                          : ColorConstants.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
