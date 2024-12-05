class Rent {
  int id;
  String bicId;
  String userId;
  String startTime;
  String time;
  int resume;

  Rent({
    required this.id,
    required this.bicId,
    required this.userId,
    required this.startTime,
    required this.time,
    required this.resume,
  });

  // Rent.fromMap(Map<String, dynamic> res):
  //   id = res['id'] ?? 0,  // null일 경우 기본값 0 설정
  //   bicId = res['bic_id'] ?? '',  // null일 경우 빈 문자열
  //   userId = res['user_id'] ?? '',
  //   startTime = res['start_time'] ?? '',
  //   time = res['time'] ?? '',
  //   resume = res['resume'] ?? 0;

    Rent.fromMap(Map<String, dynamic> res):
      id = res['id'],
      bicId = res['bic_id'],
      userId = res['user_id'],
      startTime = res['start_time'],
      time = res['time'],
      resume = res['resume'];
}