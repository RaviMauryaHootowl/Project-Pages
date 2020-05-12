
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:project_pages/note_model.dart';

const String boxName = 'noteBox';

class NotesBloc extends ChangeNotifier{
  Box<NoteModel> noteBox;

  NotesBloc(){
    noteBox = Hive.box<NoteModel>(boxName); // initialized our box in fileBox
  }

  Map<int, NoteModel> queryBoxNotes(){
    List<int> keys = noteBox.keys.cast<int>().toList();
    Map<int, NoteModel> notes = {};
    for(int i = 0; i < keys.length; i++){
      notes.addAll({keys[i] : noteBox.get(keys[i])});
    }
    return notes;
  }

  NoteModel queryBoxNote(int keyToQuery){
    return noteBox.get(keyToQuery);
  }

  void addToBox(NoteModel fm, indexToSaveAt){
    if(indexToSaveAt == -1){
      noteBox.add(fm);
    }else{
      noteBox.put(indexToSaveAt, fm);
    }
    notifyListeners();
  }

  void deleteFromBox(int keyToDelete){
    noteBox.delete(keyToDelete);
    notifyListeners();
  }

  void deleteEverything(){
    noteBox.clear();
    notifyListeners();
  }


}

