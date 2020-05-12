import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:open_file/open_file.dart';
import 'package:project_pages/blocs/files_bloc.dart';
import 'package:project_pages/blocs/notes_bloc.dart';
import 'package:project_pages/common/hex_color.dart';
import 'package:project_pages/main.dart';
import 'package:provider/provider.dart';
import 'package:flare_flutter/flare_actor.dart';
import '../file_model.dart';
import '../note_model.dart';
int themeMode = 0;
Color basicTextColor(){
  return (themeMode == 0) ? Colors.black87 : Colors.white70;
}

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
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
            Container(
              margin: EdgeInsets.only(bottom: 15.0, top: 10.0),
              color: Colors.blue,
              height: 3.0,
            ),
            Expanded(
              child: Stack(
                children: <Widget>[
                  NotesListWidget(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: AddButtonWidget(),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AddButtonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final NotesBloc notesBloc = Provider.of<NotesBloc>(context, listen: false);
    return MaterialButton(
      onPressed: () {
        //notesBloc.deleteEverything();
        Navigator.pushNamed(context, 'addNote', arguments: {
          'viewType' : 'add',
          'key' : -1,
        });
      },
      color: Colors.blue,
      textColor: Colors.white,
      child: Icon(
        Icons.add,
        size: 24,
      ),
      elevation: 5,
      padding: EdgeInsets.all(16),
      shape: CircleBorder(),
    );
  }
}

class TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: <Widget>[
          Row(
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
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                'Quick Notes',
                style: TextStyle(
                  fontSize: 20.0,
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
        ],
      ),
    );
  }
}

class NotesListWidget extends StatefulWidget {
  @override
  _NotesListWidgetState createState() => _NotesListWidgetState();
}

class _NotesListWidgetState extends State<NotesListWidget> {

  final Map<String, String> ligthToDark = {
    'A1FF92' : '6fc961', 
    'FFD392' : 'dbac67', 
    'D2A5FF' : '9e6bd1', 
    '92CAFF' : '609ad1', 
    'DFDFDF' : 'a1a1a1'
  };

  @override
  Widget build(BuildContext context) {
    print(HexColor('#d19945'));
    final NotesBloc notesBloc = Provider.of<NotesBloc>(context);
    Map<int, NoteModel> notesMap = notesBloc.queryBoxNotes();
    // create a list of keys
    List<int> noteKeys = notesMap.keys.cast<int>().toList().reversed.toList();
    // create a list of NoteModel
    List<NoteModel> notes = notesMap.values.cast<NoteModel>().toList().reversed.toList();

    return (noteKeys.isNotEmpty) ? ListView.builder(
      itemBuilder: (_, index){
        return GestureDetector(
          onLongPress: (){
            print('You Long Pressed on key - ${noteKeys[index]} and index - $index');
            showModalBottomSheet(context: context, builder: (context){
              return CustomMenuModalNote(keyOfNote: noteKeys[index]);
            });
          },
          onTap: (){ 
            Navigator.pushNamed(context, 'addNote',
              arguments: {
                'viewType' : 'view',
                'key' : noteKeys[index],
              }
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: HexColor(ligthToDark[notes[index].noteColor]),
            ),
            padding: EdgeInsets.fromLTRB(0, 0, 0, 5.0),
            margin: EdgeInsets.only(bottom: 10.0),
            child: Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: HexColor('${notes[index].noteColor}'),
              ),
              height: 100.0,
              child: Text(
                '${notes[index].noteText}',
                overflow: TextOverflow.fade,
                style: TextStyle(
                  fontSize: 16
                ),
              ),
            ),
          )
        );
      },
      itemCount: notes.length,
      shrinkWrap: true,
    ) : Center(
      child: Container(
        child: Image.asset('assets/1.png', width: 200,),
          // child: FlareActor(
          //     'assets/anim.flr',
          //     animation: 'Idle',
          //     fit: BoxFit.contain,
          //   ),
        ),
    );
  }
}

class CustomMenuModalNote extends StatelessWidget {
  
  final int keyOfNote;
  CustomMenuModalNote({this.keyOfNote});


  @override
  Widget build(BuildContext context) {
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
              title: Text('Delete Note', style: TextStyle(color: Colors.red),),
              onTap: (){
                Navigator.pop(context);
                // open confirmation Dialog box
                showDialog(context: context,
                  builder: (context){
                    return DeleteDialog(keyOfNote : keyOfNote);
                  }
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.edit, color: Colors.blue),
              title: Text('View And Edit Note', style: TextStyle(color: Colors.blue),),
              onTap: (){
                Navigator.pop(context);
                Navigator.pushNamed(context, 'addNote',
                  arguments: {
                    'viewType' : 'view',
                    'key' : keyOfNote,
                  }
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class DeleteDialog extends StatelessWidget {
  final int keyOfNote;
  DeleteDialog({this.keyOfNote});

  @override
  Widget build(BuildContext context) {
    print('You are about to delete key - $keyOfNote');
    final NotesBloc notesBloc = Provider.of<NotesBloc>(context);
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
                    notesBloc.deleteFromBox(keyOfNote);
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