import 'package:flutter/material.dart';

class StatusKey {
  static Color color(String status) {
    switch (status) {
      case 'ongoing':
        return Color.fromARGB(255, 82, 173, 248);
      case 'completed':
        return Color.fromARGB(255, 130, 206, 133);
      case 'defaulted':
        return Colors.red;
      case 'disputed':
        return Colors.purple;
      case 'collected':
        return Colors.pink;
      default:
        return Colors.black;
    }
  }
}
