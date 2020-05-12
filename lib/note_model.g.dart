// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteModelAdapter extends TypeAdapter<NoteModel> {
  @override
  final typeId = 6;

  @override
  NoteModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{};
    for(var i = 0; i < numOfFields; i++){
      fields.addAll({reader.readByte(): reader.read()});
    }
    return NoteModel(
      noteText: fields[7] as String,
      noteTime: fields[8] as String,
      noteColor: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NoteModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(7)
      ..write(obj.noteText)
      ..writeByte(8)
      ..write(obj.noteTime)
      ..writeByte(9)
      ..write(obj.noteColor);
  }
}
