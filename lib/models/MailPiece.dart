/// This class represents a specific piece of mail received by the USPS.
/// There will likely be multiple of these items per email received.
class MailPiece {
  final String id; // Unique ID of MailPiece
  final String emailId; // Unique ID of Email - made from Email contents hashed
  final DateTime timestamp;
  final String sender;
  final String imageText;
  final String? imageBytes;
  final String? featuredHtml;
  final String scanImgCID;
  final String uspsMID;
  List<String>? links; // Links from QR code, barcodes etc..
  List<String>? emailList;
  List<String>? phoneNumbersList;

  MailPiece(this.id, this.emailId, this.timestamp, this.sender, this.imageText,
      this.scanImgCID, this.uspsMID, this.links, this.emailList, this.phoneNumbersList, {this.imageBytes = null, this.featuredHtml = null});

  bool operator ==(Object other) =>
      other is MailPiece &&
      other.id == this.id &&
      other.emailId == this.emailId &&
      other.timestamp.millisecondsSinceEpoch ==
          this.timestamp.millisecondsSinceEpoch &&
      other.sender == this.sender &&
      other.imageText == this.imageText &&
      other.scanImgCID == this.scanImgCID &&
      other.uspsMID == this.uspsMID &&
      other.links == this.links &&
      other.emailList == this.emailList &&
      other.phoneNumbersList == this.phoneNumbersList;
}
