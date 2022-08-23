import 'package:json_annotation/json_annotation.dart';
part 'Logo.g.dart';

@JsonSerializable()
class LogoObject {
  String name;
  LogoObject({required this.name});

  String get getName {
    return name;
  }

  // static listFromJson(List<Map<String, dynamic>> list) {
  //   List<LogoObject> logos = [];
  //   for (var value in list) {
  //     logos.add(LogoObject.fromJson(value));
  //   }
  //   return logos;
  // }

  // static fromJson(Map<String, dynamic> parsedJson) {
  //   return LogoObject(name: parsedJson["name"]);
  // }
  factory LogoObject.fromJson(Map<String, dynamic> logo) =>
      _$LogoObjectFromJson(logo);
  Map<String, dynamic> toJson() => _$LogoObjectToJson(this);
}
