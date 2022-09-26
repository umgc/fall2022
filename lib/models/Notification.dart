import 'package:json_annotation/json_annotation.dart';

class NotificationObject {
  String TimeStamp;
  String EmailID;
  String MID;
  String NotificationSubscriptionKeyword;

  NotificationObject(
      {this.TimeStamp = '',
        this.EmailID = '',
        this.MID = '',
        this.NotificationSubscriptionKeyword = ''});
}
