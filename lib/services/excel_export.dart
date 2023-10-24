import 'package:borrowbreeze/models/loan.dart';
import 'package:borrowbreeze/services/auth.dart';
import 'package:borrowbreeze/services/database.dart';
import 'package:borrowbreeze/services/loan_logic.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

class ExcelExportService {
  final database = Database(uid: AuthService().user!.uid);
  final logic = LoanLogic();

  Future<void> exportLoansToExcel(List<Loan> loans) async {
    // Create a new Excel file
    var excel = Excel.createExcel();

    var sheet = excel['LoanData'];
    excel.delete('Sheet1');

    // Populate the header
    List<String> headers = [
      "ID",
      "Satus",
      "Account",
      "Platform",
      "Name",
      "Username",
      "Amount Repaid",
      "Principal",
      "Repay Amount",
      "Interest",
      "ROI",
      "Origination Date",
      "Repay Date",
      "Duration",
      "Request Link",
      "Notes",
      "Verification items"
    ];
    for (int i = 0; i < headers.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = headers[i];
    }

    // Populate the data
    for (int i = 0; i < loans.length; i++) {
      var loan = loans[i];
      var loanAttributes = [
        loan.docID,
        loan.status,
        loan.lenderAccount,
        loan.financialPlatform,
        loan.borrowerName,
        loan.borrowerUsername,
        loan.amountRepaid.toString(),
        loan.principal.toString(),
        loan.repayAmount.toString(),
        loan.interest.toString(),
        loan.roi.toString(),
        loan.originationDate.toDate().toString(),
        loan.repayDate.toDate().toString(),
        loan.duration.toString(),
        loan.requestLink,
        loan.notes,
      ];

      var verificationStrings = loan.verificationItems
          .map((item) => item.values.first.toString())
          .toList();
      loanAttributes.addAll(verificationStrings);

      for (int j = 0; j < loanAttributes.length; j++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1))
            .value = loanAttributes[j];
      }
    }

    // might need
    // var metricsSheet = excel['Metrics'];
    // Map<String, dynamic> metricsData = await fetchMetricsData();

    // int rowIndex = 0;
    // metricsData.forEach((key, value) {
    //   metricsSheet
    //       .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
    //       .value = key;
    //   metricsSheet
    //       .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
    //       .value = value
    //           is double
    //       ? (key.contains("ROI") || key.contains("Rate")
    //           ? '${(value * 100).toStringAsFixed(2)}%'
    //           : '\$${value.toStringAsFixed(2)}')
    //       : value.toString();
    //   rowIndex++;
    // });

    // Save the Excel file
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    excel.save(fileName: "Loans_$formattedDate.xlsx");
  }

  Future<Map<String, dynamic>> fetchMetricsData() async {
    return {
      "Total Loans": await database.getTotalLoans(),
      "Total Completed Loans": await database.getTotalCompletedLoans(),
      "Owner Equity": await database.getOwnerEquity(),
      "Available Liquid": await logic.calculateAvailableLiquid(),
      "Total Money Lent": await database.getTotalMoneyLent(),
      "Total Money Repaid": await database.getTotalMoneyRepaid(),
      "Total Interest": await database.getTotalInterest(),
      "Total Profit": await database.getTotalProfit(),
      "ROI": await logic.calculateTotalROI(),
      "Total Defaults": await database.getTotalDefaults(),
      "Total Defaulted Money": await database.getTotalDefaulted(),
      "Default Rate": await logic.calculateDefaultRate(),
      "Expenses": await database.getTotalExpenses(),
      "Pending Chargebacks": await database.getTotalPendingChargebacks(),
      "Total Money Settled": await database.getTotalMoneySettled(),
      "Funds Out In Loan": await database.getFundsInLoan(),
      "Operational Profit": await logic.calculateOperationalProfit(),
      "Operational ROI": await logic.calculateOperationalROI(),
      "Projected Liquid": await logic.calculateProjectedLiquid(),
      "Projected Profit": await database.getProjectedProfit(),
      "Projected ROI": await logic.calculateProjectedROI(),
    };
  }
}
