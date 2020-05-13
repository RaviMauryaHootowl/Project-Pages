import 'package:flutter/material.dart';
import 'package:project_pages/main.dart';
import 'package:project_pages/pages/file_selection_page.dart';
import 'package:project_pages/pages/home_page.dart';
import 'package:project_pages/pages/add_note_page.dart';

Route<dynamic> generateRoute(RouteSettings settings){
  switch(settings.name){
    case '/':
      return MaterialPageRoute(builder: (context) => Home());
      break;
    case 'addNote':
      var argument = settings.arguments;
      return MaterialPageRoute(builder: (context) => AddNotePage(argument: argument,));
      break;
    case 'selectFile':
      return MaterialPageRoute(builder: (context) => FileSelectionPage());
      break;
    default:
      return MaterialPageRoute(builder: (context) => Home());
      break;
  }
}

