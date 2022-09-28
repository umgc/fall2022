import '../models/MailPiece.dart';

/// The `MailStorage` class saves a piece of mail to the database.
class MailStorage {
  /// The latest timestamp associated with a stored piece of mail.
  /// This should be used to fetch new mail, ensuring mail received
  /// before this date is already stored and does not need to get fetched.
  DateTime LastTimestamp = DateTime.now().subtract(new Duration(days: 7));

  MailStorage()
  {
    //todo: if any MailPiece records exist, get the latest one
    //todo: set LastTimestamp to latest date
  }
  /// Persist a piece of mail to the database.
  /// The return value is whether or not the mail was saved as a new piece.
  /// Saving an already stored piece of mail should either update the existing
  /// item or noop, returning false.
  bool save(MailPiece piece) {
    //todo: commit to database
    return true;
  }
}