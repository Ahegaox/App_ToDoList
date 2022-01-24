import 'package:api_to_sqlite/src/models/employee_model.dart';
import 'package:api_to_sqlite/src/providers/db_provider.dart';
import 'package:dio/dio.dart';

class EmployeeApiProvider {
  Future<List<Employee?>> getAllEmployees() async {
    var url = "http://demo5637035.mockable.io/personas";
    Response response = await Dio().get(url);

    return (response.data as List).map((employee) {
      print('Inserting $employee');
      DBProvider.db.createEmployee(Employee.fromJson(employee));
    }).toList();
  }

  Future<Response> postNewEmployee(int? id, String email, 
  String firstName, String lastName, String avatar) async {
    var url = "http://demo5637035.mockable.io/personas";

    return (await Dio().post(url, data: {'id': id, 'email': email, 
    'firstName': firstName, 'lastName': lastName, 'avatar': avatar}));
  }

  Future<Response> deleteEmployee(int? id, String email, 
  String firstName, String lastName, String avatar) async {
    var url = "http://demo5637035.mockable.io/personas";

    return (await Dio().delete(url, data: {'id': id, 'email': email, 
    'firstName': firstName, 'lastName': lastName, 'avatar': avatar}));
  }
}
