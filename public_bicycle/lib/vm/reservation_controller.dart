
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:public_bicycle/vm/myapi.dart';

class ReservationController extends Myapi{

  final mapController = MapController();
  final serverurl = 'http://127.0.0.1:8000';

  var isfetching = false.obs;

  // var curBike = 0.obs;
  var maxBike = 0.obs;
  var minBike = 0.obs;


  final nowvalue =  DateFormat('MM월 dd일 HH시').format(DateTime.now());



  // final now = DateTime.now();
  var selectedItem = (DateFormat('MM월 dd일 HH시').format(DateTime.now())).obs;

  @override
  void onInit() {
    super.onInit();
    selectedItem.value = nowvalue;
  }

  var dropdownItems = List.generate(6, (index) {
    DateTime now = DateTime.now().add(Duration(hours: index));
    return DateFormat('MM월 dd일 HH시').format(now);
  }).obs;
  
  

  setSelected(String value) {
    selectedItem.value = value;
  }

  // fetchCurBike()async{}

  fetchpredBike(stId, curBikes)async{
    isfetching.value = true;
    String dateString = selectedItem.value;
    String formattedString = dateString.replaceAll('월 ', '').replaceAll('일 ', 'T').replaceAll('시', '');
    String dateTimeString = "2024$formattedString";

    var url = Uri.parse('$serverurl/reserve/ai?stid=$stId&predictTime=$dateTimeString&curBikes=$curBikes');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      minBike.value = dataConvertedJSON['min_bike'];
      maxBike.value = dataConvertedJSON['max_bike'];
      isfetching.value = false;
      // print('${maxBike.value}, ${minBike.value}');
      // return result;
    } else {
      // return [];
    }


  }



  reserve(String stationId)async{
    String dateString = selectedItem.value;
    String formattedString = dateString.replaceAll('월 ', '').replaceAll('일 ', 'T').replaceAll('시', '');
    String dateTimeString = "2024$formattedString";
    String url = '$serverurl/reserve/bikeInSt?statn=$stationId&reservation_time=$dateTimeString';
    final response = await makeAuthenticatedRequest(url);
    if (response.statusCode == 200) {
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      final result = dataConvertedJSON['results'];
      return result;
    } else {
      return [];
    }
  }
  

}