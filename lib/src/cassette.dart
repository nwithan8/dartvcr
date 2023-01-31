import 'dart:convert';
import 'dart:io';

import 'request_elements/http_interaction.dart';

/// A class representing a cassette that contains a list of [HttpInteraction]s.
class Cassette {
  /// The path to the cassette file.
  final String _filePath;

  /// The name of the cassette.
  final String name;

  /// Whether or not the cassette is locked (i.e. being written to).
  bool _locked = false;

  /// Creates a new [Cassette] with the given [name] and [folderPath].
  Cassette(folderPath, this.name) : _filePath = '$folderPath/$name.json';

  /// Returns the number of interactions in the cassette.
  int get numberOfInteractions => read().length;

  /// Returns a list of all [HttpInteraction]s in the cassette.
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

  /// Adds or overwrites the given [interaction] to the cassette.
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

  /// Deletes the cassette file.
  void erase() {
    File file = File(_filePath);
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  /// Returns true if the cassette file exists.
  bool _exists() {
    File file = File(_filePath);
    return file.existsSync();
  }

  /// Locks the cassette so that it cannot be written to.
  void lock() {
    _locked = true;
  }

  /// Unlocks the cassette so that it can be written to.
  void unlock() {
    _locked = false;
  }

  /// Check if the cassette can be written to.
  void _preWriteCheck() {
    if (_locked) {
      throw Exception('Cassette $name is locked');
    }
  }
}
