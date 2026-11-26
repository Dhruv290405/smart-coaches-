import 'package:flutter/material.dart';

class ResponsiveWebWrapper extends StatelessWidget {
  final Widget child;
  const ResponsiveWebWrapper({super.key, required this.child});

  static const double mobileWidth = 420;
  static const double mobileHeight = 900;

  @override
  Widget build(BuildContext context) {
    final realSize = MediaQuery.of(context).size;

    if (realSize.width <= 600) {
      return child;
    }

    final mobileMediaQuery = MediaQuery.of(context).copyWith(
      size: const Size(mobileWidth, mobileHeight),
    );

    return Container(
      color: const Color(0xFFF0F2F5),
      child: Center(
        child: SizedBox(
          width: mobileWidth,
          height: realSize.height,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: MediaQuery(
              data: mobileMediaQuery,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
