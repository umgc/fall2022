/// This class represents a subscription for generating notifications when new
/// pieces of mail are received by the USPS.
class NotificationSubscription {
  final String keyword;
  NotificationSubscription(this.keyword);

  bool operator ==(Object other) =>
      other is NotificationSubscription && other.keyword == this.keyword;
}
