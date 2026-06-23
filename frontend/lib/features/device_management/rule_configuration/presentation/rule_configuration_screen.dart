import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/widgets/custom_toggle_buttons.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/domain/entities/rule_configuration_entity.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/presentation/widgets/configure_rule.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/presentation/widgets/rule_list.dart';

class RuleConfigurationScreen extends StatefulWidget {
  const RuleConfigurationScreen({super.key});

  @override
  State<RuleConfigurationScreen> createState() =>
      _RuleConfigurationScreenState();
}

class _RuleConfigurationScreenState
    extends State<RuleConfigurationScreen> {
  int selectedTab = 0;
  RuleConfigurationEntity? selectedRuleItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          "Rule Configuration",
          style: TextStyle(
            color: Colors.black,
            fontSize: 14.sp,
            fontWeight: FontWeight.normal,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            children: [
              CustomToggleButtons(
                selectedIndex: selectedTab,
                labels: const ['Configure', 'List'],
                onTap: (index) {
                  selectedRuleItem = null;
                  selectedTab = index;
                  setState(() {});
                },
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: selectedTab == 0
                    ? ConfigureRule(
                  selectedRuleItem: selectedRuleItem,
                  onGoToListAndRefresh: () {
                    selectedTab = 1;
                    setState(
                          () {},
                    );
                  },
                )
                    : RuleList(
                  onTapEdit: (RuleConfigurationEntity ruleItem) {
                    selectedRuleItem = ruleItem;
                    selectedTab = 0;
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}