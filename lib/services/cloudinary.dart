import 'dart:typed_data';
import 'package:cloudinary_public/cloudinary_public.dart' as cpublic;
import 'package:cloudinary_sdk/cloudinary_sdk.dart' as csdk;

final cloudinary = cpublic.CloudinaryPublic('dkdy9xmeg', 'flutter_upload', cache: false);

// Authentication for deletion
final cloudinarySdk = csdk.Cloudinary.full(
  apiKey: '871287191969857',
  apiSecret: 'HlLkgYagyntIV2u03ho6kPoUqiU',
  cloudName: 'dkdy9xmeg',
);

Future<String?> cloudinaryUploadImage(Uint8List imageBytes, String? username, {String? oldImageUrl}) async {
  try {
    // Delete the old image if it exists
    if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
      await cloudinaryDeleteOldImage(oldImageUrl);
    }

    // Upload new image
    cpublic.CloudinaryResponse response = await cloudinary.uploadFile(
      cpublic.CloudinaryFile.fromByteData(
        ByteData.view(imageBytes.buffer),
        identifier: username != null ? "user_faces/$username" : "user_faces/${DateTime.now().millisecondsSinceEpoch}",
        folder: "user_faces", // ✅ Ensure the image is placed in the correct folder
      ),
    );

    return response.secureUrl;
  } catch (e) {
    print("Error uploading image: $e");
    return null;
  }
}

Future<void> cloudinaryDeleteOldImage(String imageUrl) async {
  try {
    Uri uri = Uri.parse(imageUrl);
    String lastSegment = uri.pathSegments.last;
    String publicId = lastSegment.split('.').first; // Extract "abc123" from "abc123.png"

    // Call Cloudinary to delete the image
     await cloudinarySdk.deleteResource(
      publicId: "user_faces/$publicId",
      resourceType: csdk.CloudinaryResourceType.image,
    );

  } catch (e) {
    print("Error deleting old image: $e");
  }
}
