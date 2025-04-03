import 'package:expenseapp/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  final List<Expense> _allExpenses = [];

  /* 
  
  S E T U P
 
  */

  // initialize db
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [ExpenseSchema],
      directory: dir.path,
    );
  }

  /* 
  
  G E T T E R S
 
  */

  List<Expense> get allExpense => _allExpenses;

  /* 
  
  O P E R A T I O N S
 
  */

  // Create - add a new expanse
  Future<void> createNewExpense(Expense newExpense) async {
    // add to db
    await isar.writeTxn(
      () => isar.expenses.put(newExpense),
    );

    // re-read from db
    await readExpenses();
  }

  // Read - expenses from db
  Future<void> readExpenses() async {
    // fetch all existing expenses from db
    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();

    // give to local expense list
    _allExpenses.clear();
    _allExpenses.addAll(fetchedExpenses);

    // update UI
    notifyListeners();
  }

  // Update - edit an expense in db
  Future<void> updateExpense(int id, Expense updateExpense) async {
    // make sure new expense has same id as existing one
    updateExpense.id = id;

    // upadate in db
    await isar.writeTxn(
      () => isar.expenses.put(updateExpense),
    );

    // re-read from db
    await readExpenses();
  }

  // Delate - an expense
  Future<void> deleteExpense(int id) async {
    // delete from db
    await isar.writeTxn(
      () => isar.expenses.delete(id),
    );

    // re-read from db
    await readExpenses();
  }

  /* 
  
  H E L P E R
 
  */

  // calculate total expenses for each monoth

  /* 
  
  {
    0: $250, jan
    1: $200, feb
    2: $175, mar
    ...
    11: $240, dec
  }
 
  */



  Future<Map<String, double>> calculateMonthlyTotals() async {
    // ensure the expense are read from the db
    await readExpenses();

    // create a map to keep track of total expenses per month,year
    Map<String, double> monthlyTotals = {};

    // iterate over all expenses
    for (var expense in _allExpenses) {
      // extratch the year & month from the date of the expense
      String yearMonth = '${expense.date.year}-${expense.date.month}';

      // if the month is not yet in the map, initialize to 0
      if (!monthlyTotals.containsKey(yearMonth)) {
        monthlyTotals[yearMonth] = 0;
      }

      // add the expense amount to the total for the month
      monthlyTotals[yearMonth] = monthlyTotals[yearMonth]! + expense.amount;
    }

    return monthlyTotals;
  }

  // calculate current month total
  Future<double> calcualteCurrentMonthTotal() async {
    // ensure expenses are read from db first
    await readExpenses();

    // get current month, year
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    // filter the expenses to include only those for this month this year
    List<Expense> currentMonthExpenses = _allExpenses.where((expense) {
      return expense.date.month == currentMonth &&
          expense.date.year == currentYear;
    }).toList();

    // calculate total amount for the current month
    double total = currentMonthExpenses.fold(0, (sum, expense) => sum + expense.amount);

    return total;
  }

  // get start month
  int getStartMonth() {
    if (_allExpenses.isEmpty) {
      return DateTime.now()
          .month; // default to current month is no expenses are reacoded
    }

    // sort expenses by date to find the earliest
    _allExpenses.sort(
      (a, b) => a.date.compareTo(b.date),
    );

    return _allExpenses.first.date.month;
  }

  // get start year
  int getStartYear() {
    if (_allExpenses.isEmpty) {
      return DateTime.now()
          .year; // default to current month is no expenses are reacoded
    }

    // sort expenses by date to find the earliest
    _allExpenses.sort(
      (a, b) => a.date.compareTo(b.date),
    );

    return _allExpenses.first.date.year;
  }
}
