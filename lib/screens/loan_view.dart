import 'package:borrowbreeze/widgets/loan_list.dart';
import 'package:borrowbreeze/services/database.dart';
import 'package:borrowbreeze/services/auth.dart';
import 'package:borrowbreeze/models/loan.dart';
import 'package:flutter/material.dart';

class LoanView extends StatefulWidget {
  const LoanView({Key? key}): super(key: key);

  @override
  State<LoanView> createState() => _LoanViewState();
}

class _LoanViewState extends State<LoanView> {
  final AuthService _auth = AuthService();
  List<Loan>? loanList;

  @override
  void initState() {
    super.initState();
    fetchLoanList();
  }

  Future<void> fetchLoanList() async {
    if(_auth.user != null){
      final fetchedLoanList = await Database(uid: _auth.user!.uid).getLoans();
      if (mounted) {
        setState(() {
          loanList = fetchedLoanList;
        });
      }
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Borrow Breeze'),
        
      ),
      body: loanList == null
      ? Center(child: CircularProgressIndicator()) // Loading indicator while fetching data
      : Center(child: LoanList(loanList: loanList!))
    );
  }
}