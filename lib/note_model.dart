import 'package:hive/hive.dart';

part 'note_model.g.dart';
// flutter packages pub run build_runner build

@HiveType(typeId: 6)
class NoteModel{
  @HiveField(7)
  String noteText;
  @HiveField(8)
  String noteTime;
  @HiveField(9)
  String noteColor;

  NoteModel({this.noteText, this.noteTime, this.noteColor});

}