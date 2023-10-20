import 'package:borrowbreeze/models/loan.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

class ExcelExportService {
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
        loan.borrowerUsername,
        loan.borrowerName,
        loan.principal.toString(),
        loan.repayAmount.toString(),
        loan.interest.toString(),
        loan.roi.toString(),
        loan.amountRepaid.toString(),
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

    // Save the Excel file
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    excel.save(fileName: "Loans_$formattedDate.xlsx");
  }
}
