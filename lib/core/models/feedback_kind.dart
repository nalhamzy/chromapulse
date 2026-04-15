enum FeedbackKind {
  blazing('BLAZING'),
  nice('NICE'),
  correct('CORRECT'),
  perfect('PERFECT'),
  great('GREAT'),
  good('GOOD'),
  ok('OK'),
  miss('MISS'),
  timeUp("TIME'S UP");

  final String label;
  const FeedbackKind(this.label);

  bool get isPositive =>
      this == FeedbackKind.blazing ||
      this == FeedbackKind.nice ||
      this == FeedbackKind.correct ||
      this == FeedbackKind.perfect ||
      this == FeedbackKind.great ||
      this == FeedbackKind.good;

  bool get isNegative => this == FeedbackKind.miss || this == FeedbackKind.timeUp;
}
