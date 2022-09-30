/// This class represents a specific piece of mail received by the USPS.
/// There will likely be multiple of these items per email received.
class MailPiece {
  final String id; // Unique ID of MailPiece
  final String emailId; // Unique ID of Email - made from Email contents hashed
  final DateTime timestamp;
  final String sender;
  final String imageText;
  final String midId;

  MailPiece(this.id, this.emailId, this.timestamp, this.sender, this.imageText,
      this.midId);

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
}
