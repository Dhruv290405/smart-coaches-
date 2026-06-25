import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Coach-wise Toilet Monitoring', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 10) / 2;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: coaches.map((c) => SizedBox(width: cardWidth, child: OdourCoachCard(coach: c))).toList(),
            );
          },
        ),
      ],
    );
  }
}
