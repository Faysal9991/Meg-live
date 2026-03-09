class HomeBanner {
  const HomeBanner({required this.image});

  final String image;

  factory HomeBanner.fromJson(Map<String, dynamic> json) {
    return HomeBanner(image: (json['image'] ?? '').toString());
  }
}
