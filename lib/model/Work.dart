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
  final String dispatcherID;
  List<String> _statuses; // Encapsulated statuses field

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
    required this.dispatcherID,
    required List<String> statuses, // Modified to accept List<String> statuses
  }) : _statuses = statuses; // Initialize the encapsulated statuses field

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
      dispatcherID: map['dispatcherID'],
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
      'dispatcherID': dispatcherID,
      'statuses': _statuses, // Use the encapsulated statuses field
    };
  }

  // Method to add a new status
  void addStatus(String newStatus) {
    _statuses.add(newStatus);
  }

  // Method to update the status at a specific index
  void updateStatus(String newStatus, int index) {
    if (index >= 0 && index < _statuses.length) {
      _statuses[index] = newStatus;
    }
  }

  // Getter to access the statuses list
  List<String> get statuses => _statuses;
}
