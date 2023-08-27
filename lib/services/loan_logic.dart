import 'package:borrowbreeze/models/loan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Business logic class
class LoanLogic {
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

  static double calculateDailyRoi(double roi, int duration) {
    return roi / duration;
  }
}
