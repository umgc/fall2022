import 'package:flutter_test/flutter_test.dart';
import 'package:summer2022/image_processing/usps_address_verification.dart';
import 'package:summer2022/image_processing/usps_web_api.dart';

void main() async {
  bool result;
  final uspsAddressValidator = UspsAddressVerification();
  final uspsWebApi = UspsWebApi();

  group('USPS Address Verification Tests', () {
    test('Well Formatted Address', () async {
      const strAddress = r'1004 SPA RD, APT 202; ANNAPOLIS, MD 21403';
      result = await uspsAddressValidator.verifyAddressString(strAddress);
      // print(result);
      expect(result, true);
    });
    test('Well Formatted Address, Without second Address', () async {
      const strAddress = r'13123 VANDALIA DR; ROCKVILLE, MD 20853-3348';
      result = await uspsAddressValidator.verifyAddressString(strAddress);
      // print(result);
      expect(result, true);
    });
    test('Well Formatted Address, With full state name', () async {
      const strAddress = r'13123 VANDALIA DR; ROCKVILLE, MARYLAND 20853-3348';
      result = await uspsAddressValidator.verifyAddressString(strAddress);
      // print(result);
      expect(result, true);
    });
    test('Well Formatted Address, With full state name and short zip',
        () async {
      const strAddress = r'13123 VANDALIA DR; ROCKVILLE, MARYLAND 20853';
      result = await uspsAddressValidator.verifyAddressString(strAddress);
      // print(result);
      expect(result, true);
    });
    test('No comma address', () async {
      const strAddress = r'1002 SPA RD APT 201; ANNAPOLIS MD 21403';
      result = await uspsAddressValidator.verifyAddressString(strAddress);
      // print(result);
      expect(result, true);
    });
    test('Second address is on second line', () async {
      const strAddress = r'1002 SPA RD; APT 201; ANNAPOLIS MD 21403';
      result = await uspsAddressValidator.verifyAddressString(strAddress);
      // print(result);
      expect(result, true);
    });
    test('Second address is on first line', () async {
      const strAddress = r'APT 201; 1000 SPA RD; ANNAPOLIS MD 21403';
      result = await uspsAddressValidator.verifyAddressString(strAddress);
      // print(result);
      expect(result, true);
    });
    test('Second address is on first line with comma after city', () async {
      const strAddress = r'APT 201; 1000 SPA RD; ANNAPOLIS, MD 21403';
      result = await uspsAddressValidator.verifyAddressString(strAddress);
      // print(result);
      expect(result, true);
    });
    test('PO Box address', () async {
      const strAddress3 = r'PO Box 85148; Richmond, VA 23295-0001';
      result = await uspsAddressValidator.verifyAddressString(strAddress3);
      // print(result);
      expect(result, true);
    });
    //Removed "Exception: Address format not considered for validation"
    // test('Bad Address', () async {
    //   try {
    //     const strAddress =
    //         r'22 zzzzzzzzzzzzz zzzzzzzz zzzzzzzzzzz zzzzzzzzzzzzzz zzzzzzzzzzz';
    //     result = await uspsAddressValidator.verifyAddressString(strAddress);
    //     // print(result);
    //     expect(result, false);
    //   } catch (e) {
    //     // print(e.toString());
    //     expect(e.toString(),
    //         "Exception: Address format not considered for validation");
    //   }
    // });
  });

  group('USPS Address Validation Function Tests', () {
    test('Get XML Version', () {
      String url = uspsAddressValidator.getXmlVersion();
      // print(url);
      expect(url, '"version="1.0"');
    });
  });

  group('USPS Web Api test', () {
    test('Test Connection', () async {
      bool isConnected = await uspsWebApi.testConnectionToUspsAPI();
      // print(isConnected);
      expect(isConnected, true);
    });
    test('Test Failed Connection', () async {
      TestWidgetsFlutterBinding
          .ensureInitialized(); //for some reason this breaks web connections so we can test for no internet
      bool isConnected = await uspsWebApi.testConnectionToUspsAPI();
      // print(isConnected);
      expect(isConnected, false);
    });
  });
}
