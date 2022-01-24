import 'package:api_to_sqlite/src/models/employee_model.dart';
import 'package:api_to_sqlite/src/providers/db_provider.dart';
import 'package:api_to_sqlite/src/providers/employee_api_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var isLoading = false;
  String search_value = "", email_value = "", name_value = "", lastname_value = "", avatar_value = "";
  bool custom = false, _selectedinicialitzat = true, _llistaInicialitzada = false;
  List<List<int>> _selected = [];

  Color primary_color = const Color.fromARGB(255, 102, 0, 204);
  Color second_color = const Color.fromARGB(255, 204, 0, 204);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo List'),
        centerTitle: true,
        backgroundColor: primary_color,
        actions: <Widget>[
          Container(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: const Icon(Icons.settings_input_antenna),
              onPressed: () async {
                await _loadFromApi();
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await _deleteData();
              },
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor:AlwaysStoppedAnimation(primary_color),
              ),
            )
          : _cutomsearch(custom),
          backgroundColor: const Color.fromARGB(255, 245, 245, 245),

      floatingActionButtonLocation: 
      FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: second_color,
        child: Icon(_returnicon(),), onPressed: () {_returnscreen(context);},),
      bottomNavigationBar: BottomAppBar(
        color: primary_color,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                await _showTodoSearchSheet(context);
              },
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
          ],
        ),
      ),
    );
  }

  IconData _returnicon() {

    bool sortir = false;
    for (var i = 0; i < _selected.length && sortir == false; i++) {
      if (_selected[i][0] == 1) {
        sortir = true;
      }
    }

    if (sortir) {
      return Icons.delete;
    }
    return Icons.add;
  }

  _loadFromApi() async {
    setState(() {
      isLoading = true;
    });

    custom == false;
    var apiProvider = EmployeeApiProvider();
    await apiProvider.getAllEmployees();

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoading = false;
    });
  }

  _deleteData() async {
    setState(() {
      isLoading = true;
    });

    await DBProvider.db.deleteAllEmployees();

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      isLoading = false;
    });

    print('All employees deleted');
  }

  _cutomsearch(bool custom) {
    if (custom == false || search_value == "") {

      return _buildEmployeeListView();

    } else if (custom == true) {

      return _buildEmployeeListViewQuery(search_value);
    }
  }

  _buildEmployeeListView() {
    return FutureBuilder(
      future: DBProvider.db.getAllEmployees(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor:AlwaysStoppedAnimation(primary_color),
            ),
          );
        } else if (snapshot.data.length == 0) {
          return Center(
            child: Image.asset('assets/imgs/carpeta.png', width: 100, height: 100, color: primary_color,),
          );
        } else {

          if (snapshot.data.length != _selected.length && custom == false) {
            _selected = List.generate(snapshot.data.length, (i) => List.filled(2, 0, growable: false), growable: true);
            _llistaInicialitzada = true;
          }

          return ListView.builder(itemCount: (snapshot.data.length),
            padding: const EdgeInsets.all(16),
            itemBuilder: (BuildContext context, int index) {
              for (var i = 0; i < snapshot.data.length && _llistaInicialitzada == true; i++) {
                _selected[i][1] = snapshot.data[i].id;
              }
              _llistaInicialitzada = false;
              return Container (
                height: 100,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide()),
                  color: Colors.transparent,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
                  leading: Text(
                    "${index + 1}",
                    style: const TextStyle(fontSize: 20.0),
                  ),
                  title: Text("${snapshot.data[index].firstName} ${snapshot.data[index].lastName}"),
                  subtitle: Text('${snapshot.data[index].email}'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  tileColor: _changecolor(_selected[index][0]), // If current item is selected show blue color
                  trailing: _changeIcon(_selected[index][0]),
                  onTap: () => setState(() => _selected[index][0] = _changeboolstate(context, _selected[index][0])),
                  onLongPress: () async {_moreDetails(context, snapshot.data[index].firstName, snapshot.data[index].lastName, snapshot.data[index].avatar, snapshot.data[index].email);},
                ),
              );
            }
          );
        }
      },
    );
  }

  _getIdFromExistingRecordsToList(List<List<int>> _selected) {
    Future<List<Employee?>> _temp = DBProvider.db.getAllEmployeesId();
  }

  void _setVariablestoZero() {
    _selectedinicialitzat = true;
    search_value = "";
    return;
  }

  Future _showTodoSearchSheet(BuildContext context) async {
    final _todoSearchDescriptionFormController = TextEditingController();
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            color: const Color.fromARGB(255, 245, 245, 245),
            child: Container(
              height: 230,
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 245, 245, 245),
                  borderRadius: const BorderRadius.only(
                      topLeft: const Radius.circular(10.0),
                      topRight: const Radius.circular(10.0))),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 15, top: 25.0, right: 15, bottom: 30),
                child: ListView(
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            cursorColor: primary_color,
                            controller: _todoSearchDescriptionFormController,
                            textInputAction: TextInputAction.newline,
                            maxLines: 4,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w400),
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Search in list...',
                              labelText: 'Search',
                              labelStyle: TextStyle(
                                  color: primary_color,
                                  fontWeight: FontWeight.w500),
                              enabledBorder: UnderlineInputBorder(      
                                borderSide: BorderSide(color: primary_color),   
                              ),  
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primary_color),
                              ),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: primary_color),
                              ),
                            ),
                            validator: (String? value) {
                              return value!.contains('@')
                                  ? 'Dont use the @ character.'
                                  : null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5, top: 15),
                          child: CircleAvatar(
                            backgroundColor: primary_color,
                            radius: 18,
                            child: IconButton(
                              icon: const Icon(
                                Icons.search,
                                size: 22,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                search_value = _todoSearchDescriptionFormController.value.text;
                                custom = true;
                                _selectedinicialitzat = true;
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  void _returnscreen(BuildContext context) {
    bool sortir = false;

    for (var i = 0; i < _selected.length && sortir == false; i++) {
      if (_selected[i][0] == 1) {
        sortir = true;
      }
    }

    if (sortir) {
      return _showDeleteUser(context);
    }
    return _showAddNewUser(context);
  }

  void _showDeleteUser(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text("Cancel", style: TextStyle(color: primary_color,),),
      onPressed: () {Navigator.pop(context);},
    );
    Widget continueButton = TextButton(
      child: Text("Continue", style: TextStyle(color: primary_color,),),
      onPressed: () {
        _deleteSelectedUsers(context);
        _setVariablestoZero();
        setState(() {});
        Navigator.pop(context);
        setState(() {});
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Delete Users", style: TextStyle(color: primary_color,),),
      content: Text("Would you like to delete all the selected users from the device?", style: TextStyle(color: second_color,),),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _deleteSelectedUsers(BuildContext context) async {
    int total_sortides = 0;

    for (var i = 0; i < _selected.length; i++) {
      if (_selected[i][0] != 0) {
        _selected[i][0] = 2;
        custom = false;
        DBProvider.db.deleteSelectedEmployee(_selected[i][1]);

        List<String> temp = await DBProvider.db.getUserData(_selected[i][1]);

        var apiProvider = EmployeeApiProvider();
        Response outputinfo = await apiProvider.deleteEmployee(_selected[i][1], temp[0], temp[1], temp[2], temp[3]);

        if (outputinfo.statusCode == 200) {total_sortides++;}
      }
    }

    _alertDialogDelete(context, total_sortides);
  }

  void _showAddNewUser(BuildContext context) {
    final _userlistemail = TextEditingController();
    final _userlistfirstname = TextEditingController();
    final _userlistlastname = TextEditingController();
    final _avatar = TextEditingController();
    custom = true;
    showModalBottomSheet<dynamic>(
      isScrollControlled: true,
      context: context,
      builder: (builder) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            color: Colors.transparent,
            child: Container(
              height: 400,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                      topLeft: const Radius.circular(10.0),
                      topRight: const Radius.circular(10.0))),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 15, top: 15, right: 15, bottom: 15),
                child: ListView( 
                  children: <Widget>[
                    Text('Insert new User', style: TextStyle(color: primary_color, fontWeight: FontWeight.w500, fontSize: 18),),
                        Expanded(
                          child: TextFormField(
                            controller: _userlistemail,
                            textInputAction: TextInputAction.newline,
                            cursorColor: primary_color,
                            maxLines: 2,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w400),
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'E-Mail',
                              labelText: 'E-Mail',
                              labelStyle: TextStyle(
                                  color: primary_color,
                                  fontWeight: FontWeight.w500),
                              enabledBorder: UnderlineInputBorder(      
                                borderSide: BorderSide(color: primary_color),   
                              ),  
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primary_color),
                              ),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: primary_color),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _userlistfirstname,
                            textInputAction: TextInputAction.newline,
                            cursorColor: primary_color,
                            maxLines: 1,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w400),
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Name',
                              labelText: 'Name',
                              labelStyle: TextStyle(
                                  color: primary_color,
                                  fontWeight: FontWeight.w500),
                              enabledBorder: UnderlineInputBorder(      
                                borderSide: BorderSide(color: primary_color),   
                              ),  
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primary_color),
                              ),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: primary_color),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _userlistlastname,
                            textInputAction: TextInputAction.newline,
                            cursorColor: primary_color,
                            maxLines: 1,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w400),
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Surname',
                              labelText: 'Surname',
                              labelStyle: TextStyle(
                                  color: primary_color,
                                  fontWeight: FontWeight.w500),
                              enabledBorder: UnderlineInputBorder(      
                                borderSide: BorderSide(color: primary_color),   
                              ),  
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primary_color),
                              ),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: primary_color),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _avatar,
                            textInputAction: TextInputAction.newline,
                            cursorColor: primary_color,
                            maxLines: 2,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w400),
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Avatar Web Link',
                              labelText: 'Avatar',
                              labelStyle: TextStyle(
                                  color: primary_color,
                                  fontWeight: FontWeight.w500),
                              enabledBorder: UnderlineInputBorder(      
                                borderSide: BorderSide(color: primary_color),   
                              ),  
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primary_color),
                              ),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: primary_color),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5, top: 15),
                          child: CircleAvatar(
                            backgroundColor: primary_color,
                            radius: 18,
                            child: IconButton(
                              icon: const Icon(
                                Icons.add,
                                size: 22,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                  email_value = _userlistemail.value.text;
                                  name_value = _userlistfirstname.value.text;
                                  lastname_value = _userlistlastname.value.text;
                                  avatar_value = _avatar.value.text;
                                if (!email_value.isEmpty && !name_value.isEmpty && !lastname_value.isEmpty) {
                                  DBProvider.db.insertNewEmployee(email_value, name_value, lastname_value, avatar_value);

                                  int? temp = await DBProvider.db.getNewUserId(name_value);

                                  var apiProvider = EmployeeApiProvider();
                                  Response outputinfo = await apiProvider.postNewEmployee(temp, email_value, name_value, lastname_value, avatar_value);
                                  Navigator.pop(context);
                                  _alertDialog(context, outputinfo);
                                  setState(() {custom = false;});
                                }
                              },
                            ),
                          ),
                        )
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  _alertDialogDelete(BuildContext context, int total_deleted) {
    Widget okButton = TextButton(
        child: Text("OK", style: TextStyle(color: primary_color),),
        onPressed: () { Navigator.pop(context); },
      );

      String title = "", content = "";

      if (total_deleted >= 1) {
        title = "Data Deleted";
        content = "Total employees deleted from the BD and the API: " + total_deleted.toString();
      } else {
        title = "Error";
        content = "Something failed while deleting from the API/BD";
      }

      AlertDialog alert = AlertDialog(
        title: Text(title, style: TextStyle(color: primary_color),),
        content: Text(content, style: TextStyle(color: second_color),),
        actions: [
          okButton,
        ],
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
  }

  _alertDialog(BuildContext context, Response objecte) {
    Widget okButton = TextButton(
        child: Text("OK", style: TextStyle(color: primary_color),),
        onPressed: () { Navigator.pop(context); },
      );

      String title = "", content = "";

      if (objecte.statusCode == 200) {
        title = "User Created";
        content = "The employee was correctly added to the BD and uploaded to the API";
      } else {
        title = "Error";
        content = "Something failed while uploading to the API/saving the user to the BD";
      }

      AlertDialog alert = AlertDialog(
        title: Text(title, style: TextStyle(color: primary_color),),
        content: Text(content, style: TextStyle(color: second_color),),
        actions: [
          okButton,
        ],
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
  }

  _buildEmployeeListViewQuery(valor) {
    return FutureBuilder(
      future: DBProvider.db.getAllEmployeesQuery(query: valor),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor:AlwaysStoppedAnimation(primary_color),
            ),
          );
        } else if (snapshot.data.length == 0) {
          return Center(
            child: Image.asset('assets/imgs/carpeta.png', width: 100, height: 100, color: primary_color,),
          );
        } else {
          return ListView.builder(
            itemCount: snapshot.data.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (BuildContext context, int index) {
              return Container(
                height: 100,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide()),
                  color: Colors.transparent,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
                  leading: Text(
                  "${index + 1}",
                  style: const TextStyle(fontSize: 20.0),
                  ),
                  title: Text("Name: ${snapshot.data[index].firstName} ${snapshot.data[index].lastName}"),
                  subtitle: Text('EMAIL: ${snapshot.data[index].email}'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  tileColor: _changecolorFilter(_selected, snapshot.data[index].id),
                  trailing: _changeIconFilter(_selected, snapshot.data[index].id),

                  onTap: () => setState(() => _changeboolstateFilter(context, _selected, snapshot.data[index].id)),
                  
                ),
              );
            },
          );
        }
      },
    );
  }

  Icon _changeIcon(int valor) {
    if (valor == 1) {
      return const Icon(Icons.check_box);
    } else {
      return const Icon(Icons.check_box_outline_blank);
    }
  }

  Icon _changeIconFilter(_selected, int id) {
    for (var i = 0; i < _selected.length; i++) {
      if (_selected[i][1] == id && _selected[i][0] == 1) {
        return const Icon(Icons.check_box);
      }
    }
    return const Icon(Icons.check_box_outline_blank);
  }

  Color _changecolor(int valor) {
    if (valor == 1) {
      return const Color.fromARGB(255, 230, 230, 230);
    } else {
      return Colors.transparent;
    }
  }

  Color _changecolorFilter(_selected, int id) {
    for (var i = 0; i < _selected.length; i++) {
      if (_selected[i][1] == id && _selected[i][0] == 1) {
        return const Color.fromARGB(255, 230, 230, 230);
      }
    }
    return Colors.transparent;
  }

  int _changeboolstate(BuildContext context, int valor) {
    if (valor == 0) {
      return 1;
    } else {
      return 0;
    }
  }

    _changeboolstateFilter(BuildContext context, _selected, int id) {

    for (var i = 0; i < _selected.length; i++) {
      if (_selected[i][1] == id && _selected[i][0] == 0) {
        _selected[i][0] = 1;
      } else if (_selected[i][1] == id && _selected[i][0] == 1) {
        _selected[i][0] = 0;
      }
    }
  }

  Widget _checkbox(BuildContext context) {
    bool isChecked = false;
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return Checkbox(
      checkColor: Colors.white,
      fillColor: MaterialStateProperty.resolveWith(getColor),
      value: isChecked,
      onChanged: (bool? value) {
        setState(() {
          isChecked = value!;
        });
      },
    );
  }

  _moreDetails(BuildContext context, String name, String surname, String imageurl, String email) {
    Widget okButton = TextButton(
      child: Text("Close", style: TextStyle(color: primary_color),),
      onPressed: () {Navigator.pop(context);},
    );

    Dialog alert = Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(10),
      child: Stack(
        overflow: Overflow.visible,
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 230,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: const Color.fromARGB(255, 245, 245, 245),
            ),
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(name + " " + surname, style: TextStyle(color: second_color, fontSize: 20),),
                const SizedBox(height: 5),
                Text("Email: " + email),
                Container(
                  margin: const EdgeInsets.only(left: 0.0, right: 0.0, bottom: 0.0, top: 25.0),
                  child: okButton,
                ),
              ],
            )
          ),
          Positioned(
            top: -75,
            child: Image.network(
              imageurl, 
              width: 150, 
              height: 150,
              errorBuilder: (context, exception, stackTrace) {
                return Image.asset('assets/imgs/imagen.png', width: 150, height: 150, color: primary_color,);
              },
            )
          ),
        ],
      ),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}