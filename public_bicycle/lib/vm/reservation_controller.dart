
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';

class ReservationController extends GetxController{

  final mapController = MapController();

  
  final now = DateTime.now();
  var selectedItem = '0'.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    selectedItem.value = now.hour.toString();
  }

  var items = List.generate(24, (index) {
    return index.toString();
  },).obs;
  
  

  void setSelected(String value) {
    selectedItem.value = value;
  }
}