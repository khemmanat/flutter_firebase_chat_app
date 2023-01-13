class StringHelper {
  isEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  String overFlowText(String text, {double? parseLength}) {
    if (parseLength != null) {
      return text.length > parseLength
          ? "${text.substring(0, parseLength.toInt())}..."
          : text;
    } else {
      return text.length > 8 ? "${text.substring(0, 8)}..." : text;
    }
  }
}
