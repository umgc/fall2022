/// This class represents a notification for a specific piece of mail recieved
/// by the USPS. The associated mail piece will have matches the associated
/// subscription keyword.
class Notification {
  final String mailPieceId;
  final String subscriptionKeyword;
  Notification(this.mailPieceId, this.subscriptionKeyword);

  bool operator ==(Object other) =>
      other is Notification &&
      other.mailPieceId == this.mailPieceId &&
      other.subscriptionKeyword == this.subscriptionKeyword;
}
