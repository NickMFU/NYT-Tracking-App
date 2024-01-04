class Work {
  final String workID;
  final String date;
  final String consignee;
  final String vessel;
  final String voy;
  final String blNo;
  final String shipping;
  final Duration? estimatedCompletionTime;
  final String employeeId;
  final List<String> statuses;
  final String responsiblePerson;
  final String imageUrl; // Add imageUrl field

  Work({
    required this.workID,
    required this.date,
    required this.consignee,
    required this.vessel,
    required this.voy,
    required this.blNo,
    required this.shipping,
    required this.estimatedCompletionTime,
    required this.employeeId,
    required this.responsiblePerson,
    required this.imageUrl, // Add imageUrl field
    List<String>? statuses,
  }) : statuses = statuses ?? [];

  factory Work.fromMap(Map<String, dynamic> map) {
    return Work(
      workID: map['workID'],
      date: map['date'],
      consignee: map['consignee'],
      vessel: map['vessel'],
      voy: map['voy'],
      blNo: map['blNo'],
      shipping: map['shipping'],
      estimatedCompletionTime: map['estimatedCompletionTime'] != null
          ? Duration(milliseconds: map['estimatedCompletionTime'])
          : null,
      employeeId: map['employeeId'],
      responsiblePerson: map['responsiblePerson'],
      imageUrl: map['imageUrl'], // Add imageUrl field
      statuses: List<String>.from(map['statuses'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workID': workID,
      'date': date,
      'consignee': consignee,
      'vessel': vessel,
      'voy': voy,
      'blNo': blNo,
      'shipping': shipping,
      'estimatedCompletionTime': estimatedCompletionTime?.inMilliseconds,
      'employeeId': employeeId,
      'responsiblePerson': responsiblePerson,
      'imageUrl': imageUrl, // Add imageUrl field
      'statuses': statuses,
    };
  }

  void addStatus(String newStatus) {
    statuses.add(newStatus);
  }
}
