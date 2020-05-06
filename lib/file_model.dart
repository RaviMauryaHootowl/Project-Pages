import 'package:hive/hive.dart';

part 'file_model.g.dart';
// flutter packages pub run build_runner build

@HiveType(typeId: 0)
class FileModel{
  @HiveField(1)
  String fileName;
  @HiveField(2)
  String filePath;
  @HiveField(3)
  int type;
  @HiveField(4)
  String place;

  FileModel({this.fileName, this.filePath, this.type, this.place});

}