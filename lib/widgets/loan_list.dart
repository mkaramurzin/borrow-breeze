import 'package:borrowbreeze/widgets/loan_item.dart';
import 'package:borrowbreeze/models/loan.dart';
import 'package:flutter/material.dart';

class LoanList extends StatefulWidget {
  List<Loan> loanList;
  LoanList({super.key, required this.loanList});

  @override
  State<LoanList> createState() => _LoanListState();
}

class _LoanListState extends State<LoanList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: widget.loanList!.length,
        itemBuilder: (context, index) {
          return LoanItem();
        },
      ),
    );
  }
}
