import 'package:flutter/material.dart';
import 'package:http/retry.dart';
import 'package:http/http.dart' as http;

//http documentation: https://pub.dev/packages/http
//usps documentation: https://www.usps.com/business/web-tools-apis/address-information-api.pdf

class UspsWebApi {
  final String _strUrl = "https://secure.shippingapis.com/";
  final String _strUserID = "974UNIVE7445";

  UspsWebApi() {
    //nothing to initialize
  }

  String getUrl() {
    return _strUrl;
  }

  String getUserID() {
    return _strUserID;
  }

  Future<bool> verifyAddressXml(String xml) async {
    //according to documentation, append xml to the end of the url
    String strUri = '${getUrl()}ShippingAPI.dll?API=Verify&XML=$xml';

    String strResponse = await _callClient(strUri);

    if (strResponse.contains('<DPVConfirmation>')) {
      final responseSplit = strResponse.split('<DPVConfirmation>');
      return responseSplit[1].characters.elementAt(0) == 'Y';
    }
    return false;
  }

  Future<bool> testConnectionToUspsAPI() async {
    try {
      //Construct test address
      String strUri =
          '${getUrl()}ShippingAPITest.dll?API=ZipCodeLookup&XML=<ZipCodeLookupRequest USERID="${getUserID()}"><Address ID="0"><Address1></Address1><Address2>6406 Ivy Lane</Address2><City>Greenbelt</City><State>MD</State></Address></ZipCodeLookupRequest>';

      //regardless of response if its blank then there is no connection
      if ((await _callClient(strUri)).toLowerCase().contains('error')) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> _callClient(String strUri) async {
    try {
      //create web client
      final client = RetryClient(http.Client());
      //download response string from api
      return await client.read(Uri.parse(strUri));
    } catch (e) {
      rethrow;
    }
  }
}
