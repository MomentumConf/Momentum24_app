class SocialMedia {
  final String? facebook;
  final String? tiktok;
  final String? instagram;
  final String? website;

  SocialMedia({
    this.facebook,
    this.tiktok,
    this.instagram,
    this.website,
  });

  factory SocialMedia.fromJson(Map<String, dynamic> json) {
    return SocialMedia(
      facebook: json['facebook'],
      tiktok: json['tiktok'],
      instagram: json['instagram'],
      website: json['website'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'facebook': facebook,
      'tiktok': tiktok,
      'instagram': instagram,
      'website': website,
    };
  }
}
