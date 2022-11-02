import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'confirm_food_image.dart';


class CaptureFoodImage extends StatefulWidget {
  CaptureFoodImage({Key? key,required this.matchDetailsMap}) : super(key: key);

  final camera = globals.cameras[0]; //Specify which camera to use.
  final Map matchDetailsMap;

  @override
  _CaptureFoodImageState createState() => _CaptureFoodImageState();
}

class _CaptureFoodImageState extends State<CaptureFoodImage> {

  late CameraController _controller;
  late Future<void> _initializeControllerFuture;


  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.high,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture'),),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            // If the picture was taken, display it on a new screen.
          await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ConfirmAndSaveFoodImage(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  localImagePath: image.path,
                  matchDetailsMap: widget.matchDetailsMap,
                ),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}


