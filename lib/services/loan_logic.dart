import 'package:borrowbreeze/models/loan.dart';
import 'package:borrowbreeze/services/auth.dart';
import 'package:borrowbreeze/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Business logic class
class LoanLogic {
  Database db = Database(uid: AuthService().user!.uid);

  // Calculate ROI for a single loan
  static double calculateRoiSingle(double principal, double repayAmount) {
    if (principal == 0) return 0.0; // To avoid division by zero
    return ((repayAmount - principal) / principal) * 100;
  }

  // Calculate average ROI for a list of loans
  static double calculateRoiList(List<Loan> loans) {
    if (loans.isEmpty) return 0.0;

    double totalRoi = 0.0;
    for (var loan in loans) {
      totalRoi += calculateRoiSingle(loan.principal, loan.repayAmount);
    }

    return totalRoi / loans.length;
  }

  // Calculate days between the start and end of a loan
  static int calculateDuration(DateTime originationDate, DateTime repayDate) {
    DateTime originationMidnight = DateTime(
        originationDate.year, originationDate.month, originationDate.day);
    DateTime repayMidnight =
        DateTime(repayDate.year, repayDate.month, repayDate.day);

    Duration duration = repayMidnight.difference(originationMidnight);
    return duration.inDays;
  }

  // Calculate ROI on a daily scale
  static double calculateDailyRoi(double roi, int duration) {
    return roi / duration;
  }

  // Calculate various averages
  static double calculateAverage(String dataField, List<Loan> loanList) {
    double total = 0.0;

    if (loanList.isEmpty) {
      return 0.0;
    }

    switch (dataField) {
      case 'principal':
        for (Loan loan in loanList) {
          total += loan.principal;
        }
        return ((total / loanList.length) * 100).roundToDouble() / 100;

      case 'interest':
        for (Loan loan in loanList) {
          total += (loan.repayAmount - loan.principal);
        }
        return ((total / loanList.length) * 100).roundToDouble() / 100;

      case 'duration':
        for (Loan loan in loanList) {
          total += loan.duration;
        }
        return ((total / loanList.length) * 100).roundToDouble() / 100;

      default:
        return 0;
    }
  }

  // Calculate the payment protection fee for PayPal or Venmo
  static double calculatePaymentProtectionFee(String platform, amount) {
    if (platform == 'PayPal') {
      amount = (amount) / (1 - 0.0299);
      return ((amount) * 100).roundToDouble() / 100;
    } else if (platform == 'Venmo') {
      amount = (amount) / (1 - 0.019) + 0.1;
      return ((amount) * 100).roundToDouble() / 100;
    }
    return 0;
  }

  // Calculate operational profit
  Future<double> calculateOperationalProfit() async {
    double pendingChargebacks = await db.getTotalPendingChargebacks();
    double projectedProfit = await db.getProjectedProfit();
    double profit = await db.getTotalProfit();

    return projectedProfit - profit - pendingChargebacks;
  }

  // Calculate available liquid
  Future<double> calculateAvailableLiquid() async {
    double equity = await db.getOwnerEquity();
    double fundsInLoan = await db.getFundsInLoan();
    double profit = await db.getTotalProfit();

    return equity + profit - fundsInLoan;
  }

  // Calculate total business ROI
  Future<double> calculateTotalROI() async {
    double repaid = await db.getTotalMoneyRepaid();
    double profit = await db.getTotalProfit();

    return profit / repaid;
  }

  // Calculate ROI on funds in loan
  Future<double> calculateOperationalROI() async {
    double fundsInLoan = await db.getFundsInLoan();
    double profit = await calculateOperationalProfit();

    return profit / fundsInLoan;
  }

  // Calculate projected ROI
  Future<double> calculateProjectedROI() async {
    double lent = await db.getTotalMoneyLent();
    double profit = await db.getProjectedProfit();

    return profit / lent;
  }

}
