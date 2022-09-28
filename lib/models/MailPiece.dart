import 'Address.dart';

class MailPiece {
  final int mailId;
  final DateTime informedDate;
  final String logoText;
  final AddressObject senderAddress;

   MailPiece(this.mailId, this.informedDate, this.logoText, this.senderAddress);
}
