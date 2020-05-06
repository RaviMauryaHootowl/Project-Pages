import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hive/hive.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'file_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String boxName = 'fileBox';

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

void main() async{ 
  WidgetsFlutterBinding.ensureInitialized();
  final document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  Hive.registerAdapter(FileModelAdapter());
  await Hive.openBox<FileModel>(boxName);
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home()),
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int themeMode = 1;
  Box<FileModel> fileBox;
  final TextEditingController nameController = TextEditingController();
  TextEditingController _renameController = TextEditingController();
  TextEditingController _searchController = TextEditingController();

  String curPlace = '/';
  String querySearch = '';
  bool dialVisible = true;
  int countItems = -1;
  Icon dialIcon = Icon(Icons.add);

  void setDialVisible(bool value) {
    setState(() {
      dialVisible = value;
    });
  }

  void showDialogForAdd({int type}){
    nameController.clear();
    showDialog(context: context,
      builder: (context){
        String selectedFilePath = 'null';
        String selectedStatus = '';
        bool _validateField = false;
        return StatefulBuilder(
          builder: (context, setState){
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.white
                ),
                padding: EdgeInsets.all(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      (type == 0) ? 'Add New File' : 'Add New Folder',
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    SizedBox(height: 20.0),
                    
                    (type == 0) ? Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        RaisedButton(onPressed: () async {
                          setState(() {
                            selectedStatus = 'Loading...';
                          });
                            String file = await getFilePath();
                            setState(() {
                              selectedFilePath = file;
                              if(file != 'null'){
                                selectedStatus = 'Selected';
                              }
                            });
                          },
                          child: Text('Select File', style: TextStyle(color: Colors.white),),
                          color: Colors.blueAccent,
                        ),
                        SizedBox(width: 10.0),
                        Text(
                          '$selectedStatus',
                        ),
                      ],
                    ) : Container(),
                    SizedBox(height: 20.0),
                    TextField(
                      decoration: InputDecoration(
                        hintText: (type == 0) ? 'Enter a file Name' : 'Enter the Folder Name',
                        errorText: (_validateField) ? 'Can\'t be empty' : null,
                      ),
                      controller: nameController,
                      onChanged: (text){
                        if(text.isNotEmpty){
                          setState(() {
                            _validateField = false;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 40.0),
                    RaisedButton(
                      child: Text('Add', style: TextStyle(color: Colors.white),),
                      color: Colors.blue,
                      onPressed: () async {
                        //Add to hive box
                        if(nameController.text.isEmpty){
                          setState(() {
                            _validateField = true;
                          });
                        }else{
                          setState(() {
                            _validateField = false;
                          });
                          if(type == 1 || (type == 0 && selectedFilePath!='null'))
                          {
                            final String name = nameController.text;
                            final String path = selectedFilePath;
                            print(path);
                            FileModel file = FileModel(fileName: name, filePath: path, type: type, place: curPlace);
                            fileBox.add(file);
                            Navigator.pop(context);
                          }else{
                            setState(() {
                              selectedStatus = 'No file selected';
                            });
                          }
                        }
                      },
                    )
                  ],
                ),
              )
            );
          }
        );
      },
    );
  }

  void _onLongPressedMenu(int keyToAction){
    showModalBottomSheet(context: context, builder: (context){
      return Container(
        color: Color(0xFF737373),
        padding: EdgeInsets.fromLTRB(10.0,0,10,10),
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red,),
                title: Text((fileBox.get(keyToAction).type == 0) ? 'Delete File' : 'Delete Folder', style: TextStyle(color: Colors.red),),
                onTap: (){
                  Navigator.pop(context);
                  // open confirmation Dialog box
                  openDeleteConfirmationDialog(keyToAction);
                },
              ),
              ListTile(
                leading: Icon(Icons.edit, color: Colors.blue),
                title: Text((fileBox.get(keyToAction).type == 0) ? 'Rename File' : 'Rename Folder', style: TextStyle(color: Colors.blue),),
                onTap: (){
                  Navigator.pop(context);
                  openRenameDialog(keyToAction);
                },
              ),
              ListTile(
                leading: Icon(Icons.arrow_forward, color: Colors.blue),
                title: Text((fileBox.get(keyToAction).type == 0) ? 'Open File' : 'Open Folder', style: TextStyle(color: Colors.blue),),
                onTap: (){
                  Navigator.pop(context);
                  FileModel file = fileBox.get(keyToAction);
                  if(file.type == 0){
                    openFile(file.filePath);
                  }else{
                    //open this folder
                    setState(() {
                      curPlace = file.place + file.fileName + '/';
                    });
                  }
                },
              )
            ],
          ),
        ),
      );
    });
  }

  void openDeleteConfirmationDialog(int keyToDelete){
    FileModel fileToDelete = fileBox.get(keyToDelete);
    showDialog(context: context,
      builder: (context){
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: (themeMode == 0) ? Colors.white : HexColor('272727'),
            ),
            padding: EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0,10,0,10),
                  child: Text(
                    'Do you want to Delete this?',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20.0,
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  (fileToDelete == 0) ? 'By deleting this, it won\'t delete the actual file.'
                  : 'By deleting this, it will delete everything inside this folder.',
                  style: TextStyle(
                    color: (themeMode == 0)? Colors.black45 : Colors.white70,
                  ),
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      child: Text('Cancel', style: TextStyle(color: (themeMode == 0)? Colors.black45 : Colors.white70,),),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      child: Text('Delele', style: TextStyle(color: Colors.red),),
                      onPressed: (){
                        Navigator.pop(context);
                        fileBox.delete(keyToDelete);
                        if(fileToDelete.type == 1){
                          // if this is folder delete all routes within this
                          List<int> allfilesKeys = fileBox.keys.cast<int>().toList();
                          print(allfilesKeys);
                          for(int i = 0; i < allfilesKeys.length; i++){
                            if(fileBox.get(allfilesKeys[i]).place.startsWith(fileToDelete.place + fileToDelete.fileName + '/')){
                              fileBox.delete(allfilesKeys[i]);
                            }
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }


  void openRenameDialog(int keyToRename){
    _renameController.clear();
    showDialog(context: context,
      builder: (context){
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: (themeMode == 0) ? Colors.white : HexColor('272727'),
            ),
            padding: EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'What do you want to Rename to?',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 20.0
                  ),
                ),
                SizedBox(height: 10.0),
                TextField(
                  style: TextStyle(
                    color: (themeMode == 0)? Colors.black45 : Colors.white70,
                  ),
                  controller: _renameController,
                  decoration: InputDecoration(
                    hintText: 'New Name',
                    
                    hintStyle: TextStyle(
                      color: (themeMode == 0) ? Colors.black12 : Colors.white38,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    ),
                  ),

                ),
                //Text('By deleting this, it won\'t delete the actual file.'),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      child: Text('Cancel', style: TextStyle(
                        color: (themeMode == 0)? Colors.black45 : Colors.white70,
                      ),),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      child: Text('Rename', style: TextStyle(color: Colors.blue),),
                      onPressed: (){
                        Navigator.pop(context);
                        //fileBox.delete(keyToDelete);
                        String _newName = _renameController.text;
                        //print(_newName);
                        //print(fileBox.get(keyToRename).fileName);
                        FileModel _tempModel = fileBox.get(keyToRename);
                        //print('got : ${_tempModel.fileName}');
                        _tempModel.fileName = _newName;
                        fileBox.put(keyToRename, _tempModel);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }



  SpeedDial buildSpeedDial() {
    return SpeedDial(
      child: dialIcon,
      //animatedIcon: AnimatedIcons.arrow_menu,
      animatedIconTheme: IconThemeData(size: 22.0),
      onOpen: () { setState(() {
        dialIcon = Icon(Icons.close);
      }); },
      onClose: () { setState(() {
        dialIcon = Icon(Icons.add);
      });},
      visible: dialVisible,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: Icon(Icons.insert_drive_file, color: Colors.blue),
          backgroundColor: Colors.white,
          onTap: () {showDialogForAdd(type: 0);},
          label: 'Add File',
          labelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white
          ),
          labelBackgroundColor: Colors.blue,
        ),
        SpeedDialChild(
          child: Icon(Icons.folder, color: Colors.blue),
          backgroundColor: Colors.white,
          onTap: () {showDialogForAdd(type: 1);},
          label: 'Add Folder',
          labelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white
          ),
          labelBackgroundColor: Colors.blue,
        ),
      ],
    );
  }

  Future<String> getFilePath() async {
   try {
      String filePath = await FilePicker.getFilePath(type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xlsx']
      );
      if (filePath == '') {
        return 'null';
      }
      print("File path: " + filePath);
      return filePath;
    } on Exception catch (e) {
      return 'null';
    }
  }

  Future<bool> _onBackPressed() {
    String tempPlace =  curPlace;
    if(tempPlace == '/'){
      SystemNavigator.pop();
      //Navigator.of(context).pop(true);
    }else{
      print('lenstart : ${tempPlace.length-1}');
      for(int i = tempPlace.length-2; i >= 0; i--){
        if(tempPlace[i] == '/'){
          break;
        }else{
          tempPlace = tempPlace.substring(0,i);
        }
      }
      setState(() {
        curPlace = tempPlace;
        print('set to : $curPlace');
      });
    }
    return Future.value(false);
  }

  void filterList(String query){
    setState(() {
      querySearch = query;
    });
  }

  Future<void> openFile(String filePath) async {
    final result = await OpenFile.open(filePath);
    print('$result');
    // setState(() {
    //   //_openResult = "type=${result.type}  message=${result.message}";
    // });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fileBox = Hive.box<FileModel>(boxName);
    
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //debugPaintSizeEnabled = true;
    
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: GestureDetector(
        onTap: (){
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: (themeMode == 0) ? HexColor('EFEFEF') : HexColor('121212'),
          body: SafeArea(
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(
                          'Pages',
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 0,8.0, 0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (text){
                        // filter listview 
                        print(text);
                        filterList(text);
                      },
                      style: TextStyle(
                        color: (themeMode == 0)? Colors.black45 : Colors.white70,
                      ),
                      cursorColor: Colors.black45,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        filled: true,
                        hintStyle: TextStyle(
                          color: (themeMode == 0) ? Colors.black45 : Colors.white38,
                        ),
                        fillColor: (themeMode == 0) ? HexColor('d7dde0') : HexColor('#373737'),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 5,10,15),
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Path : ',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.blue,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            (querySearch == '') ? curPlace : '--',
                            style: TextStyle(
                              fontSize: 20.0,
                              color: (themeMode == 0)? Colors.black45 : Colors.white70
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 15.0),
                    color: Colors.blue,
                    height: 3.0,
                  ),
                  //Text("Shared files:"),
                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: fileBox.listenable(),
                      builder: (context, Box<FileModel> files, _){
                        List<int> keys = files.keys.cast<int>().toList();
                        for(int i = 0; i < keys.length; i++){
                          final FileModel tempfile = files.get(keys[i]);
                          if(querySearch != ''){
                            if(!tempfile.fileName.toLowerCase().contains(querySearch.toLowerCase())){
                              keys.removeAt(i);
                              i--;
                            }
                          }else{
                            if(tempfile.place != curPlace){
                              keys.removeAt(i);
                              i--;
                            }
                          }
                        }
                        if(keys.isEmpty){
                          print('List is Empty');
                        }
                        print(keys);
                        return (keys.isNotEmpty) ? ListView.separated(
                          itemBuilder: (_, index){
                            final FileModel file = files.get(keys[index]);
                            return GestureDetector(
                              onLongPress: (){
                                _onLongPressedMenu(keys[index]);
                              },
                              child: ListTile(
                                title: Text(
                                  file.fileName,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: (themeMode == 0) ? Colors.black87 : Colors.white70
                                  ),
                                ),
                                leading: (file.type == 0) ? Image.asset('assets/pdficon.png', width: 24,) : Icon(Icons.folder, color: Colors.blue,),
                                onTap: (){
                                  if(querySearch != ''){
                                    _searchController.clear();
                                    FocusScope.of(context).requestFocus(new FocusNode());
                                    setState(() {
                                      querySearch = '';
                                    });
                                  }
                                  if(file.type == 0){
                                    openFile(file.filePath);
                                  }else{
                                    //open this folder
                                    setState(() {
                                      curPlace = file.place + file.fileName + '/';
                                    });
                                  }
                                },
                              ),
                            );
                          },
                          separatorBuilder: (_, index) => Divider(), 
                          itemCount: keys.length,
                          shrinkWrap: true,
                        ) : Image.asset('assets/file.jpg');
                      },
                    ),
                  ),

                  //-------------- Delete Button --------------
                  // Row(
                  //   children: <Widget>[
                  //     Padding(
                  //       padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                  //       child: RawMaterialButton(
                  //         onPressed: () {
                  //           fileBox.clear();
                  //           setState(() {
                  //             curPlace = '/';
                  //           });
                  //         },
                  //         elevation: 2.0,
                  //         fillColor: Colors.red,
                  //         child: Icon(
                  //           Icons.delete,
                  //           color: Colors.white,
                  //           size: 25.0,
                  //         ),
                  //         padding: EdgeInsets.all(15.0),
                  //         shape: CircleBorder(),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
          floatingActionButton: buildSpeedDial(),
        ),
      ),
    );
  }
}


