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
  final TextEditingController _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String category1 = "Cash In";
  String category2 = "Cash Out";

  Future<Map<String, List<Entry>>> _loadEntries() async {
    var cashInData = await database.getEntriesByCategory(category1);
    var cashOutData = await database.getEntriesByCategory(category2);
    return {'cashIn': cashInData, 'cashOut': cashOutData};
  }

  String formatDate(DateTime date) {
    return "${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}-${date.year}";
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
          return SingleChildScrollView(
            child: Center(
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
      children: entries.asMap().map((index, entry) {
            Color bgColor = index % 2 == 0 ? Color.fromARGB(255, 63, 62, 62) : Colors.transparent;
            return MapEntry(
              index,
              Container(
                color: bgColor,
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.label),
                      Text("\$${entry.amount}"),
                      Text(entry.date.toString())
                    ],
                  ),
                ),
              ),
            );
          }).values.toList(),
    );
  }

  Widget _buildAddEntryButton(String category) {
    return ElevatedButton(
      child: Icon(Icons.add),
      onPressed: () => _showAddEntryDialog(category),
    );
  }

  Future<void> _showAddEntryDialog(String category) async {
    List<String> dropdownOptions = category == "Cash In"
        ? ["Equity", "Profit"]
        : ["Expense", "Distribution", "Reimbursement", "Mainland Payment"];
    String? selectedLabel =
        dropdownOptions.isNotEmpty ? dropdownOptions.first : null;

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
                  DropdownButtonFormField<String>(
                    value: selectedLabel,
                    decoration: InputDecoration(labelText: 'Label'),
                    items: dropdownOptions
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedLabel = newValue;
                      });
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please select a label'
                        : null,
                  ),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter an amount'
                        : null,
                  ),
                  ListTile(
                    title: Text('Select Date'),
                    subtitle: Text(formatDate(_selectedDate)),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2025),
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
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
                  _addEntry(category, selectedLabel!);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addEntry(String category, String label) async {
    try {
      Entry newEntry = Entry(
        label: label,
        amount: double.parse(_amountController.text),
        date: formatDate(_selectedDate),
      );

      await database.addEntry(category, newEntry);
      setState(() {});
      Navigator.of(context).pop();
      _clearTextFields();
    } catch (e) {
      print('Error adding entry: $e');
    }
  }

  void _clearTextFields() {
    _amountController.clear();
  }
}
