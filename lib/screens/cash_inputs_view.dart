import 'package:borrowbreeze/models/cash_input.dart';
import 'package:borrowbreeze/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:borrowbreeze/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CashInputView extends StatefulWidget {
  @override
  _CashInputViewState createState() => _CashInputViewState();
}

class _CashInputViewState extends State<CashInputView> {
  final database = Database(uid: AuthService().user!.uid);
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String category1 = "Cash In";
  String category2 = "Cash Out";

  Future<Map<String, List<Entry>>> _loadEntries() async {
    var cashInData = await database.getEntriesByCategory(category1);
    var cashOutData = await database.getEntriesByCategory(category2);
    return {'cashIn': cashInData, 'cashOut': cashOutData};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<Entry>>>(
      future: _loadEntries(),
      builder: (BuildContext context,
          AsyncSnapshot<Map<String, List<Entry>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          var cashInEntries = snapshot.data!['cashIn']!;
          var cashOutEntries = snapshot.data!['cashOut']!;
          return Center(
            child: Container(
              constraints: BoxConstraints(
                  minWidth: 200,
                  maxWidth: MediaQuery.of(context).size.width * 0.6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAddEntryButton(category1),
                      Expanded(
                          child: _buildCategoryExpansionTile(
                              category1, cashInEntries)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAddEntryButton(category2),
                      Expanded(
                          child: _buildCategoryExpansionTile(
                              category2, cashOutEntries)),
                    ],
                  ),
                  SizedBox(),
                  SizedBox()
                ],
              ),
            ),
          );
        } else {
          return Center(child: Text('No data available'));
        }
      },
    );
  }

  Widget _buildCategoryExpansionTile(String category, List<Entry> entries) {
    return ExpansionTile(
      title: Center(child: Text(category)),
      childrenPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      children:
          entries.map((entry) => ListTile(title: Text(entry.label))).toList(),
    );
  }

  Widget _buildAddEntryButton(String category) {
    return ElevatedButton(
      child: Icon(Icons.add),
      onPressed: () => _showAddEntryDialog(category),
    );
  }

  Future<void> _showAddEntryDialog(String category) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Entry to $category'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _labelController,
                    decoration: InputDecoration(labelText: 'Label'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a label';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a date';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                _clearTextFields();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _addEntry(category);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _clearTextFields() {
    _labelController.clear();
    _amountController.clear();
    _dateController.clear();
  }

  Future<void> _addEntry(String category) async {
    try {
      Entry newEntry = Entry(
        label: _labelController.text,
        amount: double.parse(_amountController.text),
        date: DateTime.parse(_dateController.text),
      );

      await database.addEntry(category, newEntry);
      setState(() {});
      Navigator.of(context).pop();
      _clearTextFields();
    } catch (e) {
      print('Error adding entry: $e');
    }
  }
}
