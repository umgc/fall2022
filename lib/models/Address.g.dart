// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressObject _$AddressObjectFromJson(Map<String, dynamic> json) =>
    AddressObject(
      type: json['type'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      validated: json['validated'] as bool? ?? false,
    );

Map<String, dynamic> _$AddressObjectToJson(AddressObject instance) =>
    <String, dynamic>{
      'type': instance.type,
      'name': instance.name,
      'address': instance.address,
      'validated': instance.validated,
    };
