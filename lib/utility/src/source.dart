///  LinkWell is Text Plugin that detects URLs and Emails in a String and when tapped opens in user browsers,

/// I invite you to clone, start and make contributions to this project, Thanks.

/// Copyright 2020. All rights reserved.
/// Use of this source code is governed by a BSD-style license that can be
/// found in the LICENSE file.
/// https://github.com/samuelezedi/linkwell
/// Last set of changes to project were over 2 years ago
///
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Helper {
  const Helper(this.value);

  static var regex = new RegExp(
      r"((https?:www\.)|(https?:\/\/)|(www\.))?[\w/\-?=%.][-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z]{1,6}(\/[-a-zA-Z()@:%_\+.~#?&\/=]*)?");

  static var phoneRegex = new RegExp(r"((\(?\d{3}\)?)([ .-])(\d{3})([ .-])(\d{4}))");

  static var defaultTextStyle = TextStyle(
    fontSize: 17,
    color: Colors.black,
  );

  static var linkDefaultTextStyle = TextStyle(fontSize: 17, color: Colors.blue);

  final int value;
}
