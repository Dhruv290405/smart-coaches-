// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../../constants/app_colors.dart';
// import '../../constants/app_text_styles.dart';
// import '../../constants/app_dimensions.dart';
// import '../../constants/app_strings.dart';
// import '../../models/diesel_tank_model.dart';
// import '../../utils/status_helper.dart';
// import '../../widgets/common/loco_badge.dart';
// import '../../widgets/common/period_filter.dart';
// import '../../widgets/common/update_info.dart';

// class DieselTankHistory extends StatefulWidget {
//   final DieselTankModel tank;

//   const DieselTankHistory({Key? key, required this.tank}) : super(key: key);

//   @override
//   State<DieselTankHistory> createState() => _DieselTankHistoryState();
// }

// class _DieselTankHistoryState extends State<DieselTankHistory> {
//   String selectedPeriod = '1 Day';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ColorConstants.scaffoldBackground,
//       appBar: AppBar(
//         backgroundColor: ColorConstants.scaffoldBackground,
//         elevation: 0,
//         scrolledUnderElevation: 0,
//         leadingWidth: 40,
//         leading: IconButton(
//           padding: EdgeInsets.zero,
//           icon: const Icon(Icons.arrow_back, color: ColorConstants.textPrimary),
//           onPressed: () => Navigator.pop(context),
//         ),
//         titleSpacing: 4,
//         title: Text(AppStrings.dieselTankHistory, style: AppTextStyles.header1),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(AppDimensions.paddingLarge),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildCurrentLevelCard(),
//               const SizedBox(height: 20),

//               PeriodFilter(
//                 selected: selectedPeriod,
//                 periods: const ['Live', '1 Day', '7 Days', '30 Days'],
//                 onChanged: (val) => setState(() => selectedPeriod = val),
//               ),
//               const SizedBox(height: 20),

//               _buildLineChart(),
//               const SizedBox(height: 12),

//               UpdateInfo(
//                 lastUpdated: widget.tank.getFormattedDate(),
//                 refilledBy: widget.tank.refilledBy,
//               ),
//               const SizedBox(height: 24),

//               _buildStatsCards(),
//               const SizedBox(height: 24),

//               _buildLastUpdatedBySection(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCurrentLevelCard() {
//     final statusColor = StatusHelper.getStatusColor(widget.tank.status);
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: ColorConstants.white,
//         borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.06),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   '${AppStrings.currentLevel}: ${widget.tank.percentage}%',
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                     color: ColorConstants.textPrimary,
//                   ),
//                 ),
//               ),
//               Container(
//                 width: 8,
//                 height: 8,
//                 decoration: BoxDecoration(
//                   color: statusColor,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//               const SizedBox(width: 4),
//               Text(
//                 widget.tank.status,
//                 style: GoogleFonts.poppins(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w500,
//                   color: statusColor,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               SizedBox(
//                 width: 60,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(6),
//                   child: LinearProgressIndicator(
//                     value: widget.tank.percentage / 100,
//                     minHeight: 14,
//                     backgroundColor: ColorConstants.divider,
//                     valueColor: AlwaysStoppedAnimation<Color>(statusColor),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 6),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//             decoration: BoxDecoration(
//               color: ColorConstants.cardBackground,
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: Text(
//               'Last Updated: 10:46 AM',
//               style: AppTextStyles.bodySmall,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(widget.tank.trainName, style: AppTextStyles.bodyMedium),
//               const LocoBadge(),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLineChart() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: ColorConstants.white,
//         borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.06),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: SizedBox(
//         height: 200,
//         child: LineChart(
//           LineChartData(
//             gridData: FlGridData(
//               show: true,
//               drawVerticalLine: false,
//               horizontalInterval: 20,
//               getDrawingHorizontalLine: (value) => FlLine(
//                 color: ColorConstants.divider,
//                 strokeWidth: 1,
//               ),
//             ),
//             titlesData: FlTitlesData(
//               leftTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   interval: 20,
//                   reservedSize: 40,
//                   getTitlesWidget: (value, meta) => Text(
//                     '${value.toInt()}%',
//                     style: AppTextStyles.bodySmall,
//                   ),
//                 ),
//               ),
//               bottomTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   reservedSize: 30,
//                   getTitlesWidget: (value, meta) {
//                     const labels = [
//                       '09:00 AM',
//                       '11:00 AM',
//                       '08:00 PM',
//                       '10:00 PM'
//                     ];
//                     if (value.toInt() >= 0 && value.toInt() < labels.length) {
//                       return Padding(
//                         padding: const EdgeInsets.only(top: 8),
//                         child: Text(
//                           labels[value.toInt()],
//                           style:
//                               AppTextStyles.bodySmall.copyWith(fontSize: 9),
//                         ),
//                       );
//                     }
//                     return const SizedBox.shrink();
//                   },
//                 ),
//               ),
//               topTitles: const AxisTitles(
//                   sideTitles: SideTitles(showTitles: false)),
//               rightTitles: const AxisTitles(
//                   sideTitles: SideTitles(showTitles: false)),
//             ),
//             borderData: FlBorderData(show: false),
//             minX: 0,
//             maxX: 3,
//             minY: 0,
//             maxY: 100,
//             lineBarsData: [
//               LineChartBarData(
//                 spots: const [
//                   FlSpot(0, 5),
//                   FlSpot(0.5, 10),
//                   FlSpot(1, 20),
//                   FlSpot(1.5, 25),
//                   FlSpot(2, 45),
//                   FlSpot(2.5, 60),
//                   FlSpot(2.7, 80),
//                   FlSpot(3, 95),
//                 ],
//                 isCurved: true,
//                 color: Colors.green,
//                 barWidth: 2,
//                 dotData: FlDotData(
//                   show: true,
//                   getDotPainter: (spot, percent, barData, index) =>
//                       FlDotCirclePainter(
//                     radius: 4,
//                     color: index == 0 ? Colors.red : Colors.green,
//                     strokeWidth: 0,
//                   ),
//                 ),
//                 belowBarData: BarAreaData(
//                   show: true,
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Colors.green.withValues(alpha: 0.3),
//                       Colors.green.withValues(alpha: 0.05),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatsCards() {
//     return Column(
//       children: [
//         Row(
//           children: [
//             _buildStatItem('Lowest Level', '10%', ColorConstants.statusCritical),
//             const SizedBox(width: 12),
//             _buildStatItem('Highest Level', '95%', ColorConstants.primary),
//           ],
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             _buildStatItem('Consumption', '400L/hr', ColorConstants.statusGood),
//             const SizedBox(width: 12),
//             _buildStatItem('Refilled', '2 times', ColorConstants.primary),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildStatItem(String label, String value, Color valueColor) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: ColorConstants.white,
//           borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.06),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Flexible(
//               child: Text(label, style: AppTextStyles.bodyMedium),
//             ),
//             Text(
//               value,
//               style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w700,
//                 color: valueColor,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLastUpdatedBySection() {
//     final historyData = [
//       {'date': 'Yesterday, 10:45 AM', 'refiller': 'Ramesh Kumar'},
//       {'date': '08/02/2026, 12:45 PM', 'refiller': 'Ramesh Kumar'},
//       {'date': '07/02/2026, 09:45 AM', 'refiller': 'Ramesh Kumar'},
//       {'date': '06/02/2026, 06:45 PM', 'refiller': 'Ramesh Kumar'},
//       {'date': '05/02/2026, 04:45 PM', 'refiller': 'Ramesh Kumar'},
//       {'date': '04/02/2026, 03:45 PM', 'refiller': 'Ramesh Kumar'},
//     ];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Last Updated By', style: AppTextStyles.header2),
//         const SizedBox(height: 12),
//         Container(
//           decoration: BoxDecoration(
//             color: ColorConstants.white,
//             borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.06),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Date & Time',
//                       style: AppTextStyles.bodyMedium
//                           .copyWith(fontWeight: FontWeight.w600),
//                     ),
//                     Text(
//                       'Refilled By',
//                       style: AppTextStyles.bodyMedium
//                           .copyWith(fontWeight: FontWeight.w600),
//                     ),
//                   ],
//                 ),
//               ),
//               ...historyData.map((entry) => Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 16, vertical: 10),
//                     decoration: const BoxDecoration(
//                       border: Border(
//                           top: BorderSide(
//                               color: ColorConstants.divider, width: 0.5)),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(entry['date']!,
//                             style: AppTextStyles.bodyMedium),
//                         Text(entry['refiller']!,
//                             style: AppTextStyles.bodyMedium),
//                       ],
//                     ),
//                   )),
//             ],
//           ),
//         ),
//         const SizedBox(height: 12),
//         Center(
//           child: TextButton(
//             onPressed: () {},
//             child: Text(
//               'View all',
//               style: AppTextStyles.bodyLarge.copyWith(
//                   color: ColorConstants.primary, fontWeight: FontWeight.w500),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_coach_new/core/helper/status_helper.dart';
import 'package:smart_coach_new/core/widgets/period_filter.dart';
import 'package:smart_coach_new/features/reports_and_alerts/diesel_tank/data/models/diesel_tank_model.dart';

import '../../../../core/utils/app_dimensions.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/color_constants.dart';


class DieselTankHistory extends StatefulWidget {
  final DieselTankModel tank;

  const DieselTankHistory({super.key, required this.tank});

  @override
  State<DieselTankHistory> createState() => _DieselTankHistoryState();
}

class _DieselTankHistoryState extends State<DieselTankHistory> {
  String selectedPeriod = '1 Day';
  final Color _valuePurple = const Color(0xFF513ADF);
  final Color _boxGrey = const Color(0xFFF8F9FA); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: ColorConstants.scaffoldBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 40,
        leading: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_back, color: ColorConstants.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 4,
        title: Text(AppStrings.dieselTankHistory, style: AppTextStyles.header1),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCurrentLevelCard(),
              const SizedBox(height: 20),
              PeriodFilter(
                selected: selectedPeriod,
                periods: const ['Live', '1 Day', '7 Days', '30 Days'],
                onChanged: (val) => setState(() => selectedPeriod = val),
              ),
              const SizedBox(height: 20),
              
              _buildGraphCard(),
              
              const SizedBox(height: 24),
              _buildStatsCards(),
              const SizedBox(height: 24),
              
              _buildLastUpdatedByCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentLevelCard() {
    final statusColor = StatusHelper.getStatusColor(widget.tank.status);
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ColorConstants.textPrimary,
                    ),
                    children: [
                      TextSpan(text: '${AppStrings.currentLevel}: '),
                      TextSpan(
                        text: '${widget.tank.percentage}%',
                        style: const TextStyle(color: ColorConstants.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.tank.status,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: widget.tank.percentage / 100,
                    minHeight: 14,
                    backgroundColor: ColorConstants.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: ColorConstants.cardBackground,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Last Updated: 10:46 AM',
              style: AppTextStyles.bodySmall,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.tank.trainName, style: AppTextStyles.bodyMedium),
              Row(
                children: [
                  SvgPicture.asset(
                    AppIcons.train,
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      _valuePurple,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '1 Loco',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _valuePurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGraphCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Graph inside a Grey Box
          Container(
            height: 220,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            decoration: BoxDecoration(
              color: _boxGrey, // Grey background for graph
              borderRadius: BorderRadius.circular(12),
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: ColorConstants.divider,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}%',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        const labels = [
                          '09:00 AM',
                          '11:00 AM',
                          '08:00 PM',
                          '10:00 PM'
                        ];
                        if (value.toInt() >= 0 && value.toInt() < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labels[value.toInt()],
                              style: AppTextStyles.bodySmall.copyWith(fontSize: 9),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 3,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 5),
                      FlSpot(0.5, 10),
                      FlSpot(1, 20),
                      FlSpot(1.5, 25),
                      FlSpot(2, 45),
                      FlSpot(2.5, 60),
                      FlSpot(2.7, 80),
                      FlSpot(3, 95),
                    ],
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 2,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: index == 0 ? Colors.red : Colors.green,
                        strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.green.withValues(alpha: 0.3),
                          Colors.green.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Info Text moved inside the card
          Text(
            'Last Updated: ${widget.tank.getFormattedDate()}',
            style: AppTextStyles.bodySmall.copyWith(
              color: ColorConstants.textSecondary,
              height: 1.5,
            ),
          ),
          Text(
            'Refilled By: ${widget.tank.refilledBy}',
            style: AppTextStyles.bodySmall.copyWith(
              color: ColorConstants.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Row(
            children: [
              _buildStatItem('Lowest Level', '10%', _valuePurple),
              const SizedBox(width: 12),
              _buildStatItem('Highest Level', '95%', _valuePurple),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem('Consumption', '400L/hr', _valuePurple),
              const SizedBox(width: 12),
              _buildStatItem('Refilled', '2 times', _valuePurple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        height: 38,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _boxGrey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.textPrimary,
                  height: 1.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: valueColor,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdatedByCard() {
    final historyData = [
      {'date': 'Yesterday, 10:45 AM', 'refiller': 'Ramesh Kumar'},
      {'date': '08/02/2026, 12:45 PM', 'refiller': 'Ramesh Kumar'},
      {'date': '07/02/2026, 09:45 AM', 'refiller': 'Ramesh Kumar'},
      {'date': '06/02/2026, 06:45 PM', 'refiller': 'Ramesh Kumar'},
      {'date': '05/02/2026, 04:45 PM', 'refiller': 'Ramesh Kumar'},
      {'date': '04/02/2026, 03:45 PM', 'refiller': 'Ramesh Kumar'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Last Updated By', style: AppTextStyles.header2),
          const SizedBox(height: 16),
          
          // Data List inside a Grey Box
          Container(
            decoration: BoxDecoration(
              color: _boxGrey, // Grey background for the list
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date & Time',
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Refilled By',
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                ...historyData.map((entry) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: const BoxDecoration(
                        border: Border(
                            top: BorderSide(
                                color: ColorConstants.divider, width: 0.5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry['date']!, style: AppTextStyles.bodyMedium),
                          Text(entry['refiller']!,
                              style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // View All button inside the card
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'View all',
                style: AppTextStyles.bodyLarge.copyWith(
                    color: _valuePurple, // Using the purple color
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}