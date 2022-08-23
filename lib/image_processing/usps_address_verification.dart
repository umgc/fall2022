import './usps_web_api.dart';
import 'package:xml/xml.dart' as xml;

//xml documentation: https://pub.dev/packages/xml

class UspsAddressVerification {
  final String _strXmlVersion = '"version="1.0"';

  UspsAddressVerification() {
    //Nothing to initialize but it makes me feel better having this here
  }

  //getter for strXmlVersion
  String getXmlVersion() {
    return _strXmlVersion;
  }

  //Can't overload in dart so new Name for Json specific functions
  Future<bool> verifyAddressString(String strAddr) async {
    String strAddr1 = "";
    String strCity = "";
    String strState = "";
    String strZip5 = "";
    String strAddr2 = "";
    String strZip4 = "";
    RegExp numericEnd = RegExp(r'[0-9]+$');
    UspsWebApi webApi = UspsWebApi();

    try {
      List<String> list = strAddr.split(';');

      //determine street address information
      if (list.length == 3) {
        //assume that the second line is address 2
        if (numericEnd.hasMatch(list[0])) {
          //line 1 is the second address line
          strAddr2 = list[0].trim();
          strAddr1 = list[1].trim();
        } else if (numericEnd.hasMatch(list[1])) {
          //line 2 has the second address value
          strAddr2 = list[1].trim();
          strAddr1 = list[0].trim();
        }
      } else if (list.length == 2) {
        //assume that line one is address 1 and potentially address 2
        if (numericEnd.hasMatch(list[0])) {
          //use to determine if the address line has a numerical value at the end of the string, this implies that there is a second address
          final addrSplit = list[0].split(' ');
          strAddr2 =
              '${addrSplit[addrSplit.length - 2]} ${addrSplit[addrSplit.length - 1]}'; // address 2 can only be the last two values of the address line.
          strAddr1 = list[0].split(
              strAddr2)[0]; //everything the left of address 2 will be address 1
        } else {
          //there is no address 2
          strAddr1 = list[0];
        }
      } else {
        print('Address format not considered for validation');
        return false;
      }

      //City, State Zip will always be the last line of the list
      if (list.last.contains(',')) {
        //address is well formatted and can assume that left of the comma is the city
        strCity = list.last.trim().split(',')[0];
        strState = _findState(list.last.trim());
        strZip5 = _findZip5(list.last.trim());
        strZip4 = _findZip4(list.last.trim());
      } else {
        //address is not well formatted and need to find the other components before we can assume city
        strState = _findState(list.last.trim());
        strZip5 = _findZip5(list.last.trim());
        strZip4 = _findZip4(list.last.trim());
        strCity = list.last.split(strState)[0].trim();
      }

      xml.XmlDocument doc = _buildAddressXml(
          strAddr1, strAddr2, strCity, strState, strZip5, strZip4);
      return await webApi.verifyAddressXml(doc.outerXml);
    } catch (e) {
      rethrow;
    }
  }

  String _findZip5(String str) {
    try {
      RegExp fiveAndFour = RegExp(r'[0-9]+-[0-9]+$');
      RegExp numericEnd = RegExp(r'[0-9]+$');
      if (fiveAndFour.hasMatch(str)) {
        final strSplit = str.split(' ');
        return strSplit.last.split('-')[0];
      } else if (numericEnd.hasMatch(str)) {
        return str.split(' ').last;
      } else {
        return '';
      }
    } catch (e) {
      rethrow;
    }
  }

  String _findZip4(String str) {
    try {
      RegExp fiveAndFour = RegExp(r'[0-9]+-[0-9]+$');
      if (fiveAndFour.hasMatch(str)) {
        final strSplit = str.split(' ');
        return strSplit.last.split('-')[1];
      }
      return '';
    } catch (e) {
      rethrow;
    }
  }

  String _findState(String str) {
    try {
      RegExp shortState = RegExp(r' [A-Z]{2} ');
      String strState = '';
      if (shortState.hasMatch(str)) {
        str.split(' ').forEach((e) {
          if (e.length == 2) {
            strState = e;
          }
        });
      } else {
        //state value is not two characters so we must find zip as state is always before zip
        final strSplit = str.split(' ');
        for (int x = 0; x < strSplit.length; x++) {
          if (strSplit[x].contains('-') &&
              int.tryParse(strSplit[x].split('-')[0]) != null) {
            strState = strSplit[x - 1];
            break;
          } else if (int.tryParse(strSplit[x]) != null) {
            strState = strSplit[x - 1];
            break;
          }
        }
      }
      return strState;
    } catch (e) {
      rethrow;
    }
  }

  xml.XmlDocument _buildAddressXml(String strAddr1, String strAddr2,
      String strCity, String strState, String strZip5, String strZip4) {
    try {
      final builder = xml.XmlBuilder();
      builder.processing('xml', getXmlVersion());
      builder.element('AddressValidateRequest', nest: () {
        builder.attribute('USERID', UspsWebApi().getUserID());
        builder.element('Revision', nest: 1);
        builder.element('Address', nest: () {
          builder.attribute('ID', 0);
          builder.element('Address1', nest: strAddr1);
          builder.element('Address2', nest: strAddr2);
          builder.element('City', nest: strCity);
          builder.element('State',
              nest:
                  strState); //works with both full state names and abbreviation
          builder.element('Zip5', nest: strZip5);
          builder.element('Zip4', nest: strZip4);
        });
      });
      return builder.buildDocument();
    } catch (e) {
      rethrow;
    }
  }
}
