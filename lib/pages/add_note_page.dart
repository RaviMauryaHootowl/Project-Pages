import 'package:flutter/material.dart';
import 'package:project_pages/blocs/notes_bloc.dart';
import 'package:project_pages/common/hex_color.dart';
import 'package:project_pages/note_model.dart';
import 'package:provider/provider.dart';

class AddNotePage extends StatefulWidget {
  @override
  _AddNotePageState createState() => _AddNotePageState();
  final Map argument;
  AddNotePage({this.argument});
}

class _AddNotePageState extends State<AddNotePage> {
  final TextEditingController _noteController = TextEditingController();
  int colorIndex = 0;
  List<String> colors = ['A1FF92', 'FFD392', 'D2A5FF', '92CAFF', 'DFDFDF'];
  Map args = {};
  int loadedIndex = -1;
  @override
  Widget build(BuildContext context) {
    final NotesBloc notesBloc = Provider.of<NotesBloc>(context, listen: false);
    if(args.isEmpty){
      args = widget.argument;
      print(args);
      if(args['key'] != -1){
        loadedIndex = args['key'];
        NoteModel loadedNote = notesBloc.queryBoxNote(loadedIndex);
        _noteController.text = loadedNote.noteText;
        for(int i = 0; i < colors.length; i++){
          if(loadedNote.noteColor == colors[i]){
            colorIndex = i;
            break;
          }
        }
      }
    }
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            padding: EdgeInsets.all(10.0),
            color: HexColor(colors[colorIndex]),
            child: Column(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: "Type your note here",
                      border: InputBorder.none,
                    ),
                    scrollPadding: EdgeInsets.all(20.0),
                    keyboardType: TextInputType.multiline,
                    maxLines: 99999,
                    autofocus: true,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: (){
                        setState(() {
                          colorIndex = 0; 
                        });
                      },
                      child: Card(
                        elevation: 10.0,
                        shape: CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: CircleAvatar(
                          backgroundColor: HexColor(colors[0]),
                          radius: 20,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        setState(() {
                          colorIndex = 1; 
                        });
                      },
                      child: Card(
                        elevation: 10.0,
                        shape: CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: CircleAvatar(
                          backgroundColor: HexColor(colors[1]),
                          radius: 20,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        setState(() {
                          colorIndex = 2; 
                        });
                      },
                      child: Card(
                        elevation: 10.0,
                        shape: CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: CircleAvatar(
                          backgroundColor: HexColor(colors[2]),
                          radius: 20,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        setState(() {
                          colorIndex = 3; 
                        });
                      },
                      child: Card(
                        elevation: 10.0,
                        shape: CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: CircleAvatar(
                          backgroundColor: HexColor(colors[3]),
                          radius: 20,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        setState(() {
                          colorIndex = 4; 
                        });
                      },
                      child: Card(
                        elevation: 10.0,
                        shape: CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: CircleAvatar(
                          backgroundColor: HexColor(colors[4]),
                          radius: 20,
                        ),
                      ),
                    ),
                    FlatButton(onPressed: (){
                      NoteModel tempNote = NoteModel(noteText : _noteController.text, noteColor: colors[colorIndex], noteTime: '');
                      notesBloc.addToBox(tempNote, loadedIndex);
                      Navigator.pop(context);
                      }, 
                      child: Text('Save')
                    )
                  ]
                )
                
              ]
            ),
          ),
        ),
      ),
    );
  }
}