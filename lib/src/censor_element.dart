class CensorElement {
  final String name;

  final bool caseSensitive;

  CensorElement(this.name, {this.caseSensitive = false});

  bool matches(String key) {
    if (caseSensitive) {
      return key == name;
    } else {
      return key.toLowerCase() == name.toLowerCase();
    }
  }
}
