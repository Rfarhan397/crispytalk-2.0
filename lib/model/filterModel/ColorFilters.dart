import 'dart:typed_data';

class MediaWithFilter {
  final Uint8List mediaBytes;
  final String mediaType;
  final int? selectedFilterIndex;

  MediaWithFilter({
    required this.mediaBytes,
    required this.mediaType,
    this.selectedFilterIndex,
  });
}
