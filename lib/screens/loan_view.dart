import 'package:borrowbreeze/screens/cash_inputs_view.dart';
import 'package:borrowbreeze/screens/metrics_view.dart';
import 'package:borrowbreeze/services/excel_export.dart';
import 'package:borrowbreeze/services/loan_logic.dart';
import 'package:borrowbreeze/widgets/loan_item.dart';
import 'package:borrowbreeze/services/database.dart';
import 'package:borrowbreeze/services/auth.dart';
import 'package:borrowbreeze/models/loan.dart';
import 'package:flutter/material.dart';
import 'package:borrowbreeze/models/filter.dart';
import 'package:borrowbreeze/widgets/filter_dialog.dart';
import '../widgets/loan_form.dart';
import 'package:borrowbreeze/services/excel_export.dart';

class LoanView extends StatefulWidget {
  const LoanView({Key? key}) : super(key: key);

  @override
  State<LoanView> createState() => _LoanViewState();
}

class _LoanViewState extends State<LoanView>
    with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  List<Loan> loanList = [];
  LoanFilter currentFilter = LoanFilter();
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    _initializeFilter();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _initializeFilter() async {
    if (_auth.user != null) {
      LoanFilter savedFilter =
          await Database(uid: _auth.user!.uid).fetchUserFilter();
      if (mounted) {
        // Check whether the widget is still in the widget tree
        setState(() {
          currentFilter = savedFilter;
        });
      }
    }
  }

  Future<List<Loan>> fetchLoanList() async {
    if (_auth.user != null) {
      return await Database(uid: _auth.user!.uid)
          .getLoans(filter: currentFilter);
    }
    return [];
  }

  Future<void> openFilterDialog() async {
    LoanFilter? result = await showDialog(
      context: context,
      builder: (context) => FilterDialog(currentFilter: currentFilter),
    );

    if (result != null) {
      setState(() {
        currentFilter = result;
      });
      // Save the filter
      await Database(uid: _auth.user!.uid).saveFilter(result);
    }
  }

  void menuOption(int option) async {
    switch (option) {
      case 0:
        await showDialog(
          context: context,
          builder: (context) => LoanFormDialog(
            onFormSubmit: () {
              setState(() {});
            },
          ),
        );
        setState(() {});
        break;

      case 1:
        openFilterDialog();
        break;

      case 2:
        ExcelExportService().exportLoansToExcel(loanList);
        break;

      case 3:
        await _auth.signOut();
        Navigator.pushReplacementNamed(context, '/');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double contentWidth = screenWidth > 600 ? 600 : screenWidth;

    return Scaffold(
      appBar: AppBar(
        title: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () async {
              currentFilter = LoanFilter();
              await Database(uid: _auth.user!.uid).deleteCurrentFilter();
              setState(() {});
            },
            child: Row(
              children: [
                Image.asset(
                  'web/favicon.png',
                  width: 40,
                  height: 40,
                ),
                SizedBox(
                    width:
                        10),
                Text('Borrow Breeze'),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              menuOption(0);
            },
            child: Text('Create Loan'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Color.fromARGB(255, 255, 232, 22), // Background color
              foregroundColor: Colors.brown, // Text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
          ),

          // TODO delete in production
          // ElevatedButton(
          //   onPressed: () async {
          //     await Database(uid: _auth.user!.uid).totalReset();
          //     setState(() {});
          //   },
          //   child: Icon(Icons.autorenew),
          // ),

          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: PopupMenuButton<int>(
                onSelected: (item) {
                  menuOption(item);
                  setState(() {});
                },
                icon: Icon(
                  Icons.settings,
                  size: 30,
                ),
                position: PopupMenuPosition.under,
                itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 0,
                        child: Text('Create Loan'),
                      ),
                      PopupMenuItem(
                        value: 1,
                        child: Text('Apply Filter'),
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: Text('Excel Export'),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: 3,
                        child: Text("Sign Out"),
                      ),
                    ]),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.grey,
          tabs: [
            Tab(icon: Icon(Icons.list, size: 18.0)),
            Tab(icon: Icon(Icons.bar_chart, size: 18.0)),
            Tab(icon: Icon(Icons.attach_money, size: 18.0)),
          ],
        ),
      ),
      body: TabBarView(
          controller: _tabController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            FutureBuilder<List<Loan>>(
              future: fetchLoanList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return Center(child: Text('Error fetching loans.'));
                }

                loanList = snapshot.data ?? [];

                return Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: loanList.isEmpty
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('No loans found',
                                      style: TextStyle(fontSize: 22)),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Container(
                                    width: 300,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        menuOption(0);
                                      },
                                      child: Text(
                                        'Create a Loan',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Color.fromARGB(
                                                255, 255, 232, 22)),
                                      ),
                                      style: ButtonStyle(
                                        side: MaterialStateProperty.resolveWith(
                                            (states) => BorderSide(
                                                color: Color.fromARGB(
                                                    255, 255, 232, 22),
                                                width: 2)),
                                        padding:
                                            MaterialStateProperty.resolveWith(
                                                (states) =>
                                                    EdgeInsets.symmetric(
                                                        vertical: 15.0,
                                                        horizontal: 25.0)),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    width: 300,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        menuOption(1);
                                      },
                                      child: Text(
                                        'Apply Filter',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Color.fromARGB(
                                                255, 255, 232, 22)),
                                      ),
                                      style: ButtonStyle(
                                        side: MaterialStateProperty.resolveWith(
                                            (states) => BorderSide(
                                                color: Color.fromARGB(
                                                    255, 255, 232, 22),
                                                width: 2)),
                                        padding:
                                            MaterialStateProperty.resolveWith(
                                                (states) =>
                                                    EdgeInsets.symmetric(
                                                        vertical: 15.0,
                                                        horizontal: 25.0)),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            : ListView(
                                padding: EdgeInsets.symmetric(
                                  horizontal: (screenWidth - contentWidth) /
                                      2, // Center the content
                                ),
                                children: loanList!
                                    .map((loan) => AnimatedContainer(
                                          duration: Duration(milliseconds: 500),
                                          width: contentWidth,
                                          child: LoanItem(loan: loan),
                                        ))
                                    .toList(),
                              ),
                      ),
                    ),
                    Container(
                      color: Colors.grey[800],
                      height: MediaQuery.of(context).size.height * 0.05,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Total Items'),
                              Text(loanList.length.toString()),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Average Principal'),
                              Text(
                                  '\$${LoanLogic.calculateAverage('principal', loanList)}')
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Average Interest'),
                              Text(
                                  '\$${LoanLogic.calculateAverage('interest', loanList)}')
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Average Duration'),
                              Text(
                                  '${LoanLogic.calculateAverage('duration', loanList)} Days')
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            MetricsView(),
            CashInputView(),
          ]),
    );
  }
}
