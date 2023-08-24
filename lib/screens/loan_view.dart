import 'package:borrowbreeze/widgets/loan_item.dart';
import 'package:borrowbreeze/services/database.dart';
import 'package:borrowbreeze/services/auth.dart';
import 'package:borrowbreeze/models/loan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:borrowbreeze/models/filter.dart';
import 'package:borrowbreeze/widgets/filter_dialog.dart';

import '../widgets/loan_form.dart';

class LoanView extends StatefulWidget {
  const LoanView({Key? key}) : super(key: key);

  @override
  State<LoanView> createState() => _LoanViewState();
}

class _LoanViewState extends State<LoanView> {
  final AuthService _auth = AuthService();
  List<Loan>? loanList;
  LoanFilter currentFilter = LoanFilter();
  Loan dummyLoan = Loan(
      status: 'ongoing',
      financialPlatform: 'PayPal',
      borrowerUsername: 'Plungus',
      borrowerName: 'Fahad',
      principal: 200,
      repayAmount: 240,
      originationDate: Timestamp.now(),
      verificationItems: [
        {
          "label": "ID",
          "url":
              "https://matrix.redditspace.com/_matrix/media/r0/download/reddit.com/gf7c4a54acua1"
        },
        {
          "label": "Photo",
          "url":
              "https://matrix.redditspace.com/_matrix/media/r0/download/reddit.com/akyk5o37dcua1"
        }
      ],
      repayDate: Timestamp.now());

  @override
  void initState() {
    super.initState();
    fetchLoanList();
  }

  Future<void> fetchLoanList() async {
    if (_auth.user != null) {
      final fetchedLoanList =
          await Database(uid: _auth.user!.uid).getLoans(filter: currentFilter);
      if (mounted) {
        setState(() {
          loanList = fetchedLoanList;
          print(loanList);
        });
      }
    }
  }

  Future<void> openFilterDialog() async {
    LoanFilter? result = await showDialog(
      context: context,
      builder: (context) => FilterDialog(currentFilter: currentFilter),
    );

    if (result != null) {
      setState(() {
        currentFilter = result;
        fetchLoanList();
      });
    }
  }

  void menuOption(int option) async {
    switch (option) {
      case 0:
        // await Database(uid: _auth.user!.uid).addLoan(dummyLoan);
        fetchLoanList();
        showDialog(
          context: context,
          builder: (context) => LoanFormDialog(
            onFormSubmit: () {
              fetchLoanList();
              setState(() {});
            },
          ),
        );
        break;

      case 1:
        openFilterDialog();
        break;

      case 2:
        await _auth.signOut();
        Navigator.pushReplacementNamed(context, '/');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double contentWidth = screenWidth > 600 ? 600 : screenWidth;
    return Scaffold(
        appBar: AppBar(
          title: Text('Borrow Breeze'),
          actions: [
            PopupMenuButton<int>(
                onSelected: (item) {
                  menuOption(item);
                  setState(() {});
                },
                icon: Icon(Icons.settings),
                position: PopupMenuPosition.under,
                itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 0,
                        child: Text('Add Loan'),
                      ),
                      PopupMenuItem(
                        value: 1,
                        child: Text('Apply Filter'),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: 2,
                        child: Text("Sign Out"),
                      ),
                    ]),
          ],
        ),
        body: Center(
          child: Column(
            children: [
              loanList == null
                  ? CircularProgressIndicator() // Loading indicator while fetching data
                  : Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(
                          horizontal: (screenWidth - contentWidth) /
                              2, // Center the content
                        ),
                        children: loanList!
                            .map((loan) => AnimatedContainer(
                                  duration: Duration(milliseconds: 500),
                                  width: contentWidth,
                                  child: LoanItem(loan: loan),
                                ))
                            .toList(),
                      ),
                    ),
            ],
          ),
        ));
  }
}
