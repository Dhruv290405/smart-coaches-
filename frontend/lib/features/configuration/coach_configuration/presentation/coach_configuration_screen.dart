import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/export_utils.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/core/widgets/custom_toggle_buttons.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/presentation/bloc/coach_configuration_bloc.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/presentation/widgets/configure_coach.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/presentation/widgets/coach_list.dart';class CoachConfigurationScreen extends StatefulWidget {	const CoachConfigurationScreen({super.key});	@override	State<CoachConfigurationScreen> createState() =>			_CoachConfigurationScreenState();}class _CoachConfigurationScreenState extends State<CoachConfigurationScreen> {
	int selectedTab = 0;
	CoachEntity? selectedCoachItem;

	Future<void> _exportCoachList() async {
		final state = context.read<CoachConfigurationBloc>().state;
		final coaches = state.coachList;
		if (coaches.isEmpty) return;
		final data = coaches.map((c) => {
			'Coach ID': c.coachUniqueId ?? '',
			'Display ID': c.coachDisplayId ?? '',
			'Entity Type': c.entityType ?? '',
			'Make': c.makeOfCoach ?? '',
			'Type': c.typeOfCoach ?? '',
			'Manufacturing Year': c.manufacturingYear?.toString() ?? '',
			'# Master Modules': c.noOfMasterModule?.toString() ?? '',
			'Status': c.coachStatus ?? '',
			'Created By': c.createdBy ?? '',
			'Created At': c.createdAt ?? '',
			'Updated By': c.updatedBy ?? '',
			'Updated At': c.updatedAt ?? '',
		}).toList();
		final path = await ExportUtils.exportToCsv(data, 'Coach_List');
		if (path.isNotEmpty) {
			await Share.shareXFiles([XFile(path)]);
		}
	}

	@override
	Widget build(BuildContext context) {			return Scaffold(
			resizeToAvoidBottomInset: true,
			backgroundColor: const Color(0xFFF8F9FA),
			appBar: AppBar(				backgroundColor: Colors.white,				elevation: 0.5,				leading: IconButton(					icon: Icon(Icons.arrow_back, color: Colors.black),					onPressed: () => Navigator.of(context).pop(),				),				centerTitle: true,				title: Text(					"Coach Configuration",					style: TextStyle(						color: Colors.black,						fontSize: 14.sp,						fontWeight: FontWeight.normal,					),				),				automaticallyImplyLeading: false,			),			body: SafeArea(				child: Padding(					padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),					child: Column(						children: [							Container(								width: double.infinity,								padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.0.h),								decoration: BoxDecoration(									color: Colors.white,									borderRadius: BorderRadius.circular(3.w),									boxShadow: [										BoxShadow(											color: Colors.black.withValues(alpha: 0.05),											blurRadius: 12,										),									],								),								child: Column(									crossAxisAlignment: CrossAxisAlignment.start,									children: [										Text(											'Coach Configuration',											style: TextStyle(												fontSize: 14.sp,												fontWeight: FontWeight.bold,											),										),										SizedBox(height: 1.0.h),										Text(											'Manage and configure coach details for the Smart Coach system',											style: TextStyle(												fontSize: 12.sp,												color: Colors.black,											),										),									],								),							),							SizedBox(height: 2.h),							Container(								width: double.infinity,								padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.0.h),								decoration: BoxDecoration(									color: Colors.white,									borderRadius: BorderRadius.circular(3.w),									boxShadow: [										BoxShadow(											color: Colors.black.withValues(alpha: 0.05),											blurRadius: 12,										),									],								),								child: Row(									crossAxisAlignment: CrossAxisAlignment.center,									children: [										Expanded(											child: CustomToggleButtons(												selectedIndex: selectedTab,												labels: const ['Configure', 'List'],												onTap: (index) {													selectedCoachItem = null;													selectedTab = index;													setState(() {});												},											),										),										if (selectedTab == 1)											SizedBox(												width: 4.w,											),										if (selectedTab == 1)											CustomButton(												text: 'Export',												color: Colors.white,												textColor: Colors.black,												textSize: 12,												showBorder: true,												prefixIcon: Icons.download_outlined,												iconSize: 4,												padding: EdgeInsets.symmetric(													vertical: 1.3.h,													horizontal: 3.w,												),												radius: 8,												onPressed: _exportCoachList,											),									],								),							),							SizedBox(height: 2.h),							Expanded(								child: selectedTab == 0										? ConfigureCoach(									selectedCoachItem: selectedCoachItem,									onGoToListAndRefresh: () {										selectedTab = 1;										setState(													() {},										);									},								)										: CoachList(									onTapEdit: (CoachEntity coachEntity) {										selectedCoachItem = coachEntity;										selectedTab = 0;										setState(() {});									},								),							),						],					),				),			),		);	}}