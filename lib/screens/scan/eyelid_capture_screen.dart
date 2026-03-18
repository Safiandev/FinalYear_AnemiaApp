import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hemoglobe_ai/screens/scan/review_photo_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class EyelidCaptureScreen extends StatefulWidget {
  const EyelidCaptureScreen({super.key});

  @override
  State<EyelidCaptureScreen> createState() => _EyelidCaptureScreenState();
}

class _EyelidCaptureScreenState extends State<EyelidCaptureScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0; // 0 for Back, 1 for Front
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera(0);
  }

  Future<void> _initializeCamera(int cameraIndex) async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
            _cameras![cameraIndex], ResolutionPreset.high,
            enableAudio: false);

        try {
          await _controller!.initialize();
          setState(() {
            _selectedCameraIndex = cameraIndex;
            _isCameraInitialized = true;
          });
        } catch (e) {
          debugPrint("Camera Error: $e");
        }
      }
    }
  }

  void _switchCamera() {
    if (_cameras == null || _cameras!.length < 2) return;
    int newIndex = _selectedCameraIndex == 0 ? 1 : 0;
    _initializeCamera(newIndex);
  }

  Future<void> _pickFromGallery() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _showEditPopup(pickedFile.path);
    }
  }

  // --- UPDATED GALLERY IMAGE ADJUSTMENT POPUP ---
  void _showEditPopup(String path) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog.fullscreen(
            backgroundColor: Colors.black,
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: const Text("Adjust Eyelid Image",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  leading: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context)),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close Popup
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    ReviewPhotoScreen(imagePath: path)));
                      },
                      child: const Text("DONE",
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    )
                  ],
                ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 1. IMPROVED INTERACTIVE VIEWER
                      InteractiveViewer(
                        boundaryMargin: const EdgeInsets.all(double.infinity),
                        minScale: 1.0,
                        maxScale: 5.0,
                        clipBehavior: Clip.none,
                        child: Center(
                          child: Container(
                            constraints: const BoxConstraints(
                                minWidth: 300, minHeight: 300),
                            child: Image.file(
                              File(path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      // 2. THE FOCUS OVERLAY (Black background with hole)
                      IgnorePointer(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.7),
                                BlendMode.srcOut,
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                      decoration: const BoxDecoration(
                                          color: Colors.transparent)),
                                  Center(
                                    child: Container(
                                      width: 260,
                                      height: 260,
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Blue border for the circle
                            Container(
                              width: 260,
                              height: 260,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.blue, width: 3),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 3. INSTRUCTIONS
                      Positioned(
                        bottom: 60,
                        child: IgnorePointer(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
                              "Fit your eyelid inside the blue circle",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final XFile image = await _controller!.takePicture();
      if (!mounted) return;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ReviewPhotoScreen(imagePath: image.path)));
    } catch (e) {
      debugPrint("Capture Error: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. CAMERA PREVIEW
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
          ),

          // 2. OVERLAY & CIRCLE
          IgnorePointer(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5), BlendMode.srcOut),
              child: Stack(
                children: [
                  Container(
                      decoration:
                          const BoxDecoration(color: Colors.transparent)),
                  Center(
                      child: Container(
                          width: 250,
                          height: 250,
                          decoration: const BoxDecoration(
                              color: Colors.black, shape: BoxShape.circle))),
                ],
              ),
            ),
          ),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue, width: 3)),
              ),
            ),
          ),

          // 3. TOP CONTROLS
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context)),
                  const Text('Capture Eyelid',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  IconButton(
                      icon: const Icon(Icons.flip_camera_ios,
                          color: Colors.white),
                      onPressed: _switchCamera),
                ],
              ),
            ),
          ),

          // 4. BOTTOM CONTROLS
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(30))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _actionBtn(
                          Icons.photo_library, "Gallery", _pickFromGallery),

                      // MAIN CAPTURE
                      GestureDetector(
                        onTap: _capturePhoto,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.blue.shade100, width: 5)),
                          child: const Center(
                              child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.blue,
                                  child: Icon(Icons.camera_alt,
                                      color: Colors.white))),
                        ),
                      ),

                      _actionBtn(_isFlashOn ? Icons.flash_on : Icons.flash_off,
                          "Flash", () {
                        setState(() => _isFlashOn = !_isFlashOn);
                        _controller!.setFlashMode(
                            _isFlashOn ? FlashMode.torch : FlashMode.off);
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.black54, size: 30),
          const SizedBox(height: 5),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
