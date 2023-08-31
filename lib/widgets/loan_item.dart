import 'package:borrowbreeze/widgets/loan_form.dart';
import 'package:borrowbreeze/widgets/metrics_row.dart';
import 'package:flutter/material.dart';
import 'package:borrowbreeze/models/loan.dart';
import 'package:intl/intl.dart'; // for date formatting
import 'package:borrowbreeze/services/status_key.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:borrowbreeze/services/database.dart';
import '../services/auth.dart';

class LoanItem extends StatefulWidget {
  final Loan loan;

  LoanItem({required this.loan});

  @override
  State<LoanItem> createState() => _LoanItemState();
}

class _LoanItemState extends State<LoanItem> {
  final AuthService _auth = AuthService();
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    notesController = TextEditingController(text: widget.loan.notes);
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  _showChangeLogDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Changelog'),
          content: SingleChildScrollView(
            child: Text(widget.loan.changeLog),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: StatusKey.color(widget.loan.status),
      child: Column(
        children: <Widget>[
          ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Lender Account: ${widget.loan.lenderAccount}'),
                      Icon(Icons.arrow_circle_right),
                      Text(
                          'Borrower Username: ${widget.loan.borrowerUsername}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Loan Amount: \$${widget.loan.principal}'),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Amount Repaid: ',
                              style: TextStyle(fontSize: 16)
                            ),
                            TextSpan(
                              text: '\$${widget.loan.amountRepaid}',
                              style: DefaultTextStyle.of(context)
                                  .style
                                  .copyWith(
                                      fontWeight:
                                          FontWeight.bold, fontSize: 16),
                            ),
                            TextSpan(
                              text: ' / \$${widget.loan.repayAmount}',
                              style: TextStyle(fontSize: 16)
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          'Origination Date: ${DateFormat('MM-dd-yyyy').format(widget.loan.originationDate.toDate())}'),
                      Text(
                          'Repay Date: ${DateFormat('MM-dd-yyyy').format(widget.loan.repayDate.toDate())}'),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  MetricsRow(roi: widget.loan.roi, interest: widget.loan.interest, duration: widget.loan.duration)
                ],
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => LoanFormDialog(
                    onFormSubmit: () => setState(() {}),
                    loan: widget.loan,
                  ),
                );
              }),
          ExpansionTile(
            childrenPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            title: Text(''),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Financial Platform: ${widget.loan.financialPlatform}'),
                  Text('Borrower Name: ${widget.loan.borrowerName}'),
                ],
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: widget.loan.verificationItems.map((item) {
                    return ElevatedButton(
                      onPressed: () async {
                        var urlString = item['url'];
                        if (urlString != null) {
                          var uri = Uri.parse(urlString);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Could not launch $urlString')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('URL is null!')),
                          );
                        }
                      },
                      child: Text('${item['label']}'),
                    );
                  }).toList(),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: notesController,
                  maxLines: null, // Makes it multiline
                  decoration: InputDecoration(
                    filled: true, // This is important
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (value) async {
                    widget.loan.notes = notesController.text;
                    await Database(uid: _auth.user!.uid)
                        .updateLoan(widget.loan);
                  },
                ),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: _showChangeLogDialog,
                  child: Text('View Changelog'),
                ),
              ),
              SizedBox(
                height: 6,
              )
            ],
          ),
        ],
      ),
    );
  }
}
