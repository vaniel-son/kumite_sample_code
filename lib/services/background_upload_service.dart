import 'package:dojo_app/models/video_model.dart';
import 'package:flutter_uploader/flutter_uploader.dart';

/// This method uses the flutter_uploader package to upload file in the background.
Future<void> uploadFileBackground(videoName,filePath, uploadUrl) async {
  final  videoInfo = VideoModel(
    uploadedAt: DateTime.now(),
    videoName: videoName,
  );

  final tag = 'upload';

  final upload = RawUpload(
      url: uploadUrl,
      path: filePath,
      method: UploadMethod.PUT,
      tag: tag,
      allowCellular: true
  );


  FlutterUploader _uploader = FlutterUploader();
  await _uploader.enqueue(upload);
}