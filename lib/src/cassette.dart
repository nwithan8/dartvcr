import 'dart:convert';
import 'dart:io';

import 'request_elements/http_interaction.dart';

class Cassette {
  final String _filePath;
  final String name;

  bool _locked = false;

  Cassette(folderPath, this.name) : _filePath = '$folderPath/$name.json';

  int get numberOfInteractions => read().length;

  List<HttpInteraction> read() {
    List<HttpInteraction> interactions = [];

    if (!_exists()) {
      return interactions;
    }

    File file = File(_filePath);
    String fileContents = file.readAsStringSync();

    if (fileContents.isNotEmpty) {
      List<dynamic> json = jsonDecode(fileContents);

      interactions = json.map((e) => HttpInteraction.fromJson(e)).toList();
    }

    return interactions;
  }

  void update(HttpInteraction interaction) {
    File file = File(_filePath);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }

    _preWriteCheck();

    List<HttpInteraction> interactions = read();

    interactions.add(interaction);

    File(_filePath).writeAsStringSync(jsonEncode(interactions));
  }

  void erase() {
    File file = File(_filePath);
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  bool _exists() {
    File file = File(_filePath);
    return file.existsSync();
  }

  void lock() {
    _locked = true;
  }

  void unlock() {
    _locked = false;
  }

  void _preWriteCheck() {
    if (_locked) {
      throw Exception('Cassette $name is locked');
    }
  }
}
