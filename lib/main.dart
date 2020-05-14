import 'dart:async';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_pages/common/hex_color.dart';
import 'package:project_pages/note_model.dart';
import 'package:project_pages/pages/home_page.dart';
import 'package:project_pages/pages/notes_page.dart';
import 'package:provider/provider.dart';
import 'blocs/files_bloc.dart';
import 'blocs/notes_bloc.dart';
import 'file_model.dart';
import 'package:project_pages/router.dart' as router;

const String boxName = 'fileBox';
const String boxNameNotes = 'noteBox';

void main() async{ 
  WidgetsFlutterBinding.ensureInitialized();
  final document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  Hive.registerAdapter(FileModelAdapter());
  Hive.registerAdapter(NoteModelAdapter());
  await Hive.openBox<FileModel>(boxName);
  await Hive.openBox<NoteModel>(boxNameNotes);
  runApp(MultiProvider(
        providers: [
          ChangeNotifierProvider<FilesBloc>.value(
            value: FilesBloc(),
          ),
          ChangeNotifierProvider<NotesBloc>.value(
            value: NotesBloc(),
          ),
        ],
        child: MaterialApp(
        //debugShowCheckedModeBanner: false,
          onGenerateRoute: router.generateRoute,
          initialRoute: '/',
          //home: Home()),
        )
    ),
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int themeMode = 0;
  int _currentIndex = 1; 
  final List<Widget> _children = [
    NotesPage(),
    HomePage(),
    NotesPage()
  ]; 

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
    //var status = Permission.camera.status;
  }

  void setIndex(int i){
    setState(() {
      _currentIndex = i;
    });
  }

  // FocusScopeNode currentFocus = FocusScope.of(context);
  @override
  Widget build(BuildContext context) {

    //debugPaintSizeEnabled = true;
    final FilesBloc filesBloc = Provider.of<FilesBloc>(context, listen: false);
    print('Main Page builded again! -----');
    return WillPopScope(
      onWillPop: (){ return _onBackPressed(filesBloc);},
      child: GestureDetector(
        onTap: (){
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: (themeMode == 0) ? HexColor('EFEFEF') : HexColor('121212'),
          body: _children[_currentIndex],
          bottomNavigationBar: CustomNavBar(setIndex, _currentIndex),
        ),
      ),
    );
  }
}


class CustomNavBar extends StatelessWidget {
  Function setIndexF;
  int curIndex;
  CustomNavBar(Function setIndex, int i){
    setIndexF = setIndex;
    curIndex = i;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HexColor('EFEFEF'),
      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50.0),
          boxShadow: [
            BoxShadow(color: Colors.grey[300], blurRadius: 6.0, offset: Offset(0.5,0.5))
          ]
        ),
        
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: (){
                setIndexF(0);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.access_time, size: 30, 
                    color: (curIndex == 0) ? Colors.blue : Colors.grey[600],
                  ),
                  Text('Recent', style: TextStyle(fontSize: 12, 
                    color: (curIndex == 0) ? Colors.blue : Colors.grey[600],
                  ),),
                ],
              ),
            ),
          ),
          Expanded(
                      child: InkWell(
              onTap: (){setIndexF(1);},
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.home, size: 30, 
                    color: (curIndex == 1) ? Colors.blue : Colors.grey[600],
                  ),
                  Text('Home', style: TextStyle(fontSize: 12, 
                    color: (curIndex == 1) ? Colors.blue : Colors.grey[600],
                  ),),
                ],
              ),
            ),
          ),
          Expanded(
                      child: InkWell(
              onTap: (){setIndexF(2);},
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.note, size: 30, 
                    color: (curIndex == 2) ? Colors.blue : Colors.grey[600],
                  ),
                  Text('Quick Notes', style: TextStyle(fontSize: 12, 
                    color: (curIndex == 2) ? Colors.blue : Colors.grey[600],
                  ),),
                ],
              ),
            ),
          ),
          //Icon(Icons.home, size: 30, color: Colors.blue,),
          //Icon(Icons.note, size: 30,color: Colors.grey[600],),
        ],),
      ),
    );
  }
}