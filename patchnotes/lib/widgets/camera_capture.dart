import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraCapturePage extends StatefulWidget {
  const CameraCapturePage({Key? key}) : super(key: key);

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCapturing = false;


  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras![0], ResolutionPreset.high);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _takePicture() async {
  if (_isCapturing || _controller == null || !_controller!.value.isInitialized) return;

  setState(() {
    _isCapturing = true;
  });

  try {
    final image = await _controller!.takePicture();
    if (mounted) {
      Navigator.pop(context, image);
    }
  } catch (e) {
    debugPrint("Capture failed: $e");
  } finally {
    if (mounted) {
      setState(() {
        _isCapturing = false;
      });
    }
  }
}

  Widget _buildCameraPreview() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        CameraPreview(_controller!),
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                onPressed: _isCapturing ? null : _takePicture,
                icon: const Icon(Icons.camera_alt),
                label: const Text("Capture"),
              ),
            ],
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _buildCameraPreview(),
      ),
    );
  }
}
