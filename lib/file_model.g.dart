// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FileModelAdapter extends TypeAdapter<FileModel> {
  @override
  final typeId = 0;

  @override
  FileModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    
    var fields = <int, dynamic>{};
    for(var i = 0; i < numOfFields; i++){
      fields.addAll({reader.readByte(): reader.read()});
    }
    return FileModel(
      fileName: fields[1] as String,
      filePath: fields[2] as String,
      type: fields[3] as int,
      place: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FileModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(1)
      ..write(obj.fileName)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.place);
  }
}
