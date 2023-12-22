import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  String name;
  List<Entry> entries;

  Category({required this.name, required this.entries});

  // Method to convert a Firestore document to a Category object
  factory Category.fromFirestore(Map<String, dynamic> firestoreData) {
    var entriesData = firestoreData['Entries'] as List;
    List<Entry> entriesList = entriesData.map((data) => Entry.fromFirestore(data)).toList();
    return Category(name: firestoreData['name'], entries: entriesList);
  }

  // Method to convert a Category object to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'Entries': entries.map((entry) => entry.toFirestore()).toList(),
    };
  }
}

class Entry {
  String label;
  double amount;
  DateTime date;

  Entry({required this.label, required this.amount, required this.date});

  // Method to convert a Firestore document to an Entry object
  factory Entry.fromFirestore(Map<String, dynamic> firestoreData) {
    return Entry(
      label: firestoreData['label'],
      amount: firestoreData['amount'],
      date: (firestoreData['date'] as Timestamp).toDate(),
    );
  }

  // Method to convert an Entry object to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'label': label,
      'amount': amount,
      'date': Timestamp.fromDate(date),
    };
  }
}
