import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Keychain {
  Keychain();
  // Create storage
  final _storage = const FlutterSecureStorage();

  Future<void> readAll() async {
    final all = await _storage.readAll(
        iOptions: _getIOSOptions(), aOptions: _getAndroidOptions());
    List<_SecItem> items = all.entries
        .map((entry) => _SecItem(entry.key, entry.value))
        .toList(growable: false);
    for (_SecItem item in items) {
      print(item.key);
      print(item.value);
    }
  }

  getUsername() async {
    final item = await _storage.read(
        key: "username",
        iOptions: _getIOSOptions(),
        aOptions: _getAndroidOptions());
    print(item);
    return item;
  }

  getPassword() async {
    final item = await _storage.read(
        key: "password",
        iOptions: _getIOSOptions(),
        aOptions: _getAndroidOptions());
    print(item);
    return item;
  }

  void deleteAll() async {
    await _storage.deleteAll(
        iOptions: _getIOSOptions(), aOptions: _getAndroidOptions());
  }

  void addCredentials(String username, String password) {
    _addNewItem('username', username);
    _addNewItem('password', password);
  }

  void _addNewItem(String key, String value) async {
    await _storage.write(
        key: key,
        value: value,
        iOptions: _getIOSOptions(),
        aOptions: _getAndroidOptions());
  }

  IOSOptions _getIOSOptions() => const IOSOptions(
      // accountName: _getAccountName(),
      );

  // String? _getAccountName() =>
  //     _accountNameController.text.isEmpty ? null : _accountNameController.text;

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );
}

class _SecItem {
  _SecItem(this.key, this.value);

  final String key;
  final String value;
}
