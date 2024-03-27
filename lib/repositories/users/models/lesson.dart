class Lesson {
  const Lesson({
    required this.lessonId,
    required this.tutor,
    required this.student,
    required this.subject,
    required this.date,
  });

  final int lessonId;
  final String tutor;
  final String student;
  final String subject;
  final String date;
}