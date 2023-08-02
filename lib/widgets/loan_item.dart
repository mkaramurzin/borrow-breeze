import 'package:flutter/material.dart';

class LoanItem extends StatefulWidget {
  const LoanItem({super.key});

  @override
  State<LoanItem> createState() => _LoanItemState();
}

class _LoanItemState extends State<LoanItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 100,
      color: Colors.green,
    );
  }
}