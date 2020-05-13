import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storage_path/storage_path.dart';

class FileSelectionPage extends StatefulWidget {
  @override
  _FileSelectionPageState createState() => _FileSelectionPageState();
}

class _FileSelectionPageState extends State<FileSelectionPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //getAudioPath();
    //getVideoPath();
  }

  // Future<void> getImagesPath() async {
  //   String imagespath = "";
  //   try {
  //     imagespath = await StoragePath.imagesPath;
  //     var response = jsonDecode(imagespath);
  //     print(response);
  //     var imageList = response as List;
  //     List<FileModel> list =
  //         imageList.map<FileModel>((json) => FileModel.fromJson(json)).toList();

  //     setState(() {
  //       imagePath = list[11].files[0];
  //     });
  //   } on PlatformException {
  //     imagespath = 'Failed to get path';
  //   }
  //   return imagespath;
  // }

  // Future<void> getVideoPath() async {
  //   String videoPath = "";
  //   try {
  //     videoPath = await StoragePath.videoPath;
  //     var response = jsonDecode(videoPath);
  //     //print(response);
  //   } on PlatformException {
  //     videoPath = 'Failed to get path';
  //   }
  //   return videoPath;
  // }

  // Future<void> getAudioPath() async {
  //   String audioPath = "";
  //   try {
  //     audioPath = await StoragePath.audioPath;
  //     var response = jsonDecode(audioPath);
  //     //print(response);
  //   } on PlatformException {
  //     audioPath = 'Failed to get path';
  //   }
  //   return audioPath;
  // }

  String searchQ = '';
  List<String> allfiles = [];
  List<String> allfilesPath = [];
  List<String> allfilesFolderName = [];
  Future<void> getFilePath() async {
    String filePath = "";
    var response;
    try {
      filePath = await StoragePath.filePath;
      response = jsonDecode(filePath);
      //print('--------------------------');
      //print(response[0]['files'][0]['path']);
      //print('--------------------------');
      //Clipboard.setData(ClipboardData(text: filePath.toString()));
    } on PlatformException {
      filePath = 'Failed to get path';
    }

    //
    List<String> allFileName = [];
    List<String> allFileLocation = [];
    List<String> allFileFolderName = [];
    int noOfFolders = response.length;
    for (int i = 0; i < noOfFolders; i++) {
      int noOfFiles = response[i]['files'].length;
      for (int j = 0; j < noOfFiles; j++) {
        Map thisFile = response[i]['files'][j];
        if (thisFile['mimeType'] == 'application/pdf') {
          if (searchQ != '') {
            if (thisFile['title']
                .toString()
                .toLowerCase()
                .contains(searchQ.toLowerCase())) {
              allFileName.add(thisFile['title']);
              allFileLocation.add(thisFile['path']);
              allfilesFolderName.add(response[i]['folderName']);
            }
          } else {
            allFileName.add(thisFile['title']);
            allFileLocation.add(thisFile['path']);
            allfilesFolderName.add(response[i]['folderName']);
          }
        }
      }
      //print(response[i]['folderName']);
    }
    //print('Total Number of Files are : ${allFileLocation.length}');
    //
    setState(() {
      allfiles = allFileName;
      allfilesPath = allFileLocation;
      allFileFolderName = allFileFolderName;
    });
    //return allFileLocation;

    // setState(() {
    //   allfiles = filePath;
    // });
    // // JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    // // String prettyprint = encoder.convert(filePath);
    // // print(prettyprint);
    // return filePath;
  }

  @override
  Widget build(BuildContext context) {
    if(allfiles.isEmpty){
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
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                          hintText: 'Search within ${allfiles.length} files'),
                      onChanged: (text) {
                        allfiles.clear();
                        allfilesPath.clear();
                        allfilesFolderName.clear();
                        setState(() {
                          searchQ = text;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Expanded(
                child: Container(
                  child: ListView.builder(
                    itemCount: allfiles.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: (){
                          Navigator.pop(context, allfilesPath[index]);
                        },
                        title: Text(allfiles[index]),
                        subtitle: Text('Folder: ${allfilesFolderName[index]}'),
                      );
                    }
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
