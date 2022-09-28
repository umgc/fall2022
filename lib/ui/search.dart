import 'dart:core';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';

class SearchWidget extends StatefulWidget {
  @override
  SearchWidgetState createState() => SearchWidgetState();

}

class SearchWidgetState extends State<SearchWidget> {
  final DateTime _today = DateTime.now();
  final double _preferredButtonHeight = 50.0;
  final Color _buttonColor = Color.fromRGBO(51, 51, 102, 1.0);
  final Color _labelTextColor = Colors.black;
  final Color _buttonTextColor = Colors.white;
  final FontWeight _buttonFontWeight = FontWeight.w600;
  final double _buttonIconSize = 35;
  final double _buttonTextSize = 20.0;
  final FontWeight _commonFontWeight = FontWeight.w500;
  final double _commonFontSize = 30;
  final double _buttonLabelTextSize = 26;
  final DateFormat _dateFormat = DateFormat("M/d/yyyy");
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now();

  @override
  Widget build(BuildContext context) {
    int _duration = DateTimeRange(start: _start, end: _end).duration.inDays + 1;

    return Scaffold(
      bottomNavigationBar: const BottomBar(),
      appBar: AppBar(
        title: Text('Mail Search',  style:
        TextStyle(fontWeight: _commonFontWeight, fontSize: _commonFontSize),
        ),
        backgroundColor: _buttonColor,
        centerTitle: true,
      ),
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
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children:[
                                Text(
                                  "Start Date:",
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
                                        style: TextStyle(
                                            fontWeight: _buttonFontWeight,
                                            fontSize: _buttonTextSize,
                                            color: _buttonTextColor
                                        )
                                    ), onPressed: () {},
                                  ),
                                ),
                              ]
                          ),
                        ),
                      ),
                      Expanded(
                        child:
                        Padding(padding: EdgeInsets.only(left:5.0),
                          child:
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children:[
                                Text(
                                  "End Date:",
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
                                    label: Text('${_dateFormat.format(_end)}',
                                        style: TextStyle(
                                            fontWeight: _buttonFontWeight,
                                            fontSize: _buttonTextSize,
                                            color: _buttonTextColor
                                        )
                                    ),
                                    onPressed: (){},
                                  ),
                                ),
                              ]
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
                  child:
                  TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2, color: _buttonColor)),
                        hintText: 'Enter a keyword to search'
                    ),
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
                                  Navigator.pushNamed(context, '/mail_view');
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