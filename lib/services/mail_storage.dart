import 'package:summer2022/services/sqlite_database.dart';

import '../models/MailPiece.dart';

/// The `MailStorage` class saves a piece of mail to the database.
class MailStorage {
  /// The latest timestamp associated with a stored piece of mail.
  /// This should be used to fetch new mail, ensuring mail recieved
  /// before this date is already stored and does not need to get fetched.
  Future<DateTime> get lastTimestamp async {
    final db = await database;
    final result = await db.query(MAIL_PIECE_TABLE,
        orderBy: "timestamp DESC", limit: 1, columns: ["timestamp"]);
    if (result.isEmpty) {
      return DateTime.now().subtract(Duration(days: 7));
    } else {
      final timestamp = result[0]["timestamp"] as int;
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
  }

  /// Persist a peice of mail to the database.
  /// The return value is whether or not the mail was saved as a new piece.
  /// Saving an already stored piece of mail should either update the existing
  /// item or noop, returning false.
  Future<bool> saveMailPiece(MailPiece piece) async {
    final db = await database;
    final data = {
      "id": piece.id,
      "email_id": piece.emailId,
      "sender": piece.sender,
      "image_text": piece.imageText,
      "timestamp": piece.timestamp.millisecondsSinceEpoch,
      "midId": piece.midId
    };
    try {
      await db.insert(MAIL_PIECE_TABLE, data);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Retrieves a mail piece by its ID, otherwise returns null.
  Future<MailPiece?> getMailPiece(String id) async {
    final db = await database;
    final result =
        await db.query(MAIL_PIECE_TABLE, where: "id = ?", whereArgs: [id]);
    if (result.isEmpty) return null;
    return MailPiece(
        result[0]["id"]?.toString() ?? "",
        result[0]["email_id"]?.toString() ?? "",
        DateTime.fromMillisecondsSinceEpoch(result[0]["timestamp"] as int),
        result[0]["sender"]?.toString() ?? "",
        result[0]["image_text"]?.toString() ?? "",
        result[0]["midId"]?.toString() ?? "");
  }

  /// Returns all mail pieces that match the provided query.
  /// Any empty or null query returns all mail pieces.
  Future<List<MailPiece>> searchMailsPieces(String? query) async {
    final db = await database;
    final result = await db.query(MAIL_PIECE_TABLE,
        where: "image_text LIKE '%' || ? || '%'", whereArgs: [query ?? ""]);
    return result
        .map((row) =>
        MailPiece(
            row["id"].toString() ?? "",
            row["email_id"]?.toString() ?? "",
            DateTime.fromMillisecondsSinceEpoch(row["timestamp"] as int),
            row["sender"]?.toString() ?? "",
            row["image_text"]?.toString() ?? "",
            row["midId"]?.toString() ?? ""))
        .toList();
  }
}
