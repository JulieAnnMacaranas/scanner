class Subject {
  final String subjectId;
  final String subjectName;
  final String subjectCode;
  final String subjectYear;
  final String subjectSection;

  Subject({required this.subjectId, required this.subjectCode,  required this.subjectName, required this.subjectSection, required this.subjectYear});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      subjectId: json['subject_id'].toString(), 
      subjectCode: json['subject_code'],
      subjectName: json['subject_name'],
      subjectSection: json['section'],
      subjectYear: json['year'].toString(),
    );
  }
}
