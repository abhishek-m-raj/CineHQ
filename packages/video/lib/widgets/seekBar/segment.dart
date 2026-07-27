class Segment {
  final String? name;
  final double start;
  final double end;

  const Segment({required this.name, required this.start, required this.end});

  double get diff {
    return end - start;
  }
}
