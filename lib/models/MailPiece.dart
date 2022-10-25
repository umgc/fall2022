/// This class represents a specific piece of mail received by the USPS.
/// There will likely be multiple of these items per email received.
class MailPiece {
  final String id; // Unique ID of MailPiece
  final String emailId; // Unique ID of Email - made from Email contents hashed
  final DateTime timestamp;
  final String sender;
  final String imageText;
  final String midId;
  List<String>? links; // Links from QR code, barcodes etc..
  List<String>? emailList;
  List<String>? phoneNumbersList;


  MailPiece(this.id, this.emailId, this.timestamp, this.sender, this.imageText,
      this.midId, [this.links, this.emailList, this.phoneNumbersList]);


  factory MailPiece.fromJson(dynamic json) {
    return MailPiece(
        json['id'] as String,
        json['emailId'] as String,
        json['timestamp'] as DateTime,
        json['sender'] as String,
        json['imageText'] as String,
        json['midId'] as String

    );
  }

  bool operator ==(Object other) =>
      other is MailPiece &&
      other.id == this.id &&
      other.emailId == this.emailId &&
      other.timestamp.millisecondsSinceEpoch ==
          this.timestamp.millisecondsSinceEpoch &&
      other.sender == this.sender &&
      other.imageText == this.imageText &&
      other.midId == this.midId&&
          other.links == this.links &&
          other.emailList == this.emailList &&
          other.phoneNumbersList == this.phoneNumbersList;

}
