import 'dart:core';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:summer2022/models/MailPiece.dart';
import 'package:summer2022/models/MailSearchParameters.dart';
import 'package:summer2022/ui/top_app_bar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../models/ApplicationFunction.dart';
import '../models/SearchCriteria.dart';
import '../services/mail_service.dart';
import 'assistant_state.dart';
import '../services/mail_storage.dart';
import 'package:summer2022/ui/floating_home_button.dart';

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
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now();
  String _keyword = "";
  TextEditingController keywordInput = TextEditingController();

  final _mailStorage = MailStorage();

  // Apply and passed in search parameters to the filters
  void applyFilters() {
    if (this.widget.parameters.isEmpty) return;
    final filters = SearchCriteria.withList(this.widget.parameters);

    // Update local variables
    _start = filters.startDate ?? _start;
    _end = filters.endDate ?? _end;
    _keyword = filters.keyword;
  }

  @override
  void processFunction(ApplicationFunction function)
  {
      if (function.methodName == "performSearch") {
        if (function.parameters!.isNotEmpty)
          {
            final filters = SearchCriteria.withList(function.parameters!);
            keywordInput.text = filters.keyword;
            _start = filters.startDate ?? _start;
            _end = filters.endDate ?? _end;
          }
      }
      else {
        super.processFunction(function);
      }
  }

  @override
  Widget build(BuildContext context) {
    applyFilters();
    int _duration = DateTimeRange(start: _start, end: _end).duration.inDays + 1;
    keywordInput.text = _keyword;
    bool showHomeButton = MediaQuery.of(context).viewInsets.bottom == 0;
    return Scaffold(
        floatingActionButton: Visibility(
          visible: showHomeButton,
          child: FloatingHomeButton(parentWidgetName: context.widget.toString()),
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomBar(),
      appBar: TopBar(title: 'Mail Search'),
      body:
      SingleChildScrollView(
        child:
        Container(
          padding: EdgeInsets.all(15.0),
          child: Column(
              children: [
                SfDateRangePicker(
                  selectionMode: DateRangePickerSelectionMode.range,
                  onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                    final DateTime rangeStartDate;
                    final DateTime rangeEndDate;
                    final dynamic value = args.value;
                    if (args.value is PickerDateRange) {
                      rangeStartDate = value.startDate;
                      rangeEndDate = value.endDate == null ? value.startDate : value.endDate;
                    }
                    else {
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
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child:
                        Padding(padding: EdgeInsets.only(right:5.0),
                          child:
                          Semantics(
                            label: "Start Date",
                            onTap: (){
                              //TODO: add function that types in date and displays it in the calendar view
                            },
                            child:
                            MergeSemantics(
                              child:
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children:[
                                    Text(
                                      "Start Date:",
                                      semanticsLabel: "",
                                      style: TextStyle(
                                          fontSize: _buttonLabelTextSize,
                                          fontWeight: _commonFontWeight,
                                          color: Color.fromRGBO(51, 51, 102, 100)
                                      ),
                                    ),
                                    SizedBox(
                                      height: 50.0,
                                      child:
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromRGBO(51, 51, 102, 1.0),
                                        ),
                                        icon: Icon(Icons.calendar_month_outlined,
                                            size: _buttonIconSize,
                                            color: Colors.white
                                        ),
                                        label: Text('${_dateFormat.format(_start)}',
                                            semanticsLabel: " ${DateFormat('MMM,d,yyyy').format(_start)}",
                                            style: TextStyle(
                                                fontWeight: _buttonFontWeight,
                                                fontSize: _buttonTextSize,
                                                color: _buttonTextColor
                                            )
                                        ),
                                        onPressed: () {
                                          //TODO: add function that types in date and displays it in the calendar view
                                        },
                                      ),
                                    ),
                                  ]
                              ),
                            ),
                         ),
                        ),
                      ),
                      Expanded(
                        child:
                        Padding(padding: EdgeInsets.only(left:5.0),
                          child:
                          Semantics(
                            label: "End Date",
                            onTap: (){
                              //TODO: add function that types in date and displays it in the calendar view
                            },
                            child:
                            MergeSemantics(
                              child:
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children:[
                                    Text(
                                      "End Date:",
                                      semanticsLabel: "",
                                      style: TextStyle(
                                          fontWeight: _commonFontWeight,
                                          fontSize: _buttonLabelTextSize,
                                          color: Color.fromRGBO(51, 51, 102, 100)
                                      ),
                                    ),
                                    SizedBox(
                                      height: _preferredButtonHeight,
                                      child:
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _buttonColor,
                                        ),
                                        icon: Icon(Icons.calendar_month_outlined,
                                            size: 35,
                                            color: Colors.white
                                        ),
                                        label: Text(
                                            '${_dateFormat.format(_end)}',
                                            semanticsLabel: "${DateFormat('MMM,d,yyyy').format(_end)}",
                                            style: TextStyle(
                                                fontWeight: _buttonFontWeight,
                                                fontSize: _buttonTextSize,
                                                color: _buttonTextColor
                                            )
                                        ),
                                        onPressed: (){
                                          //TODO: add function that types in date and displays it in the calendar view
                                        },
                                      ),
                                    ),
                                  ]
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child:
                  Text(
                    'Duration: $_duration day(s)',
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 20,
                      color: _labelTextColor,
                    ),
                  ),
                ),
                Container(
                    child: Semantics(
                      excludeSemantics: true,
                      textField: true,
                      label: "Keyword",
                      hint: "Enter keyword to search",
                      child: TypeAheadField(
                        textFieldConfiguration: TextFieldConfiguration(
                            style: TextStyle(fontSize: 20),
                            decoration: InputDecoration(
                                labelText: 'Enter keyword to search',
                                border: OutlineInputBorder()
                            ),
                          controller: keywordInput
                        ),
                        onSuggestionSelected: (suggestion) {
                          // Go directly to mail item if the user clicks a suggestion
                          Navigator.pushNamed(context, '/mail_piece_view', arguments: suggestion);
                        },
                        suggestionsCallback: (pattern) {
                          // Populate items from cache
                          return _mailStorage.searchMailsPieces(pattern);
                        },
                        itemBuilder: (context, itemData) {
                          return ListTile(
                            title:  Text("From: ${(itemData as MailPiece).sender}, "
                                "Date: ${DateFormat('MM/dd/yyyy').format(itemData.timestamp)}"),
                            subtitle: Text("Contents: "
                                "${itemData.imageText}"),
                          );
                        },
                      )
                  ),
                ),
                Row(
                    children: [
                      Expanded(
                        child:
                        Padding( padding: EdgeInsets.symmetric(vertical: 50.0),
                          child:
                          SizedBox(
                            height: _preferredButtonHeight,
                            child:
                            OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Color.fromRGBO(51, 51, 102, 1.0),
                                ),
                                onPressed: () {
                                  MailSearchParameters searchParams = new MailSearchParameters(keywordInput.text, _start, _end);
                                  Navigator.pushNamed(context, '/mail_view', arguments: searchParams);
                                },
                                icon: const Icon(
                                    Icons.search,
                                    size: 35,
                                    color: Colors.white
                                ),
                                label: Text("Search",
                                    style: TextStyle(
                                        fontWeight: _buttonFontWeight,
                                        fontSize: _buttonTextSize + 4.0,
                                        color: _buttonTextColor
                                    )
                                )
                            ),
                          ),
                        ),
                      ),
                    ]
                ),
              ]
          ),
        ),
      ),
    );
  }
}