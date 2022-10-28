import 'dart:core';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:summer2022/models/MailPiece.dart';
import 'package:summer2022/models/MailSearchParameters.dart';
import 'package:summer2022/ui/top_app_bar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:summer2022/models/ApplicationFunction.dart';
import 'package:summer2022/models/SearchCriteria.dart';
import 'package:summer2022/services/mailPiece_service.dart';
import 'package:summer2022/ui/assistant_state.dart';
import 'package:summer2022/ui/floating_home_button.dart';
import 'package:summer2022/models/MailPieceViewArguments.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:summer2022/firebase_options.dart';
import 'package:summer2022/utility/locator.dart';
import 'package:summer2022/services/analytics_service.dart';

class SearchWidget extends StatefulWidget {
  final List<String> parameters;

  const SearchWidget({this.parameters = const []});

  @override
  SearchWidgetState createState() => SearchWidgetState();
}

class SearchWidgetState extends AssistantState<SearchWidget> {
  final DateTime _today = DateTime.now();
  final double _preferredButtonHeight = 50.0;
  final Color _buttonColor = Color.fromRGBO(51, 51, 102, 1.0);
  final Color _labelTextColor = Colors.black;
  final Color _buttonTextColor = Colors.white;
  final FontWeight _buttonFontWeight = FontWeight.w600;
  final double _buttonIconSize = 35;
  final double _buttonTextSize = 18.0;
  final FontWeight _commonFontWeight = FontWeight.w500;
  final double _buttonLabelTextSize = 26;
  final DateFormat _dateFormat = DateFormat("M/d/yyyy");
  DateTime? _start;
  DateTime? _end;
  String _advancedText = "Advanced Search";
  bool _isAdvanced = false;
  TextEditingController keywordInput = TextEditingController();
  TextEditingController senderInput = TextEditingController();
  TextEditingController mailBodyInput = TextEditingController();
  final _mailPieceService = MailPieceService();


  // Apply and passed in search parameters to the filters
  void applyFilters() {
    if (this.widget.parameters.isEmpty) return;
    final filters = SearchCriteria.withList(this.widget.parameters);

    // Update local variables
    if (filters.keyword.isNotEmpty) {
      keywordInput.text = filters.keyword;
    }
    _start = filters.startDate ?? _start;
    _end = filters.endDate ?? _end;
  }

  @override
  Future<void> processFunction(ApplicationFunction function) async {
    if (function.methodName == "performSearch") {
      if (function.parameters!.isNotEmpty) {
        final filters = SearchCriteria.withList(function.parameters!);
        keywordInput.text = filters.keyword;
        _start = filters.startDate ?? _start;
        _end = filters.endDate ?? _end;
        MailSearchParameters searchParams = new MailSearchParameters(
            keyword: keywordInput.text, startDate: _start, endDate: _end);
        Navigator.pushNamed(context, '/mail_view', arguments: searchParams);
      }
    } else {
      await super.processFunction(function);
    }
  }

  @override
  Widget build(BuildContext context) {
    locator<AnalyticsService>().logScreens(name: "Mail Search");
    applyFilters();
    int _duration = _start != null && _end != null ? DateTimeRange(start: _start!, end: _end!).duration.inDays + 1 : 0;
    bool showHomeButton = MediaQuery.of(context).viewInsets.bottom == 0;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: Visibility(
        visible: showHomeButton,
        child: FloatingHomeButton(parentWidgetName: context.widget.toString()),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomBar(),
      appBar: TopBar(title: 'Mail Search'),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 35.0),
          child: Column(children: [
            SfDateRangePicker(
              selectionMode: DateRangePickerSelectionMode.range,
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                final DateTime rangeStartDate;
                final DateTime rangeEndDate;
                final dynamic value = args.value;
                if (args.value is PickerDateRange) {
                  rangeStartDate = value.startDate;
                  rangeEndDate =
                      value.endDate == null ? value.startDate : value.endDate;
                } else {
                  rangeStartDate = _today;
                  rangeEndDate = _today;
                }
                setState(() {
                  _start = rangeStartDate;
                  _end = rangeEndDate;
                });
              },
              showNavigationArrow: true,
              maxDate: _today,
              rangeSelectionColor: Color.fromRGBO(51, 51, 102, 100.0),
              startRangeSelectionColor: Color.fromRGBO(51, 51, 102, 1.0),
              endRangeSelectionColor: Color.fromRGBO(51, 51, 102, 1.0),
              todayHighlightColor: Color.fromRGBO(231, 25, 33, 1.0),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 5.0),
                  child: Semantics(
                    label: "Start Date",
                    onTap: () {
                      //TODO: add function that types in date and displays it in the calendar view
                    },
                    child: MergeSemantics(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Start Date:",
                              semanticsLabel: "",
                              style: TextStyle(
                                  fontSize: _buttonLabelTextSize,
                                  fontWeight: _commonFontWeight,
                                  color: Color.fromRGBO(51, 51, 102, 100)),
                            ),
                            SizedBox(
                              height: 50.0,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromRGBO(51, 51, 102, 1.0),
                                ),
                                icon: Icon(Icons.calendar_month_outlined,
                                    size: _buttonIconSize, color: Colors.white),
                                label: Text(_getDateDisplay(_start),
                                    semanticsLabel:
                                        " ${_getDateDisplay(_start)}",
                                    style: TextStyle(
                                        fontWeight: _buttonFontWeight,
                                        fontSize: _buttonTextSize,
                                        color: _buttonTextColor)),
                                onPressed: () {
                                  //TODO: add function that types in date and displays it in the calendar view
                                },
                              ),
                            ),
                          ]),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: Semantics(
                    label: "End Date",
                    onTap: () {
                      //TODO: add function that types in date and displays it in the calendar view
                    },
                    child: MergeSemantics(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "End Date:",
                              semanticsLabel: "",
                              style: TextStyle(
                                  fontWeight: _commonFontWeight,
                                  fontSize: _buttonLabelTextSize,
                                  color: Color.fromRGBO(51, 51, 102, 100)),
                            ),
                            SizedBox(
                              height: _preferredButtonHeight,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _buttonColor,
                                ),
                                icon: Icon(Icons.calendar_month_outlined,
                                    size: 35, color: Colors.white),
                                label: Text(_getDateDisplay(_end),
                                    semanticsLabel: " ${_getDateDisplay(_end)}",
                                    style: TextStyle(
                                        fontWeight: _buttonFontWeight,
                                        fontSize: _buttonTextSize,
                                        color: _buttonTextColor)),
                                onPressed: () {
                                  //TODO: add function that types in date and displays it in the calendar view
                                },
                              ),
                            ),
                          ]),
                    ),
                  ),
                ),
              ),
            ]),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                _duration > 0 ? 'Duration: $_duration day(s)' : 'Date range has not been selected',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 20,
                  color: _labelTextColor,
                ),
              ),
            ),
            Visibility(
                visible: !_isAdvanced,
                child: Container(
                  child: Semantics(
                      excludeSemantics: true,
                      textField: true,
                      label: "Keyword",
                      hint: "Enter keyword to search",
                      child: Padding(
                          padding: EdgeInsets.all(10),
                          child: TypeAheadField(
                            direction: AxisDirection.up,
                            textFieldConfiguration: TextFieldConfiguration(
                                style: TextStyle(fontSize: 20),
                                decoration: InputDecoration(
                                    labelText: 'Enter keyword to search',
                                    border: OutlineInputBorder()),
                                controller: keywordInput),
                            onSuggestionSelected: (suggestion) {
                              // Go directly to mail item if the user clicks a suggestion
                              Navigator.pushNamed(context, '/mail_piece_view',
                                  arguments: new MailPieceViewArguments(suggestion as MailPiece));
                              FirebaseAnalytics.instance.logEvent(name: 'Mail_Search',parameters:{'keyword':keywordInput, 'itemId':suggestion.uspsMID});
                              },

                            suggestionsCallback: (pattern) {
                              // Populate items from cache
                              MailSearchParameters searchParams =
                                  new MailSearchParameters(keyword: pattern);
                              return _mailPieceService
                                  .searchMailPieces(searchParams);
                            },
                            itemBuilder: (context, itemData) {
                              return ListTile(
                                title: Text(
                                    "From: ${(itemData as MailPiece).sender}, "
                                    "Date: ${DateFormat('MM/dd/yyyy').format(itemData.timestamp)}"),
                                subtitle: Text(
                                  "Contents: "
                                  "${itemData.imageText}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            },
                          ))),
                )),
            Visibility(
                visible: _isAdvanced,
                child: Container(
                  child: Semantics(
                      excludeSemantics: true,
                      textField: true,
                      label: "Sender Keyword",
                      hint: "Enter sender to search",
                      child: Padding(
                          padding: EdgeInsets.all(10),
                          child: TypeAheadField(
                            direction: AxisDirection.up,
                            textFieldConfiguration: TextFieldConfiguration(
                                style: TextStyle(fontSize: 20),
                                decoration: InputDecoration(
                                    labelText: 'Enter mail sender to search',
                                    border: OutlineInputBorder()),
                                controller: senderInput),
                            onSuggestionSelected: (suggestion) {
                              // Go directly to mail item if the user clicks a suggestion
                              Navigator.pushNamed(context, '/mail_piece_view',
                                  arguments: new MailPieceViewArguments(suggestion as MailPiece));
                            },
                            suggestionsCallback: (pattern) {
                              // Populate items from cache
                              MailSearchParameters searchParams =
                                  new MailSearchParameters(
                                      senderKeyword: pattern);
                              return _mailPieceService
                                  .searchMailPieces(searchParams);
                            },
                            itemBuilder: (context, itemData) {
                              return ListTile(
                                title: Text(
                                    "From: ${(itemData as MailPiece).sender}, "
                                    "Date: ${DateFormat('MM/dd/yyyy').format(itemData.timestamp)}"),
                                subtitle: Text(
                                  "Contents: "
                                  "${itemData.imageText}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            },
                          ))),
                )),
            Visibility(
                visible: _isAdvanced,
                child: Container(
                  child: Semantics(
                      excludeSemantics: true,
                      textField: true,
                      label: "In-Text Keyword",
                      hint: "Enter text to search",
                      child: Padding(
                          padding: EdgeInsets.all(10),
                          child: TypeAheadField(
                            direction: AxisDirection.up,
                            textFieldConfiguration: TextFieldConfiguration(
                                style: TextStyle(fontSize: 20),
                                decoration: InputDecoration(
                                    labelText: 'Enter mail body text to search',
                                    border: OutlineInputBorder()),
                                controller: mailBodyInput),
                            onSuggestionSelected: (suggestion) {
                              // Go directly to mail item if the user clicks a suggestion
                              Navigator.pushNamed(context, '/mail_piece_view',
                                  arguments: new MailPieceViewArguments(suggestion as MailPiece));
                            },
                            suggestionsCallback: (pattern) {
                              // Populate items from cache
                              MailSearchParameters searchParams =
                                  new MailSearchParameters(
                                      mailBodyKeyword: pattern);
                              return _mailPieceService
                                  .searchMailPieces(searchParams);
                            },
                            itemBuilder: (context, itemData) {
                              return ListTile(
                                title: Text(
                                    "From: ${(itemData as MailPiece).sender}, "
                                    "Date: ${DateFormat('MM/dd/yyyy').format(itemData.timestamp)}"),
                                subtitle: Text(
                                  "Contents: "
                                  "${itemData.imageText}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            },
                          ))),
                )),
            new InkWell(
                child: Align(
                  alignment: Alignment.centerRight,
                    child: Semantics(
                      explicitChildNodes: true,
                      label: "${_advancedText}",
                      child:new Text(
                    _advancedText,
                    style: TextStyle(
                        fontWeight: _commonFontWeight,
                        decoration: TextDecoration.underline),
                      ),
                  ),
                ),
                onTap: () {
                  setState(() {
                    _isAdvanced = !_isAdvanced;
                    _advancedText =
                        _isAdvanced ? "Standard Search" : "Advanced Search";
                  });
                }),
            Row(children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: SizedBox(
                    height: _preferredButtonHeight,
                    child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(51, 51, 102, 1.0),
                        ),
                        onPressed: () {
                          MailSearchParameters searchParams = _isAdvanced
                              ? new MailSearchParameters(
                                  senderKeyword: senderInput.text,
                                  mailBodyKeyword: mailBodyInput.text,
                                  startDate: _start,
                                  endDate: _end)
                              : new MailSearchParameters(
                                  keyword: keywordInput.text,
                                  startDate: _start,
                                  endDate: _end);
                          Navigator.pushNamed(context, '/mail_view',
                              arguments: searchParams);
                          if(_isAdvanced)
                            FirebaseAnalytics.instance.logEvent(name: 'Mail_Search',parameters:{'senderKeyword':keywordInput.text,'mailBodyKeyword':mailBodyInput.text});
                          else
                            FirebaseAnalytics.instance.logEvent(name: 'Mail_Search',parameters:{'senderKeyword':keywordInput.text});
                        },
                        icon: const Icon(Icons.search,
                            size: 35, color: Colors.white),
                        label: Text("Search",
                            style: TextStyle(
                                fontWeight: _buttonFontWeight,
                                fontSize: _buttonTextSize + 4.0,
                                color: _buttonTextColor))),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  String _getDateDisplay(DateTime? date) {
    return date != null ? _dateFormat.format(date) : "None";
  }
}
