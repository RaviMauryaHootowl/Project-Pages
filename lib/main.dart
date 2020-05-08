import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_pages/common/hex_color.dart';
import 'package:project_pages/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'blocs/files_bloc.dart';
import 'file_model.dart';

const String boxName = 'fileBox';

void main() async{ 
  WidgetsFlutterBinding.ensureInitialized();
  final document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  Hive.registerAdapter(FileModelAdapter());
  await Hive.openBox<FileModel>(boxName);
  runApp(ChangeNotifierProvider<FilesBloc>.value(
      value: FilesBloc(),
      child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home()),
  ),
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int themeMode = 0;

  Color basicTextColor(){
    return (themeMode == 0) ? Colors.black87 : Colors.white70;
  }

  Future<bool> _onBackPressed(FilesBloc filesBloc) {
    String tempPlace =  filesBloc.getPath;
    if(tempPlace == '/'){
      SystemNavigator.pop();
    }else{
      print('lenstart : ${tempPlace.length-1}');
      for(int i = tempPlace.length-2; i >= 0; i--){
        if(tempPlace[i] == '/'){
          break;
        }else{
          tempPlace = tempPlace.substring(0,i);
        }
      }
      filesBloc.setPath = tempPlace;
    }
    
    return Future.value(false);
  }


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //debugPaintSizeEnabled = true;
    print('Main Page builded again!');
    final FilesBloc filesBloc = Provider.of<FilesBloc>(context, listen: false);
    return WillPopScope(
      onWillPop: (){ return _onBackPressed(filesBloc);},
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
          body: HomePage(),
          floatingActionButton: SpeedDialWidget(),
        ),
      ),
    );
  }
}





class SpeedDialWidget extends StatefulWidget {
  @override
  _SpeedDialWidgetState createState() => _SpeedDialWidgetState();
}

class _SpeedDialWidgetState extends State<SpeedDialWidget> {

  Icon dialIcon = Icon(Icons.add);
  void showDialogForAdd({int type}){
    // nameController.clear();
    showDialog(context: context,
      builder: (context){
        return DialogForAction(type);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: Icon(Icons.insert_drive_file, color: Colors.blue),
          backgroundColor: Colors.white,
          onTap: () {
            showDialogForAdd(type: 0);
          },
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
}


class DialogForAction extends StatefulWidget {

  int type;
  DialogForAction(int type){
    this.type = type;
  }

  @override
  _DialogForActionState createState() => _DialogForActionState();
}

class _DialogForActionState extends State<DialogForAction> {

  String selectedFilePath = 'null';
  String selectedStatus = '';
  bool _validateField = false;
  final TextEditingController nameController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    final FilesBloc filesBloc = Provider.of<FilesBloc>(context, listen: false);

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
              (widget.type == 0) ? 'Add New File' : 'Add New Folder',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.w600
              ),
            ),
            SizedBox(height: 20.0),
            
            (widget.type == 0) ? Row(
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
                hintText: (widget.type == 0) ? 'Enter a file Name' : 'Enter the Folder Name',
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
                  if(widget.type == 1 || (widget.type == 0 && selectedFilePath!='null'))
                  {
                    final String name = nameController.text;
                    final String path = selectedFilePath;
                    print(path);
                    FileModel file = FileModel(fileName: name, filePath: path, type: widget.type, place: filesBloc.getPath);
                    filesBloc.addToBox(file);
                    //fileBox.add(file);
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
}