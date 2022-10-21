import 'package:summer2022/services/sqlite_database.dart';
import 'package:summer2022/exceptions/fetch_mail_exception.dart';

import '../models/MailPiece.dart';
import '../models/MailSearchParameters.dart';

class MailService {
  /// Retrieves all mail from local cache that matches [searchArgs.keyword] and is within [searchArgs.startDate] and [searchArgs.endDate]
  /// [searchArgs.startDate] and [searchArgs.endDate] should either both have values or both be null
  /// throws a [FetchMailException] error if retrieval, parsing, or filtering fails
  Future<List<MailPiece>> fetchMail(MailSearchParameters searchArgs) async {
    try {
      _formatDateTimeForSearch(searchArgs);

      return await searchMailPieces(searchArgs);
    } catch (e) {
      throw new FetchMailException(e.toString());
    }
  }

  /// Formats [searchArgs.startDate] and [searchArgs.endDate] for search
  void _formatDateTimeForSearch(MailSearchParameters searchArgs) {
    if (searchArgs.startDate != null) {
      searchArgs.startDate = new DateTime(searchArgs.startDate!.year,
              searchArgs.startDate!.month, searchArgs.startDate!.day)
          .add(Duration(milliseconds: -1));
    }

    if (searchArgs.endDate != null) {
      searchArgs.endDate = new DateTime(searchArgs.endDate!.year,
              searchArgs.endDate!.month, searchArgs.endDate!.day)
          .add(Duration(days: 1, milliseconds: -1));
    }
  }

  /// Returns all mail pieces that match the provided query.
  /// Any empty or null query returns all mail pieces.
  Future<List<MailPiece>> searchMailPieces(searchArgs) async {
    List<String> queryList = [];
    if (searchArgs.keyword != null) {
      queryList.add("(image_text LIKE '%${searchArgs.keyword}%' OR sender LIKE '%${searchArgs.keyword}%')");
    }
    else if(searchArgs.senderKeyword != null || searchArgs.mailBodyKeyword != null){
      queryList.add("(image_text LIKE '%${searchArgs.mailBodyKeyword ?? ""}%' AND sender LIKE '%${searchArgs.senderKeyword ?? ""}%')");
    }
    if (searchArgs.startDate != null && searchArgs.endDate != null) {
      DateTime start = searchArgs.startDate;
      DateTime end = searchArgs.endDate;
      queryList.add(
          "timestamp >= '${start.millisecondsSinceEpoch}' AND timestamp <= '${end.millisecondsSinceEpoch}'");
    }

    String query = queryList.join(" AND ");
    try {
      final db = await database;
      final result = query.isEmpty
          ? await db.query(MAIL_PIECE_TABLE)
          : await db.query(MAIL_PIECE_TABLE, where: query);
      return result
          .map((row) => MailPiece(
              row["id"] as String,
              row["email_id"] as String,
              DateTime.fromMillisecondsSinceEpoch(row["timestamp"] as int),
              row["sender"] as String,
              row["image_text"] as String,
              row["midId"] as String))
          .toList();
    } catch (e) {
      throw new FetchMailException(e.toString());
    }
  }
}
