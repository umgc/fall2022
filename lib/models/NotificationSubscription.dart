import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class NotificationSubscription {
  String Keyword;

  NotificationSubscription({this.Keyword = ''});

}