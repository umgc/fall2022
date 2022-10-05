import 'package:flutter_test/flutter_test.dart';
import 'package:fall2022/models/MailPiece.dart';
import 'package:fall2022/services/mail_storage.dart';
import 'package:fall2022/services/sqlite_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MailStorage subject = MailStorage();

  DateTime now = DateTime.now();
  DateTime future = DateTime.now().add(Duration(days: 1));

  setUpAll(() async {
    await setUpTestDatabase();
  });

  setUp(() async {
    final db = await database;
    // Clear the table.
    await db.execute("""
      DELETE FROM $MAIL_PIECE_TABLE;
    """);
  });

  test("it defaults the last timestamp to 7 days ago", () async {
    await _expectMailPieceCount(0);
    final expected = now.subtract(Duration(days: 7)).millisecondsSinceEpoch;
    final actual = await subject.lastTimestamp;
    // Within 1 second, which can happen due to async timing.
    expect(actual.millisecondsSinceEpoch, closeTo(expected, 1000));
  });

  test("it can saveMailPiece a new mail piece", () async {
    final piece =
        MailPiece("test", "test", now, "someone", "some text", "test");

    expect(await subject.saveMailPiece(piece), true);

    await _expectMailPieceCount(1);
    await _expectMailPieceExists(piece);
  });

  test("it can fetch the latest timestamp", () async {
    final pieceOne =
        MailPiece("test-one", "test", now, "someone", "some text", "test");
    final pieceTwo =
        MailPiece("test-two", "test", future, "someone", "some text", "test");

    expect(await subject.saveMailPiece(pieceOne), true);
    expect(await subject.saveMailPiece(pieceTwo), true);

    final timestamp = await subject.lastTimestamp;
    expect(timestamp.millisecondsSinceEpoch, future.millisecondsSinceEpoch);
  });

  test("it does not saveMailPiece duplicate mail pieces", () async {
    final piece =
        MailPiece("test", "test", now, "someone", "some text", "test");

    expect(await subject.saveMailPiece(piece), true);
    expect(await subject.saveMailPiece(piece), false);

    await _expectMailPieceCount(1);
    await _expectMailPieceExists(piece);
  });

  test("it can retrieve a mail piece by its id", () async {
    final piece =
        MailPiece("test", "test", now, "someone", "some text", "test");
    expect(await subject.saveMailPiece(piece), true);

    expect(await subject.getMailPiece(piece.id), piece);
    expect(await subject.getMailPiece("some-other-id"), null);
  });

  group("when searching for mail pieces", () {
    final pieceOne =
        MailPiece("test-one", "test", now, "someone", "some text", "test");
    final pieceTwo = MailPiece(
        "test-two", "test", now, "someone", "some other text", "test");
    final pieceThree =
        MailPiece("test-three", "test", now, "someone", "bananas", "fruit");

    setUp(() async {
      expect(await subject.saveMailPiece(pieceOne), true);
      expect(await subject.saveMailPiece(pieceTwo), true);
      expect(await subject.saveMailPiece(pieceThree), true);
    });

    test("it retrieves matching mail pieces", () async {
      final results = await subject.searchMailsPieces("text");
      expect(results.length, 2);
      expect(results, containsAll([pieceOne, pieceTwo]));
    });

    test("it retrieves all mail pieces when provided a null query", () async {
      final results = await subject.searchMailsPieces(null);
      expect(results.length, 3);
      expect(results, containsAll([pieceOne, pieceTwo, pieceThree]));
    });

    test("it returns an empty list when no mail pieces match", () async {
      final results = await subject.searchMailsPieces("godzilla");
      expect(results.length, 0);
    });
  });
}

Future<void> _expectMailPieceCount(int count) async {
  final db = await database;
  final results = await db.query(MAIL_PIECE_TABLE);
  expect(results.length, count);
}

Future<void> _expectMailPieceExists(MailPiece piece) async {
  final db = await database;
  final results =
      await db.query(MAIL_PIECE_TABLE, where: "id = ?", whereArgs: [piece.id]);
  expect(results.length, 1);
  expect(results[0]["id"], piece.id);
  expect(results[0]["email_id"], piece.emailId);
  expect(results[0]["sender"], piece.sender);
  expect(results[0]["image_text"], piece.imageText);
}
