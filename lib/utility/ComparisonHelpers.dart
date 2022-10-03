extension StringExtension on String {
  bool containsIgnoreCase(String str) {
    return this.toLowerCase().contains(str.toLowerCase());
  }
}