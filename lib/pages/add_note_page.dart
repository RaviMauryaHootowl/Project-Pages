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

final Map<String, String> ligthToDark = {
  'A1FF92' : '6fc961', 
  'FFD392' : 'dbac67', 
  'D2A5FF' : '9e6bd1', 
  '92CAFF' : '609ad1', 
  'DFDFDF' : 'a1a1a1'
};

class _AddNotePageState extends State<AddNotePage> {
  final TextEditingController _noteController = TextEditingController();
  int colorIndex = 0;
  List<String> colors = ['A1FF92', 'FFD392', 'D2A5FF', '92CAFF', 'DFDFDF'];
  Map args = {};
  int loadedIndex = -1;

  Widget colorButton(int curColorButtonIndex){
    return InkWell(
      onTap: (){
        setState(() {
          colorIndex = curColorButtonIndex; 
        });
      },
      child: Card(
        elevation: 10.0,
        shape: CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: CircleAvatar(
          child: (colorIndex == curColorButtonIndex) ? Icon(Icons.done) : null,
          backgroundColor: HexColor(colors[curColorButtonIndex]),
          radius: 20,
        ),
      ),
    );
  }


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
            padding: EdgeInsets.only(bottom: 5.0),
            decoration: BoxDecoration(
                color: HexColor(ligthToDark[colors[colorIndex]]),
                borderRadius: BorderRadius.circular(10.0)
            ),
            child: Container(
              decoration: BoxDecoration(
                color: HexColor(colors[colorIndex]),
                borderRadius: BorderRadius.circular(10.0)
              ),
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Expanded(
                    child: TextField(
                      style: TextStyle(
                        fontSize: 18,
                      ),
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
                      colorButton(0),
                      colorButton(1),
                      colorButton(2),
                      colorButton(3),
                      colorButton(4),
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
      ),
    );
  }
}