import 'package:borrowbreeze/services/auth.dart';
import 'package:borrowbreeze/services/database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:borrowbreeze/services/loan_logic.dart';

class MetricsView extends StatelessWidget {
  const MetricsView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataTile(context, "Total Loans",
            Database(uid: _auth.user!.uid).getTotalLoans),
        _buildDataTile(context, "Total Completed Loans",
            Database(uid: _auth.user!.uid).getTotalCompletedLoans),
        _buildDataTile(context, "Total Defaults",
            Database(uid: _auth.user!.uid).getTotalDefaults),
        _buildDataTile(context, "Owner Equity",
            Database(uid: _auth.user!.uid).getOwnerEquity),
        _buildDataTile(
            context, "Available Liquid", LoanLogic().calculateAvailableLiquid),
        _buildDataTile(context, "Total Money Lent",
            Database(uid: _auth.user!.uid).getTotalMoneyLent),
        _buildDataTile(context, "Total Money Repaid",
            Database(uid: _auth.user!.uid).getTotalMoneyRepaid),
        _buildDataTile(context, "Total Interest",
            Database(uid: _auth.user!.uid).getTotalInterest),
        _buildDataTile(context, "Total Profit",
            Database(uid: _auth.user!.uid).getTotalProfit),
        _buildDataTile(context, "Total Defaulted Money",
            Database(uid: _auth.user!.uid).getTotalDefaulted),
        _buildDataTile(context, "Pending Chargebacks",
            Database(uid: _auth.user!.uid).getTotalPendingChargebacks),
        _buildDataTile(context, "Total Money Settled",
            Database(uid: _auth.user!.uid).getTotalMoneySettled),
        _buildDataTile(context, "Funds Out In Loan",
            Database(uid: _auth.user!.uid).getFundsInLoan),
        _buildDataTile(context, "Operational Profit",
            LoanLogic().calculateOperationalProfit),
        _buildDataTile(context, "Projected Profit",
            Database(uid: _auth.user!.uid).getProjectedProfit),
      ],
    );
  }

  Widget _buildDataTile(BuildContext context, String title,
      Future<dynamic> Function() dataFetcher) {
    return FutureBuilder<dynamic>(
      future: dataFetcher(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            title: Text(title),
            trailing: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return ListTile(
            title: Text(title),
            trailing: Icon(Icons.error, color: Colors.red),
          );
        } else {
          String dataText;
          if (snapshot.data is int) {
            dataText = snapshot.data.toString();
          } else if (snapshot.data is double) {
            dataText = '\$${(snapshot.data as double).toStringAsFixed(2)}';
          } else {
            dataText = 'Unknown Data Type';
          }

          return ListTile(
            title: Text(title),
            trailing: Text(dataText),
          );
        }
      },
    );
  }
}
