import 'package:flutter/material.dart';
import 'package:borrowbreeze/models/loan.dart';
import 'package:intl/intl.dart'; // for date formatting

class LoanItem extends StatelessWidget {
  final Loan loan;

  LoanItem({required this.loan});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('Loan Status: ${loan.status}', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lender Account: ${loan.lenderAccount}'),
                Text('Borrower Username: ${loan.borrowerUsername}'),
                Text('Financial Platform: ${loan.financialPlatform}'),
                Text('Loan Amount: \$${loan.amount}'),
                Text('Repay Amount: \$${loan.repayAmount}'),
                Text('Amount Repaid: \$${loan.amountRepaid}'),
                Text('Origination Date: ${DateFormat('MM-dd-yyyy').format(loan.originationDate.toDate())}'),
                Text('Repay Date: ${DateFormat('MM-dd-yyyy').format(loan.repayDate.toDate())}'),
                Text('Request Link: ${loan.requestLink}'),
              ],
            ),
            trailing: Icon(Icons.arrow_drop_down),
            onTap: () {
              // TODO navigate to edit
            },
          ),
          ExpansionTile(
            expandedAlignment: Alignment.topLeft,
            title: Text(''),
            children: [
              Text('Borrower Name: ${loan.borrowerName}'),
              Text('Notes: ${loan.notes}'),
              Text('Verification Items: ${loan.verificationItems.join(', ')}'),
              Text('Reminders: ${loan.reminders}'),
              ListView.builder(
                shrinkWrap: true,
                itemCount: loan.changeLog.length,
                itemBuilder: (ctx, index) => Text('Change log ${index+1}: ${loan.changeLog[index]}'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
