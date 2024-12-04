class SuspendStation {
  double lat;
  double lng;
  String name;
  double distance;

  SuspendStation(
      {required this.lat,
      required this.lng,
      required this.name,
      required this.distance});

  SuspendStation.fromMap(Map<String, dynamic> res)
      : name = res['name'],
        lat = res['lat'],
        lng = res['lng'],
        distance = res['distance'];
}
