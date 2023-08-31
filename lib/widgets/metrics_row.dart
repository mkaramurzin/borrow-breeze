import 'package:flutter/material.dart';

class MetricsRow extends StatelessWidget {
  final double? roi;
  final int? duration;
  final double? interest;
  const MetricsRow(
      {super.key,
      required this.roi,
      required this.interest,
      required this.duration});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        duration != null ? Text('Days: $duration') : Text(''),
        interest != null ? Text('Interest: $interest') : Text(''),
        roi != null
            ? Text('ROI: ${(roi! * 100).roundToDouble() / 100}%')
            : Text(''),
        roi != null && duration != null
            ? Text(
                'Daily ROI: ${((roi! / duration!) * 100).roundToDouble() / 100}')
            : Text('')
      ],
    );
  }
}
