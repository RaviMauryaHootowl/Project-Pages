
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../file_model.dart';

const String boxName = 'fileBox';

class FilesBloc extends ChangeNotifier{
  Box<FileModel> fileBox;
  String _q = '';
  String _path = '/';
  //List<int> keysList;

  set query(String qq){
    _q = qq;
    notifyListeners();
  }

  get query => _q;

  set setPath(String p){
    _path = p;
    notifyListeners();
  }

  String get getPath => _path;

  FilesBloc(){
    fileBox = Hive.box<FileModel>(boxName); // initialized our box in fileBox
  }

  List<int> queryBox(String curPlace){
    List<int> keys = fileBox.keys.cast<int>().toList();
    for(int i = 0; i < keys.length; i++){
      final FileModel tempfile = fileBox.get(keys[i]);
      if(_q != ''){
        if(!tempfile.fileName.toLowerCase().contains(_q.toLowerCase())){
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

    return keys;
  }
  
  List<FileModel> queryBoxFiles(String curPlace){
    List<int> keys = fileBox.keys.cast<int>().toList();
    for(int i = 0; i < keys.length; i++){
      final FileModel tempfile = fileBox.get(keys[i]);
      if(_q != ''){
        if(!tempfile.fileName.toLowerCase().contains(_q.toLowerCase())){
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
    List<FileModel> files = [];
    for(int i = 0; i < keys.length; i++){
      files.add(fileBox.get(keys[i]));
    }
    return files;
  }

  void addToBox(FileModel fm){
    fileBox.add(fm);
    notifyListeners();
  }

  void deleteFromBox(FileModel fileToDelete){
    List<FileModel> allfiles = fileBox.values.toList();
    List<int> allkeys = fileBox.keys.cast<int>().toList();
    int keyToDelete = allkeys[allfiles.indexWhere((fileX) => fileX == fileToDelete)];
    //FileModel fileToDelete = fileBox.get(keyToDelete);
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
    notifyListeners();
  }

  void renameFromBox(FileModel fileToRename, String newName){
    List<FileModel> allfiles = fileBox.values.toList();
    List<int> allkeys = fileBox.keys.cast<int>().toList();
    int keyToRename = allkeys[allfiles.indexWhere((fileX) => fileX == fileToRename)];
    String pathOfTheFileToBeRenamed = fileToRename.place;
    for(int i = 0; i < allkeys.length; i++){
      if(fileBox.get(allkeys[i]).place.startsWith(pathOfTheFileToBeRenamed) && fileBox.get(allkeys[i]).place != pathOfTheFileToBeRenamed){

        int lenOfPrePath = pathOfTheFileToBeRenamed.length;
        int posOfEnding = fileToRename.fileName.length + lenOfPrePath;
        String newPlacePath = pathOfTheFileToBeRenamed + newName + fileBox.get(allkeys[i]).place.substring(posOfEnding);
        FileModel _tempModel = fileBox.get(allkeys[i]);
        _tempModel.place = newPlacePath;
        fileBox.put(allkeys[i], _tempModel);
      }
    }
    FileModel _tempModel = fileBox.get(keyToRename);
    _tempModel.fileName = newName;
    fileBox.put(keyToRename, _tempModel);

    notifyListeners();
  }
}

