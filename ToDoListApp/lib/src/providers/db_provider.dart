import 'dart:io';
import 'package:api_to_sqlite/src/models/employee_model.dart';
import 'package:path/path.dart';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  static Database? _database;
  static final DBProvider db = DBProvider._();

  DBProvider._();

  Future<Database?> get database async {
    // If database exists, return database
    if (_database != null) return _database;

    // If database don't exists, create one
    _database = await initDB();

    return _database;
  }

  // Create the database and the Employee table
  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'employee_manager.db');

    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE Employee('
          'id INTEGER PRIMARY KEY,'
          'email TEXT,'
          'firstName TEXT,'
          'lastName TEXT,'
          'avatar TEXT'
          ')');
    });
  }

  // Insert employee on database
  createEmployee(Employee newEmployee) async {
    await deleteAllEmployees();
    final db = await database;
    final res = await db?.insert('Employee', newEmployee.toJson());

    return res;
  }

  // Delete all employees
  Future<int?> deleteAllEmployees() async {
    final db = await database;
    final res = await db?.rawDelete('DELETE FROM Employee');

    return res;
  }

  Future<List<Employee?>> getAllEmployees() async {
    final db = await database;
    final res = await db?.rawQuery("SELECT * FROM EMPLOYEE");

    List<Employee> list = res!.isNotEmpty ? res.map((c) => Employee.fromJson(c)).toList() : [];

    return list;
  }

  Future<List<Employee?>> getAllEmployeesQuery({required String query}) async {
    final db = await database;
    final res = await db?.rawQuery("SELECT * FROM EMPLOYEE WHERE firstName LIKE '%" + query + "%'");

    List<Employee> list = res!.isNotEmpty ? res.map((c) => Employee.fromJson(c)).toList() : [];

    return list;
  }

  Future<List<Employee?>> getAllEmployeesId() async {
    final db = await database;
    final res = await db?.rawQuery("SELECT id FROM EMPLOYEE");

    List<Employee> list = res!.isNotEmpty ? res.map((c) => Employee.fromJson(c)).toList() : [];


    return list;
  }

  Future<int?> getNewUserId(String query) async {
    final db = await database;
    final res = await db?.rawQuery("SELECT id FROM EMPLOYEE WHERE firstName LIKE '%" + query + "%'");

    List<Employee> list = res!.isNotEmpty ? res.map((c) => Employee.fromJson(c)).toList() : [];

    int? tmp = 0;
    for (var i = list.length - 1; i >= 0 && tmp == 0; i--) {
      tmp = list[i].id;
    }

    return tmp;
  }

  Future<List<String>> getUserData(int userId) async {
    final db = await database;
    final res = await db?.rawQuery("SELECT * FROM EMPLOYEE WHERE id LIKE '%" + userId.toString() + "%'");

    List<Employee> list = res!.isNotEmpty ? res.map((c) => Employee.fromJson(c)).toList() : [];

    List<String> tmp = List.generate(4, (i) => "");
            
    for (var i = list.length - 1; i >= 0 && tmp[0] == "" && tmp[1] == "" && tmp[2] == ""; i--) {
      tmp[0] = list[i].email!;
      tmp[1] = list[i].firstName!;
      tmp[2] = list[i].lastName!;
      tmp[3] = list[i].avatar!;
    }

    return tmp;
  }

  insertNewEmployee(String email, String firstname, String secondname, String avatar) async {
    final db = await database;
    db?.rawInsert('INSERT INTO EMPLOYEE(email, firstName, lastName, avatar) VALUES("' + email + '", "' + firstname + '", "' + secondname + '", "' + avatar + '")');
  }

  Future<int?> deleteSelectedEmployee(int user) async {
    final db = await database;
    await db?.rawDelete('DELETE FROM Employee WHERE id = ?', [user.toString()]);
  }
}
