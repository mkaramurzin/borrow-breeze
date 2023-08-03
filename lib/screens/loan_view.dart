import 'package:borrowbreeze/widgets/loan_item.dart';
import 'package:borrowbreeze/services/database.dart';
import 'package:borrowbreeze/services/auth.dart';
import 'package:borrowbreeze/models/loan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LoanView extends StatefulWidget {
  const LoanView({Key? key}) : super(key: key);

  @override
  State<LoanView> createState() => _LoanViewState();
}

class _LoanViewState extends State<LoanView> {
  final AuthService _auth = AuthService();
  List<Loan>? loanList;
  Loan dummyLoan = Loan(
      status: 'ongoing',
      financialPlatform: 'PayPal',
      borrowerUsername: 'Plungus',
      borrowerName: 'Fahad',
      amount: 200,
      repayAmount: 240,
      originationDate: Timestamp.now(),
      repayDate: Timestamp.now());

  @override
  void initState() {
    super.initState();
    fetchLoanList();
  }

  Future<void> fetchLoanList() async {
    if (_auth.user != null) {
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
          actions: [
            // PopupMenuButton(
            //   icon: Icon(Icons.settings),

            // )
          ],
        ),
        body: Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  Database(uid: _auth.user!.uid).addLoan(dummyLoan);
                  setState(() {
                    fetchLoanList();
                  });
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    width: 500,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      border: Border.all(
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add,
                      ),
                    ),
                  ),
                ),
              ),
              loanList == null
                  ? CircularProgressIndicator() // Loading indicator while fetching data
                  : Expanded(
                    child: Container(
                        width: 600,
                        child: ListView.builder(
                          itemCount: loanList!.length,
                          itemBuilder: (context, index) {
                            return LoanItem(loan: loanList!.elementAt(index),);
                          },
                        ),
                      ),
                  ),
            ],
          ),
        ));
  }
}
