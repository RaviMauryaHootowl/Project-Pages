import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_pages/common/hex_color.dart';
import 'package:project_pages/pages/home_page.dart';

class FileSelectionPage extends StatefulWidget {
  @override
  _FileSelectionPageState createState() => _FileSelectionPageState();
}


class _FileSelectionPageState extends State<FileSelectionPage> {
  final TextEditingController _searchController = TextEditingController();

  //String res = 'Loading';
  String searchQ = '';
  List<String> curFiles = [];
  List<String> curFilesPath = [];
  List<dynamic> files = [];
  static const platform = const MethodChannel("com.raviowl.project_pages/pages");
  void getFilePath() async{
    try{
      files = await platform.invokeMethod("getFiles");
      updateQuerySearch('');
    }catch(e){
      print(e);
    }
  }
 


  void updateQuerySearch(String query){
    curFiles.clear();
    curFilesPath.clear();
    List<String> tempNames = [];
    List<String> tempPaths = [];
    for(int i = 0; i < files.length; i++){
      if(files[i][0].toLowerCase().contains(query.toLowerCase())){
        tempNames.add(files[i][0]);
        tempPaths.add(files[i][1]);
      }
    }
    setState(() {
      curFiles = tempNames;
      curFilesPath = tempPaths;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(files.isEmpty){
      getFilePath();
    }
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Text(
                'Select your File',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 25.0
                ),
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (text) {
                          updateQuerySearch(text);
                        },
                        style: TextStyle(
                          color: basicTextColor(),
                        ),
                        cursorColor: Colors.black45,
                        decoration: InputDecoration(
                          hintText: 'Search within ${files.length} files',
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
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Expanded(
                child: (files.length != 0) ? Container(
                  child: ListView.builder(
                    itemCount: curFiles.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: (){
                          Navigator.pop(context, curFilesPath[index]);
                        },
                        title: Text(curFiles[index]),
                      );
                    }
                  )
                ) : Text('Loading...'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
