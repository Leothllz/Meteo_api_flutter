import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class JsonFileManager {
  static Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/favorites.json');
  }

  static Future<List<String>> readFavorites() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      return List<String>.from(json.decode(contents));
    } catch (e) {
      return [];
    }
  }

  static Future<File> writeFavorites(List<String> favorites) async {
    final file = await _getFile();
    return file.writeAsString(json.encode(favorites));
  }
}
