/// This class represents a notification for a specific piece of mail recieved
/// by the USPS. The associated mail piece will have matches the associated
/// subscription keyword.
class Notification {
  final DateTime timestamp;
  final String emailId;
  final String mailPieceId;
  final String subscriptionKeyword;
  Notification(
      this.timestamp, this.emailId, this.mailPieceId, this.subscriptionKeyword);
}
