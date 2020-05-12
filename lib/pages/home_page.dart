import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:open_file/open_file.dart';
import 'package:project_pages/blocs/files_bloc.dart';
import 'package:project_pages/common/hex_color.dart';
import 'package:provider/provider.dart';
import 'package:flare_flutter/flare_actor.dart';

import '../file_model.dart';
int themeMode = 0;
Color basicTextColor(){
  return (themeMode == 0) ? Colors.black87 : Colors.white70;
}


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TopBar(),
            SearchBar(),
            PathBar(),
            Container(
              margin: EdgeInsets.only(bottom: 15.0),
              color: Colors.blue,
              height: 3.0,
            ),
            Expanded(
              child: Stack(
                children: <Widget>[
                  FilesListWidget(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: SpeedDialWidget()
                  ),
                ],
              ),
            ),
            //Container(height: 8, color: Colors.blue,)
          ],
        ),
      ),
    );
  }
}


class TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

class SearchBar extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final FilesBloc filesBloc = Provider.of<FilesBloc>(context);
    if(filesBloc.query == ''){
      _searchController.clear();
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        onChanged: (text){
          // filter listview 
          print(text);
          filesBloc.query = text;
          //filterList(text);
        },
        style: TextStyle(
          color: basicTextColor(),
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
    );
  }
}

class PathBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FilesBloc filesBloc = Provider.of<FilesBloc>(context);
    return Padding(
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
          GestureDetector(
            onTap: (){
              filesBloc.setPath = '/';
            },
            child: Icon(
              Icons.home, 
              color: Colors.blue,
            ),
          ),
          Flexible(
            child: Text(
              filesBloc.getPath,
              //(querySearch == '') ? curPlace : '--',
              style: TextStyle(
                fontSize: 20.0,
                color: basicTextColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FilesListWidget extends StatelessWidget {

  Future<void> openFile(String filePath) async {
    final result = await OpenFile.open(filePath);
    print('$result');
  }

  @override
  Widget build(BuildContext context) {
    final FilesBloc filesBloc = Provider.of<FilesBloc>(context);
    //List<int> keys = filesBloc.queryBox(filesBloc.getPath);
    List<FileModel> files = filesBloc.queryBoxFiles(filesBloc.getPath);
    print('list is builded again!!!! :)');
    return (files.isNotEmpty) ? ListView.separated(
      itemBuilder: (_, index){
        final FileModel file = files[index];
        return GestureDetector(
          onLongPress: (){
            showModalBottomSheet(context: context, builder: (context){
              return CustomMenuModal(file);
            });
          },
          child: ListTile(
            title: Text(
              file.fileName,
              style: TextStyle(
                fontSize: 18.0,
                color: basicTextColor(),
              ),
            ),
            leading: (file.type == 0) ? Image.asset('assets/pdficon.png', width: 24,) : Icon(Icons.folder, color: Colors.blue,),
            onTap: (){
              if(file.type == 0){
                openFile(file.filePath);
              }else{
                //open this folder
                filesBloc.query = '';
                filesBloc.setPath = file.place + file.fileName + '/';
                FocusScopeNode currentFocus = FocusScope.of(context);

                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              }
            },
          ),
        );
      },
      separatorBuilder: (_, index) => Divider(), 
      itemCount: files.length,
      shrinkWrap: true,
    ) : Container(
        child: FlareActor(
            'assets/anim.flr',
            animation: 'Idle',
            fit: BoxFit.contain,
          ),
      );
  }
}


class CustomMenuModal extends StatelessWidget {
  FileModel file;

  CustomMenuModal(FileModel file){
    this.file = file;
  }
  Future<void> openFile(String filePath) async {
    final result = await OpenFile.open(filePath);
    print('$result');
  }

  @override
  Widget build(BuildContext context) {
    final FilesBloc filesBloc = Provider.of<FilesBloc>(context, listen: false);
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
              title: Text((file.type == 0) ? 'Delete File' : 'Delete Folder', style: TextStyle(color: Colors.red),),
              onTap: (){
                Navigator.pop(context);
                // open confirmation Dialog box
                showDialog(context: context,
                  builder: (context){
                    return DeleteDialog(file);
                  }
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.edit, color: Colors.blue),
              title: Text((file.type == 0) ? 'Rename File' : 'Rename Folder', style: TextStyle(color: Colors.blue),),
              onTap: (){
                Navigator.pop(context);
                showDialog(context: context,
                  builder: (context){
                    return RenameDialog(file);
                  }
                );
                //openRenameDialog(keyToAction);
              },
            ),
            ListTile(
              leading: Icon(Icons.arrow_forward, color: Colors.blue),
              title: Text((file.type == 0) ? 'Open File' : 'Open Folder', style: TextStyle(color: Colors.blue),),
              onTap: (){
                Navigator.pop(context);

                // FileModel file = fileBox.get(keyToAction);
                if(file.type == 0){
                  openFile(file.filePath);
                }else{
                  //open this folder
                  filesBloc.setPath = file.place + file.fileName + '/';
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

class DeleteDialog extends StatelessWidget {
  final FileModel file;
  DeleteDialog(this.file);

  @override
  Widget build(BuildContext context) {
    final FilesBloc filesBloc = Provider.of<FilesBloc>(context);
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
              (file.type == 0) ? 'By deleting this, it won\'t delete the actual file.'
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
                    filesBloc.deleteFromBox(file);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RenameDialog extends StatelessWidget {
  final FileModel file;
  RenameDialog(this.file);
  TextEditingController _renameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final FilesBloc filesBloc = Provider.of<FilesBloc>(context, listen: false);
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
                    String _newName = _renameController.text;

                    filesBloc.renameFromBox(file, _newName);
                  },
                ),
              ],
            ),
          ],
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
    return Padding(
      padding: EdgeInsets.only(right:16),
      child: SpeedDial(
        
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
      ),
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