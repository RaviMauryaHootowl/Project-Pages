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
        // NoteModel tempNote = NoteModel(noteText: 'Microsoft', noteTime: '7:48PM', noteColor: '#f1c40f');
        //notesBloc.addToBox(tempNote);
        Navigator.pushNamed(context, 'addNote', arguments: {
          'viewType' : 'add',
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

  @override
  Widget build(BuildContext context) {
    final NotesBloc notesBloc = Provider.of<NotesBloc>(context);
    Map<int, NoteModel> notesMap = notesBloc.queryBoxNotes();
    // create a list of keys
    List<int> noteKeys = notesMap.keys.cast<int>().toList().reversed.toList();
    // create a list of NoteModel
    List<NoteModel> notes = notesMap.values.cast<NoteModel>().toList().reversed.toList();

    return ListView.builder(
      itemBuilder: (_, index){
        return GestureDetector(
          onLongPress: (){
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
            margin: EdgeInsets.only(bottom: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: HexColor('${notes[index].noteColor}'),
            ),
            height: 100.0,
            child: Center(child : Text('${notes[index].noteText}')),
          )
        );
      },
      itemCount: notes.length,
      shrinkWrap: true,
    );
  }
}