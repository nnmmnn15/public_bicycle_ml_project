
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ReservationController extends GetxController{

  final mapController = MapController();
  final serverurl = 'http://127.0.0.1:8000';

  // var curBike = 0.obs;
  var predBike = 0.obs;

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
    String dateString = selectedItem.value;
    String formattedString = dateString.replaceAll('월 ', '').replaceAll('일 ', 'T').replaceAll('시', '');
    String dateTimeString = "2024$formattedString";

    var url = Uri.parse('$serverurl/reserve/ai?stid=$stId&predictTime=$dateTimeString&curBikes=$curBikes');
    // print("http://127.0.0.1:8000/reserve/ai?stid=ST-1199&predictTime=20241205T22&curBikes=20");
    // print('$serverurl/reserve/ai?stid=$stId&predictTime=$dateTimeString&curBikes=$curBikes');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      final minBike = dataConvertedJSON['min_bike'];
      final maxBike = dataConvertedJSON['max_bike'];
      // print('$maxBike, $minBike');
      // return result;
    } else {
      // return [];
    }


  }



  reserve(String stationId)async{
    var url = Uri.parse('$serverurl/reserve/bikeInSt?statn=$stationId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      final result = dataConvertedJSON['results'];
      return result;
    } else {
      return [];
    }
  }
  

}