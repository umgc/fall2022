import 'package:json_annotation/json_annotation.dart';
part 'Address.g.dart';

@JsonSerializable()
class AddressObject {
  String type;
  String name;
  String address;
  bool validated;
  AddressObject(
      {this.type = '',
      this.name = '',
      this.address = '',
      this.validated = false});
  bool get getValidated {
    return validated;
  }

  String get getType {
    return type;
  }

  String get getAddress {
    return address;
  }

  String get getName {
    return name;
  }

  //static fromJson(Map<String, dynamic> e) {}
  factory AddressObject.fromJson(Map<String, dynamic> address) =>
      _$AddressObjectFromJson(address);
  Map<String, dynamic> toJson() => _$AddressObjectToJson(this);
}
