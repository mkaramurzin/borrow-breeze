import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:borrowbreeze/models/loan.dart';

class Database {
  final String uid;
  Database({required this.uid});

  // collection references
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('Users');

  Future<String> addLoan(Loan loan) async {
    final DocumentReference docRef =
        await userCollection.doc(uid).collection('Loans').add({
      'status': loan.status,
      'lender account': loan.lenderAccount,
      'financial platform': loan.financialPlatform,
      'borrower username': loan.borrowerUsername,
      'borrower name': loan.borrowerName,
      'amount': loan.amount,
      'repay amount': loan.repayAmount,
      'amount repaid': loan.amountRepaid,
      'origination date': loan.originationDate,
      'repay date': loan.repayDate,
      'request link': loan.requestLink,
      'notes': loan.notes,
      'verification items': loan.verificationItems,
      'reminders': loan.reminders,
      'changelog': loan.changeLog
    });
    return docRef.id;
  }

  Future<List<Loan>> get loans async {
    QuerySnapshot querySnapshot = await userCollection.doc(uid).collection('Loans').get();
    return querySnapshot.docs.map((doc) {
      return Loan(
          docID: doc.id,
          status: doc.get('status'),
          lenderAccount: doc.get('lender account'),
          financialPlatform: doc.get('financial platform'),
          borrowerUsername: doc.get('borrower username'),
          borrowerName: doc.get('borrower name'),
          amount: doc.get('amount'),
          repayAmount: doc.get('repay amount'),
          amountRepaid: doc.get('amount repaid'),
          originationDate: doc.get('origination date'),
          repayDate: doc.get('repay date'),
          requestLink: doc.get('request link'),
          notes: doc.get('notes'),
          verificationItems: doc.get('verification items'),
          reminders: doc.get('reminders'),
          changeLog: doc.get('changelog')
      );
    }).toList();
  }
}
