import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/export_utils.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/core/widgets/custom_toggle_buttons.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/domain/entities/master_module_entity.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/presentation/bloc/master_module_configuration_bloc.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/presentation/widgets/configure_master_module.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/presentation/widgets/master_module_list.dart';

class MasterModuleConfigurationScreen extends StatefulWidget {
  const MasterModuleConfigurationScreen({super.key});

  @override
  State<MasterModuleConfigurationScreen> createState() =>
      _MasterModuleConfigurationScreenState();
}

class _MasterModuleConfigurationScreenState
    extends State<MasterModuleConfigurationScreen> {
  int selectedTab = 0;
  MasterModuleEntity? selectedMasterModuleItem;

  Future<void> _exportMasterModuleList() async {
    final state = context.read<MasterModuleConfigurationBloc>().state;
    final modules = state.masterModuleList;
    if (modules.isEmpty) return;
    final data = modules.map((m) => {
      'ID': m.moduleId?.toString() ?? '',
      'Technical No': m.moduleUniqueId ?? '',
      'Display ID': m.moduleUniqueId ?? '',
      'Status': m.simStatus ?? '',
      'Created By': m.createdBy?.toString() ?? '',
      'Created At': m.createdDate ?? '',
      'Updated By': m.updatedBy?.toString() ?? '',
      'Updated At': m.updatedDate ?? '',
    }).toList();
    final path = await ExportUtils.exportToCsv(data, 'Master_Module_List');
    if (path.isNotEmpty) {
      await Share.shareXFiles([XFile(path)]);
    }
  }

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
          "Master Module Configuration",
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
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.0.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Master Module Configuration',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1.0.h),
                    Text(
                      'Manage and configure master modules for the Smart Coach system',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.0.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomToggleButtons(
                        selectedIndex: selectedTab,
                        labels: const ['Configure', 'List'],
                        onTap: (index) {
                          selectedMasterModuleItem = null;
                          selectedTab = index;
                          setState(() {});
                        },
                      ),
                    ),
                    if (selectedTab == 1)
                      SizedBox(
                        width: 4.w,
                      ),
                    if (selectedTab == 1)
                      CustomButton(
                        text: 'Export',
                        color: Colors.white,
                        textColor: Colors.black,
                        textSize: 12,
                        showBorder: true,
                        prefixIcon: Icons.download_outlined,
                        iconSize: 4,
                        padding: EdgeInsets.symmetric(
                          vertical: 1.3.h,
                          horizontal: 3.w,
                        ),
                        radius: 8,
                        onPressed: _exportMasterModuleList,
                      ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: selectedTab == 0
                    ? ConfigureMasterModule(
                  selectedMasterModuleItem: selectedMasterModuleItem,
                  onGoToListAndRefresh: () {
                    selectedTab = 1;
                    setState(
                          () {},
                    );
                  },
                )
                    : MasterModuleList(
                  onTapEdit: (MasterModuleEntity masterModuleEntity) {
                    selectedMasterModuleItem = masterModuleEntity;
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