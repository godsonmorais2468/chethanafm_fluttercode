import 'dart:io';
import 'package:image/image.dart';

void main() {
  final imagePath = 'assets/icons/CHETHANA_new.jpg';
  final file = File(imagePath);
  if (!file.existsSync()) {
    print('Image not found');
    return;
  }

  final imageBytes = file.readAsBytesSync();
  final originalImage = decodeImage(imageBytes);

  if (originalImage == null) {
    print('Could not decode image');
    return;
  }

  print('Original Dimensions: ${originalImage.width}x${originalImage.height}');
  
  // Pad to square with white background
  int size = originalImage.width > originalImage.height ? originalImage.width : originalImage.height;
  final squareImage = Image(width: size, height: size, numChannels: 4);
  // Fill with white
  fill(squareImage, color: ColorRgba8(255, 255, 255, 255));
  
  final startX = (size - originalImage.width) ~/ 2;
  final startY = (size - originalImage.height) ~/ 2;
  compositeImage(squareImage, originalImage, dstX: startX, dstY: startY);

  final croppedImage = squareImage;
  
  // Sizes for mipmap
  final Map<String, int> sizes = {
    'mdpi': 48,
    'hdpi': 72,
    'xhdpi': 96,
    'xxhdpi': 144,
    'xxxhdpi': 192,
  };

  for (var entry in sizes.entries) {
    final density = entry.key;
    final dim = entry.value;

    // legacy
    final resized = copyResize(croppedImage, width: dim, height: dim, interpolation: Interpolation.average);
    
    final adaptiveDim = (dim * 2.25).toInt();
    
    // Create a 108x108 equivalent transparent canvas
    final foreground = Image(width: adaptiveDim, height: adaptiveDim, numChannels: 4);
    
    // Increase size of the logo in the adaptive icon: use 1.6 instead of 1.0
    final safeZoneImg = copyResize(croppedImage, width: (dim * 1.7).toInt(), height: (dim * 1.7).toInt(), interpolation: Interpolation.average);
    
    // Paste safeZoneImg into the center of the foreground
    final fgStartX = (adaptiveDim - safeZoneImg.width) ~/ 2;
    final fgStartY = (adaptiveDim - safeZoneImg.height) ~/ 2;
    
    compositeImage(foreground, safeZoneImg, dstX: fgStartX, dstY: fgStartY);

    final dir = Directory('android/app/src/main/res/mipmap-$density');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    
    File('${dir.path}/ic_launcher.png').writeAsBytesSync(encodePng(resized));
    File('${dir.path}/ic_launcher_round.png').writeAsBytesSync(encodePng(resized));
    File('${dir.path}/ic_launcher_foreground.png').writeAsBytesSync(encodePng(foreground));
    
    print('Generated $density');
  }

  // Generate transparent version for splash screen
  final transparentImg = Image.from(croppedImage);
  for (var p in transparentImg) {
    if (p.r >= 240 && p.g >= 240 && p.b >= 240) {
      p.a = 0; // Make near-white pixels transparent
    }
  }
  File('assets/icons/CHETHANA_transparent.png').writeAsBytesSync(encodePng(transparentImg));
  print('Generated CHETHANA_transparent.png');
}

