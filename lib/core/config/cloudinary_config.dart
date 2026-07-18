import 'package:cloudinary_url_gen/cloudinary.dart';

class CloudinaryConfig {
  static const String cloudName = 'wsomcpei';
  static final Cloudinary cloudinary = Cloudinary.fromCloudName(
    cloudName: cloudName,
  )..config.urlConfig.secure = true;

  static void init() {
    cloudinary.config.urlConfig.secure = true;
  }
}
