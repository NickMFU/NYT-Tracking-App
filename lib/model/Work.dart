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
  final String responsiblePerson;
  final String imageUrl;
  List<String> statuses;

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
    required this.imageUrl,
    required this.statuses,
  });

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
      imageUrl: map['imageUrl'],
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
      'imageUrl': imageUrl,
      'statuses': statuses,
    };
  }

  // Method to add a new status
  void addStatus(String newStatus) {
    statuses.add(newStatus);
  }

  // Method to update the status
  void updateStatus(String newStatus, int index) {
    statuses[index] = newStatus;
  }
}
