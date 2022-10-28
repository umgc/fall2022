import 'dart:async';
import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const String MAIL_PIECE_TABLE = "mail_piece";
const NOTIFICATION_TABLE = "notification";
const NOTIFICATION_SUBSCRIPTION_TABLE = "notification_subscription";

String _dbPath = "mail.db";

Future<Database> get database async {
  return await openDatabase(_dbPath,
      version: 3,
      onConfigure: _configureClient,
      onUpgrade: _createTables,
      singleInstance: true);
}

FutureOr<void> _configureClient(Database db) async {
  await db.execute("""
    PRAGMA foreign_keys = ON;
  """);
}

// Note: Each call to execute must only contain one statement. On android,
// only the first statement will be executed if there are multiple.
// Note: Any changes to this schema must either remove the previous database
// or increment the database version.
FutureOr<void> _createTables(Database db, int prev, int next) async {
  await db.execute("""
    CREATE TABLE IF NOT EXISTS $MAIL_PIECE_TABLE (
      id STRING UNIQUE NOT NULL,
      email_id STRING,
      sender STRING,
      image_text STRING,
      timestamp INTEGER
    );
  """);

  await db.execute("""
    CREATE TABLE IF NOT EXISTS $NOTIFICATION_SUBSCRIPTION_TABLE (
      keyword STRING UNIQUE NOT NULL
    );
  """);

  await db.execute("""
    CREATE TABLE IF NOT EXISTS $NOTIFICATION_TABLE (
      mail_piece_id STRING  NOT NULL REFERENCES $MAIL_PIECE_TABLE(id),
      subscription_keyword STRING  NOT NULL REFERENCES $NOTIFICATION_SUBSCRIPTION_TABLE(keyword) ON DELETE CASCADE
    );
  """);

  if (prev <= 1) {
    try {
      await db.execute("""
        ALTER TABLE $MAIL_PIECE_TABLE ADD COLUMN scanImgCID TEXT;
      """);
    } catch (e) {
      // Do nothing, prevent duplicate column from being added
    }
  }

  if (prev <= 2) {
    try {
      await db.execute("""
        ALTER TABLE $MAIL_PIECE_TABLE ADD COLUMN links TEXT;
      """);
      await db.execute("""
        ALTER TABLE $MAIL_PIECE_TABLE ADD COLUMN emails TEXT;
      """);
      await db.execute("""
        ALTER TABLE $MAIL_PIECE_TABLE ADD COLUMN phone_numbers TEXT;
      """);
      await db.execute("""
        ALTER TABLE $MAIL_PIECE_TABLE ADD COLUMN image_bytes TEXT;
      """);
      await db.execute("""
        ALTER TABLE $MAIL_PIECE_TABLE ADD COLUMN featured_html TEXT;
      """);
    } catch (e) {
      // Do nothing, prevent duplicate column from being added
    }
  }

  if (prev <= 1) {
    try {
      await db.execute("""
      ALTER TABLE $MAIL_PIECE_TABLE ADD COLUMN uspsMID TEXT;
    """);
    }
    catch (e) {
      // Do nothing, prevent duplicate column from being added
    }
  }

  if (prev <= 1) {
    try {
      await db.execute("""
      ALTER TABLE $MAIL_PIECE_TABLE ADD COLUMN links TEXT;
    """);
    }
    catch (e) {
      // Do nothing, prevent duplicate column from being added
    }
  }

  if (prev <= 1) {
    try {
      await db.execute("""
      ALTER TABLE $MAIL_PIECE_TABLE ADD COLUMN emails TEXT;
    """);
    }
    catch (e) {
      // Do nothing, prevent duplicate column from being added
    }
  }

  if (prev <= 1) {
    try {
      await db.execute("""
      ALTER TABLE $MAIL_PIECE_TABLE ADD COLUMN phones TEXT;
    """);
    }
    catch (e) {
      // Do nothing, prevent duplicate column from being added
    }
  }

}

Future<void> setUpTestDatabase() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    /// Initialize sqflite for test.
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  _dbPath = inMemoryDatabasePath;
  await deleteDatabase(inMemoryDatabasePath);
}
