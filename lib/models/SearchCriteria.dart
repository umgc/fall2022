import 'package:intl/intl.dart';

class SearchCriteria {
  String keyword = "";
  DateTime? startDate;
  DateTime? endDate;

  // Constructor
  SearchCriteria(this.keyword, this.startDate, this.endDate);

  // Constructor to parse params
  SearchCriteria.withList(List<String> params) {
    DateTime? _potentialStart;
    DateTime? _potentialEnd;
    String _potentialKeyword = "";

    if (params.isNotEmpty) {
      for (var param in params) {
        try {
          var potentialDate = DateFormat('MM/d/yyyy').parse(param);

          // Update start/end date if we found a valid date
          if (_potentialStart == null)
            _potentialStart = potentialDate;
          else if (_potentialEnd == null) _potentialEnd = potentialDate;
        } catch (FormatException) {
          // Couldn't parse value. Probably a keyword instead
          // Append to existing keyword search
          _potentialKeyword += _potentialKeyword.length == 0 ? param : " ${param}";
        }
      }
    }

    this.keyword = _potentialKeyword;
    this.startDate = _potentialStart;
    this.endDate = _potentialEnd ?? _potentialStart;

    // Verify end isn't before start
    if (this.startDate != null && this.endDate != null && this.startDate!.compareTo(this.endDate!) > 0) {
      this.endDate = this.startDate;
    }
  }
}