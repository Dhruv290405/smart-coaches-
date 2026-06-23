import 'package:flutter/material.dart';
import '../../data/models/odour_model.dart';
import 'odour_coach_card.dart';

class OdourCoachesView extends StatelessWidget {
  final List<OdourCoachModel> coaches;
  const OdourCoachesView({super.key, required this.coaches});

  @override
  Widget build(BuildContext context) {
    if (coaches.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("No data found matching filters"),
      ));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: coaches.length,
      itemBuilder: (context, index) {
        return OdourCoachCard(coach: coaches[index]);
      },
    );
  }
}
