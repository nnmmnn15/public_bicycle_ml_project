class Station {
  String id;
  String dong;
  String address;
  double lat;
  double lng;
  String name;

  Station({
    required this.id,
    required this.dong,
    required this.address,
    required this.lat,
    required this.lng,
    required this.name,
  });

   Station.fromMap(Map<String, dynamic> res):
      id = res['id'],
      dong = res['dong'],
      address = res['address'],
      lat = res['lat'],
      lng = res['lng'],
      name = res['name'];
     

}