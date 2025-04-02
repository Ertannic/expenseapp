import 'package:expenseapp/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  List<Expense> _allExpenses = [];

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
}
