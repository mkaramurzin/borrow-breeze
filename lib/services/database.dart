import 'package:borrowbreeze/models/filter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:borrowbreeze/models/loan.dart';

class Database {
  final String uid;
  Database({required this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('Users');

  Future<void> setUserData() async {
    await userCollection
        .doc(uid)
        .collection('Accounts')
        .add({'name': 'Independent'});
  }

  Future<void> addLoan(Loan loan) async {
    // Get a new document reference without actually creating it.
    final DocumentReference docRef =
        userCollection.doc(uid).collection('Loans').doc();

    await docRef.set({
      'docID': docRef.id,
      'status': loan.status,
      'lender account': loan.lenderAccount,
      'financial platform': loan.financialPlatform,
      'borrower username': loan.borrowerUsername,
      'borrower name': loan.borrowerName,
      'amount': loan.principal,
      'repay amount': loan.repayAmount,
      'interest': loan.interest,
      'roi': loan.roi,
      'amount repaid': loan.amountRepaid,
      'origination date': loan.originationDate,
      'repay date': loan.repayDate,
      'duration': loan.duration,
      'request link': loan.requestLink,
      'notes': loan.notes,
      'verification items': loan.verificationItems,
      'reminders': loan.reminders,
      'changelog': loan.changeLog
    });

    await _updateTotalMoneyLent(loan.principal);
    _updateTotalLoanCount(1, 'total loans');
    _updateFundsInLoan(loan.principal);
    _updateProjectedProfit(loan.interest);
  }

  Future<void> deleteLoan(Loan loan) async {
    await userCollection.doc(uid).collection('Loans').doc(loan.docID).delete();
    _updateTotalLoanCount(-1, 'total loans');
    _updateTotalMoneyLent(-loan.principal);
    _updateFundsInLoan(-loan.principal);
    _updateProjectedProfit(-loan.interest);
  }

  Future<List<Loan>> getLoans({LoanFilter? filter}) async {
    CollectionReference loansCollection =
        userCollection.doc(uid).collection('Loans');
    Query loansQuery = loansCollection;

    if (filter != null) {
      if (filter?.status != null && filter.status!.isNotEmpty) {
        loansQuery = loansQuery.where('status', whereIn: filter!.status);
      }

      if (filter?.borrowerUsername != null) {
        loansQuery = loansQuery.where('borrower username',
            isEqualTo: filter.borrowerUsername);
      }

      if (filter?.lenderAccount != null) {
        loansQuery =
            loansQuery.where('lender account', isEqualTo: filter.lenderAccount);
      }

      if (filter?.borrowerName != null) {
        loansQuery =
            loansQuery.where('borrower name', isEqualTo: filter.borrowerName);
      }

      if (filter?.originationDate != null) {
        DateTime date = filter.originationDate!.toDate();
        Timestamp startOfDay = Timestamp.fromDate(
            DateTime(date.year, date.month, date.day, 0, 0, 0));
        Timestamp endOfDay = Timestamp.fromDate(
            DateTime(date.year, date.month, date.day, 23, 59, 59));
        loansQuery = loansQuery
            .where('origination date', isGreaterThanOrEqualTo: startOfDay)
            .where('origination date', isLessThanOrEqualTo: endOfDay);
      }

      if (filter?.repayDate != null) {
        DateTime date = filter.repayDate!.toDate();
        Timestamp startOfDay = Timestamp.fromDate(
            DateTime(date.year, date.month, date.day, 0, 0, 0));
        Timestamp endOfDay = Timestamp.fromDate(
            DateTime(date.year, date.month, date.day, 23, 59, 59));
        loansQuery = loansQuery
            .where('repay date', isGreaterThanOrEqualTo: startOfDay)
            .where('repay date', isLessThanOrEqualTo: endOfDay);
      }
    }

    if (filter != null && filter.sortOption != null) {
      // Apply the sort with Firestore
      loansQuery = loansQuery.orderBy(filter.sortOption!.field,
          descending: !filter.sortOption!.ascending);
    }

    QuerySnapshot querySnapshot = await loansQuery.get();

    return querySnapshot.docs.map((doc) {
      return Loan(
          docID: doc.id,
          status: doc['status'] as String,
          lenderAccount: doc['lender account'] as String,
          financialPlatform: doc['financial platform'] as String,
          borrowerUsername: doc['borrower username'] as String,
          borrowerName: doc['borrower name'] as String,
          principal: doc['amount'] as double,
          repayAmount: doc['repay amount'] as double,
          interest: doc['interest'] as double,
          amountRepaid: doc['amount repaid'] as double,
          roi: doc['roi'] as double,
          originationDate: doc['origination date'] as Timestamp,
          repayDate: doc['repay date'] as Timestamp,
          duration: doc['duration'] as int,
          requestLink: doc['request link'] as String,
          notes: doc['notes'] as String,
          verificationItems: (doc['verification items'] as List)
              .map((item) => item as Map<String, dynamic>)
              .toList(),
          reminders: doc['reminders'] as int,
          changeLog: doc['changelog'] as String);
    }).toList();
  }

  Future<void> updateLoan(Loan loan) async {
    await userCollection.doc(uid).collection('Loans').doc(loan.docID).update({
      'status': loan.status,
      'lender account': loan.lenderAccount,
      'financial platform': loan.financialPlatform,
      'borrower username': loan.borrowerUsername,
      'borrower name': loan.borrowerName,
      'amount': loan.principal,
      'repay amount': loan.repayAmount,
      'interest': loan.interest,
      'amount repaid': loan.amountRepaid,
      'roi': loan.roi,
      'origination date': loan.originationDate,
      'repay date': loan.repayDate,
      'request link': loan.requestLink,
      'notes': loan.notes,
      'verification items': loan.verificationItems,
      'reminders': loan.reminders,
      'changelog': loan.changeLog
    });
  }

  // Save Filter
  Future<void> saveFilter(LoanFilter filter) async {
    return await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('Filters')
        .doc(filter.docID ?? 'defaultFilter')
        .set({
      'filterName': filter.filterName,
      'status': filter.status,
      'lenderAccount': filter.lenderAccount,
      'borrowerUsername': filter.borrowerUsername,
      'borrowerName': filter.borrowerName,
      'originationDate': filter.originationDate,
      'repayDate': filter.repayDate,
      'sortOptionField': filter.sortOption?.field,
      'sortOptionAscending': filter.sortOption?.ascending,
    });
  }

  // Fetch Filter
  Future<LoanFilter> fetchUserFilter() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('Filters')
        .doc('defaultFilter')
        .get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      return LoanFilter(
        docID: snapshot.id,
        filterName: data['filterName'],
        status: List<String>.from(data['status'] ?? []),
        lenderAccount: data['lenderAccount'],
        borrowerUsername: data['borrowerUsername'],
        borrowerName: data['borrowerName'],
        originationDate: data['originationDate'],
        repayDate: data['repayDate'],
        sortOption: SortOption(
          field: data['sortOptionField'] ?? '',
          ascending: data['sortOptionAscending'] ?? true,
        ),
      );
    } else {
      return LoanFilter(); // Return default filter if not set
    }
  }

  Future<List<String>> fetchAccountNames() async {
    // QuerySnapshot accountSnapshot =
    //     await FirebaseFirestore.instance.collection('Accounts').get();
    QuerySnapshot accountSnapshot =
        await userCollection.doc(uid).collection('Accounts').get();

    return accountSnapshot.docs
        .map((accountDoc) => accountDoc['name'] as String)
        .toList();
  }

  Future<List<String>> fetchBorrowerNames() async {
    CollectionReference loansCollection =
        userCollection.doc(uid).collection('Loans');
    QuerySnapshot querySnapshot = await loansCollection.get();

    Set<String> uniqueNames = {};

    for (var doc in querySnapshot.docs) {
      if (doc['borrower name'] != null) {
        uniqueNames.add(doc['borrower name'] as String);
      }
    }

    return uniqueNames.toList();
  }

  Future<List<String>> fetchBorrowerUsernames() async {
    CollectionReference loansCollection =
        userCollection.doc(uid).collection('Loans');
    QuerySnapshot querySnapshot = await loansCollection.get();

    Set<String> uniqueUsernames = {};

    for (var doc in querySnapshot.docs) {
      if (doc['borrower username'] != null) {
        uniqueUsernames.add(doc['borrower username'] as String);
      }
    }

    return uniqueUsernames.toList();
  }


  // Business logic related section below

  // TODO delete in production
  Future<void> totalReset() async {
    // Delete every loan
    CollectionReference accountsCollection =
        userCollection.doc(uid).collection('Loans');

    QuerySnapshot accountSnapshot = await accountsCollection.get();

    for (QueryDocumentSnapshot accountDoc in accountSnapshot.docs) {
      await accountsCollection.doc(accountDoc.id).delete();
    }
    await userCollection
        .doc(uid)
        .update({'total money lent': FieldValue.delete()});
    await userCollection
        .doc(uid)
        .update({'total money repaid': FieldValue.delete()});
    await userCollection
        .doc(uid)
        .update({'total interest': FieldValue.delete()});
    await userCollection.doc(uid).update({'total profit': FieldValue.delete()});
    await userCollection
        .doc(uid)
        .update({'total defaulted money': FieldValue.delete()});
    await userCollection
        .doc(uid)
        .update({'pending chargebacks': FieldValue.delete()});
    await userCollection
        .doc(uid)
        .update({'total money settled': FieldValue.delete()});
    await userCollection
        .doc(uid)
        .update({'funds out in loan': FieldValue.delete()});
    await userCollection
        .doc(uid)
        .update({'projected profit': FieldValue.delete()});
    await userCollection.doc(uid).update({'total loans': FieldValue.delete()});
    await userCollection
        .doc(uid)
        .update({'total completed loans': FieldValue.delete()});
    await userCollection
        .doc(uid)
        .update({'total defaults': FieldValue.delete()});
  }

  Future<void> handlePaidLoan(Loan loan) async {
    _updateTotalMoneyRepaid(loan.repayAmount - loan.amountRepaid);
    _updateTotalLoanCount(1, 'total completed loans');

    // undo defaulted loan changes
    if (loan.status == 'defaulted') {
      _updateTotalLoanCount(-1, 'total defaults');
      _updateTotalProfit(loan.principal);
      _updateTotalDefaulted(-loan.principal);
      if (loan.amountRepaid == 0) {
        _updateProjectedProfit(loan.repayAmount);
        _updateTotalProfit(-loan.amountRepaid);
        _updateTotalInterest(loan.interest);
        _updateTotalProfit(loan.interest);
      } else {
        _updateProjectedProfit(loan.repayAmount - loan.amountRepaid);
        _updateTotalInterest(loan.repayAmount - loan.amountRepaid);
        _updateTotalProfit(loan.interest - loan.amountRepaid);
      }
    } else {
      if (loan.amountRepaid > loan.principal) {
        _updateTotalInterest(
            loan.interest - (loan.amountRepaid - loan.principal));
        _updateTotalProfit(
            loan.interest - (loan.amountRepaid - loan.principal));
      } else {
        _updateTotalInterest(loan.interest);
        _updateTotalProfit(loan.interest);
        _updateFundsInLoan(-(loan.principal - loan.amountRepaid));
      }
    }
  }

  Future<void> handlePartialPayment(Loan loan, double amount) async {
    _updateTotalMoneyRepaid(amount);
    _updateFundsInLoan(-amount);

    if (loan.amountRepaid >= loan.principal) {
      _updateTotalInterest(amount);
      _updateTotalProfit(amount);
      _updateFundsInLoan(amount);
    } else if (amount + loan.amountRepaid > loan.principal) {
      _updateTotalInterest((amount + loan.amountRepaid) - loan.principal);
      _updateTotalProfit((amount + loan.amountRepaid) - loan.principal);
      _updateFundsInLoan(loan.amountRepaid + amount - loan.principal);
    }
  }

  Future<void> handleDefaultedLoan(Loan loan) async {
    // unsuccessful chargeback
    if (loan.status == 'disputed') {
      _updateTotalPendingChargebacks(-loan.principal);
      _updateProjectedProfit(-loan.principal);
    } else {
      _updateTotalLoanCount(1, 'total defaults');
      if (loan.amountRepaid < loan.principal) {
        _updateFundsInLoan(-(loan.principal - loan.amountRepaid));
        _updateTotalInterest(loan.amountRepaid);
        _updateTotalProfit(loan.amountRepaid);
        _updateTotalProfit(-loan.principal);
        _updateProjectedProfit(loan.amountRepaid);
        _updateProjectedProfit(-loan.principal);
        _updateProjectedProfit(-loan.interest);
        _updateTotalDefaulted(loan.principal);
      } else {
        _updateTotalDefaulted(loan.principal);
        _updateProjectedProfit(-(loan.repayAmount - loan.amountRepaid));
      }
    }
  }

  Future<void> handleDispute(Loan loan) async {
    _updateTotalPendingChargebacks(loan.principal);
    _updateProjectedProfit(loan.principal);
  }

  Future<void> handleRefundedLoan(Loan loan) async {
    _updateTotalPendingChargebacks(-loan.principal);
    _updateTotalDefaulted(-loan.principal);
    _updateTotalProfit(loan.principal);
    _updateTotalMoneySettled(loan.principal);
  }

  Future<void> handleRepayChange(Loan loan, double newAmount) async {
    _updateProjectedProfit(newAmount - loan.repayAmount);
  }

  Future<void> _updateTotalLoanCount(int amount, String type) async {
    DocumentSnapshot userDoc = await userCollection.doc(uid).get();

    if (userDoc.exists) {
      // If the document exists, increment (or create) the value
      await userCollection
          .doc(uid)
          .update({type: FieldValue.increment(amount)});
    } else {
      // If the document doesn't exist, set the value
      await userCollection
          .doc(uid)
          .set({type: amount}, SetOptions(merge: true));
    }
  }

  Future<void> _updateTotalMoneyLent(double amount) async {
    DocumentSnapshot userDoc = await userCollection.doc(uid).get();

    if (userDoc.exists) {
      // If the document exists, increment (or create) the value
      await userCollection
          .doc(uid)
          .update({'total money lent': FieldValue.increment(amount)});
    } else {
      // If the document doesn't exist, set the value
      await userCollection
          .doc(uid)
          .set({'total money lent': amount}, SetOptions(merge: true));
    }
  }

  Future<void> _updateTotalMoneyRepaid(double amount) async {
    await userCollection
        .doc(uid)
        .update({'total money repaid': FieldValue.increment(amount)});
  }

  Future<void> _updateTotalInterest(double amount) async {
    await userCollection
        .doc(uid)
        .update({'total interest': FieldValue.increment(amount)});
  }

  Future<void> _updateTotalProfit(double amount) async {
    await userCollection
        .doc(uid)
        .update({'total profit': FieldValue.increment(amount)});
  }

  Future<void> _updateTotalDefaulted(double amount) async {
    await userCollection
        .doc(uid)
        .update({'total defaulted money': FieldValue.increment(amount)});
  }

  Future<void> _updateTotalPendingChargebacks(double amount) async {
    await userCollection
        .doc(uid)
        .update({'pending chargebacks': FieldValue.increment(amount)});
  }

  Future<void> _updateTotalMoneySettled(double amount) async {
    await userCollection
        .doc(uid)
        .update({'total money settled': FieldValue.increment(amount)});
  }

  Future<void> _updateFundsInLoan(double amount) async {
    await userCollection
        .doc(uid)
        .update({'funds out in loan': FieldValue.increment(amount)});
  }

  Future<void> _updateProjectedProfit(double amount) async {
    await userCollection
        .doc(uid)
        .update({'projected profit': FieldValue.increment(amount)});
  }

  // Accessor methods below

  Future<int> getTotalLoans() async {
    try {
      DocumentSnapshot userDoc = await userCollection.doc(uid).get();
      return userDoc['total loans'] ?? 0;
    } catch (error) {
      return 0;
    }
  }

  Future<int> getTotalCompletedLoans() async {
    try {
      DocumentSnapshot userDoc = await userCollection.doc(uid).get();
      return userDoc['total completed loans'] ?? 0;
    } catch (error) {
      return 0;
    }
  }

  Future<int> getTotalDefaults() async {
    try {
      DocumentSnapshot userDoc = await userCollection.doc(uid).get();
      return userDoc['total defaults'] ?? 0;
    } catch (error) {
      return 0;
    }
  }

  Future<double> getOwnerEquity() async {
    try {
      DocumentSnapshot userDoc = await userCollection.doc(uid).get();
      return userDoc['equity'] ?? 0.0;
    } catch (error) {
      return 0.0;
    }
  }

  Future<double> getTotalMoneyLent() async {
    try {
      DocumentSnapshot userDoc = await userCollection.doc(uid).get();
      return userDoc['total money lent'] ?? 0.0;
    } catch (error) {
      return 0.0;
    }
  }

  Future<double> getTotalMoneyRepaid() async {
    try {
      DocumentSnapshot userDoc = await userCollection.doc(uid).get();
      return userDoc['total money repaid'] ?? 0.0;
    } catch (error) {
      return 0.0;
    }
  }

  Future<double> getTotalInterest() async {
    try {
      DocumentSnapshot userDoc = await userCollection.doc(uid).get();
      return userDoc['total interest'] ?? 0.0;
    } catch (error) {
      return 0.0;
    }
  }

  Future<double> getTotalProfit() async {
    try {
      DocumentSnapshot userDoc = await userCollection.doc(uid).get();
      return userDoc['total profit'] ?? 0.0;
    } catch (error) {
      return 0.0;
    }
  }

  Future<double> getTotalDefaulted() async {
    try {
      DocumentSnapshot userDoc = await userCollection.doc(uid).get();
      return userDoc['total defaulted money'] ?? 0.0;
    } catch (error) {
      return 0.0;
    }
  }

  Future<double> getTotalPendingChargebacks() async {
    try {
      DocumentSnapshot userDoc = await userCollection.doc(uid).get();
      return userDoc['pending chargebacks'] ?? 0.0;
    } catch (error) {
      return 0.0;
    }
  }

  Future<double> getTotalMoneySettled() async {
    try {
      DocumentSnapshot userDoc = await userCollection.doc(uid).get();
      return userDoc['total money settled'] ?? 0.0;
    } catch (error) {
      return 0.0;
    }
  }

  Future<double> getFundsInLoan() async {
    try {
      DocumentSnapshot userDoc = await userCollection.doc(uid).get();
      return userDoc['funds out in loan'] ?? 0.0;
    } catch (error) {
      return 0.0;
    }
  }

  Future<double> getProjectedProfit() async {
    try {
      DocumentSnapshot userDoc = await userCollection.doc(uid).get();
      return userDoc['projected profit'] ?? 0.0;
    } catch (error) {
      return 0.0;
    }
  }

  Future<double> getTotalExpenses() async {
    try {
      DocumentSnapshot userDoc = await userCollection.doc(uid).get();
      return userDoc['total expenses'] ?? 0.0;
    } catch (error) {
      return 0.0;
    }
  }
}
