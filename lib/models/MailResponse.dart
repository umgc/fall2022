import 'package:json_annotation/json_annotation.dart';
import './Address.dart';
import './Logo.dart';
import './Code.dart';
part 'MailResponse.g.dart';

@JsonSerializable(explicitToJson: true)
class MailResponse {
  List<AddressObject> addresses = [];
  List<LogoObject> logos = [];
  List<CodeObject> codes = [];

  //MailResponse({required addresses, required logos, required codes});
  MailResponse({required this.addresses, required this.logos});

  // static fromJson(Map<String, dynamic> parsedJson) {
  //   return MailResponse(
  //       addresses: parsedJson['addresses'],
  //       logos: LogoObject.fromJson(parsedJson['logos']));
  //   //codes: codeObject.listFromJson(parsedJson['codes']));
  // }
  factory MailResponse.fromJson(Map<String, dynamic> mail) =>
      _$MailResponseFromJson(mail);
  Map<String, dynamic> toJson() => _$MailResponseToJson(this);
}