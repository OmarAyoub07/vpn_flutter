import 'dart:io';
import 'dart:typed_data';
import 'dart:math';

/// Converts a PNG file to a Windows ICO file containing multiple sizes.
/// ICO format: https://en.wikipedia.org/wiki/ICO_(file_format)
void main() async {
  final pngFile = File('assets/launcher/icon.png');
  final icoFile = File('windows/runner/resources/app_icon.ico');

  final pngBytes = await pngFile.readAsBytes();

  // ICO with a single 256x256 PNG entry (Windows supports PNG-compressed ICO)
  final ico = _buildIco([pngBytes]);
  await icoFile.writeAsBytes(ico);
  print('Written ${ico.length} bytes to ${icoFile.path}');
}

Uint8List _buildIco(List<Uint8List> pngImages) {
  // ICO header: 6 bytes
  // Each directory entry: 16 bytes
  // Then image data

  final numImages = pngImages.length;
  final headerSize = 6 + numImages * 16;

  var dataOffset = headerSize;
  final builder = BytesBuilder();

  // ICO header
  builder.add(_uint16LE(0));          // reserved
  builder.add(_uint16LE(1));          // type: 1 = ICO
  builder.add(_uint16LE(numImages));  // number of images

  // Directory entries
  for (final png in pngImages) {
    final size = _getPngSize(png);
    final w = size[0] >= 256 ? 0 : size[0]; // 0 means 256
    final h = size[1] >= 256 ? 0 : size[1];

    builder.addByte(w);           // width
    builder.addByte(h);           // height
    builder.addByte(0);           // color palette (0 = no palette)
    builder.addByte(0);           // reserved
    builder.add(_uint16LE(1));    // color planes
    builder.add(_uint16LE(32));   // bits per pixel
    builder.add(_uint32LE(png.length)); // image size
    builder.add(_uint32LE(dataOffset)); // offset to image data
    dataOffset += png.length;
  }

  // Image data
  for (final png in pngImages) {
    builder.add(png);
  }

  return builder.toBytes();
}

List<int> _getPngSize(Uint8List png) {
  // PNG IHDR chunk starts at offset 16 (after 8-byte signature + 4-byte length + 4-byte type)
  final bd = ByteData.sublistView(png);
  final w = bd.getUint32(16, Endian.big);
  final h = bd.getUint32(20, Endian.big);
  return [w, h];
}

Uint8List _uint16LE(int value) {
  final bd = ByteData(2);
  bd.setUint16(0, value, Endian.little);
  return bd.buffer.asUint8List();
}

Uint8List _uint32LE(int value) {
  final bd = ByteData(4);
  bd.setUint32(0, value, Endian.little);
  return bd.buffer.asUint8List();
}
