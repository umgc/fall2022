class MailSearchParameters{

  String? keyword;

  String? senderKeyword;

  String? mailBodyKeyword;

  DateTime? startDate;

  DateTime? endDate;

  MailSearchParameters({this.keyword, this.senderKeyword, this.mailBodyKeyword, this.startDate, this.endDate});
}