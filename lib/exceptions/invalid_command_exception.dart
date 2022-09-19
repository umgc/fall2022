class InvalidCommandException implements Exception {
  String cause;
  InvalidCommandException(this.cause);
}