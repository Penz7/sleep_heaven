import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class ActiveSoundsHeader extends StatelessWidget {
  const ActiveSoundsHeader({super.key, required this.playingCount});

  final int playingCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          'ACTIVE SOUNDS',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
                color: AppColors.accent,
              ),
        ),
        Text(
          '$playingCount playing',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white54,
              ),
        ),
      ],
    );
  }
}
