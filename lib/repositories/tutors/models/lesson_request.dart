class LessonRequest {
  const LessonRequest({
    required this.lessonId,
    required this.reason,
    required this.newDate,
  });

  final int lessonId;
  final String reason;
  final String? newDate;
}