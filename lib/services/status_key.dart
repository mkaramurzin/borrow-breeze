import 'package:flutter/material.dart';

class StatusKey {
  static Color color(String status) {
    switch (status) {
      case 'ongoing':
        return Color.fromARGB(255, 82, 173, 248);
      case 'overdue':
        return Color.fromARGB(255, 255, 107, 107);
      case 'completed':
        return Color.fromARGB(255, 130, 206, 133);
      case 'defaulted':
        return Color.fromARGB(255, 255, 17, 0);
      case 'disputed':
        return Colors.purple;
      case 'refunded':
        return Colors.pink;
      default:
        return Colors.black;
    }
  }
}
