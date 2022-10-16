// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'MailResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MailResponse _$MailResponseFromJson(Map<String, dynamic> json) => MailResponse(
      addresses: (json['addresses'] as List<dynamic>)
          .map((e) => AddressObject.fromJson(e as Map<String, dynamic>))
          .toList(),
      logos: (json['logos'] as List<dynamic>)
          .map((e) => LogoObject.fromJson(e as Map<String, dynamic>))
          .toList(),
      textAnnotations: (json['textAnnotations'] as List<dynamic>)
          .map((e) => TextAnnotation.fromJson(e as Map<String, dynamic>))
          .toList(),
    )..codes = (json['codes'] as List<dynamic>)
        .map((e) => CodeObject.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$MailResponseToJson(MailResponse instance) =>
    <String, dynamic>{
      'addresses': instance.addresses.map((e) => e.toJson()).toList(),
      'logos': instance.logos.map((e) => e.toJson()).toList(),
      'codes': instance.codes.map((e) => e.toJson()).toList(),
      'textAnnotations':
          instance.textAnnotations.map((e) => e.toJson()).toList(),
    };
