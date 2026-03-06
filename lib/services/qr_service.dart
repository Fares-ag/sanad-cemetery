import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:typed_data';
import '../models/deceased.dart';

/// QR code generation (admin) and parsing (scan). Deep link format: myapp://grave/UID123
class QrService {
  static const String scheme = 'myapp';
  static const String host = 'grave';

  /// Deep link for a deceased profile: myapp://grave/{id}
  static String deepLinkForId(String deceasedId) => '$scheme://$host/$deceasedId';

  /// Parse scanned string: accept either full deep link or plain UID.
  static String? parseGraveIdFromScanned(String? scanned) {
    if (scanned == null || scanned.isEmpty) return null;
    scanned = scanned.trim();
    // Deep link: myapp://grave/UID123 or https://domain/grave/UID123
    final uri = Uri.tryParse(scanned);
    if (uri != null) {
      if (uri.scheme == scheme && uri.host == host && uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.first;
      }
      if (uri.pathSegments.length >= 2 &&
          uri.pathSegments[uri.pathSegments.length - 2] == host) {
        return uri.pathSegments.last;
      }
    }
    // Plain UID (e.g. just "UID123" or "grave-abc-123")
    if (scanned.contains('/')) return null;
    return scanned;
  }

  /// Generate QR code widget data for a deceased (admin dashboard use).
  /// In production, render to image and export for etching (Anodized Aluminum / Granite).
  QrImageView buildQrWidget(
    Deceased deceased, {
    double size = 200,
    Color? foregroundColor,
    Color? backgroundColor,
  }) {
    final data = deceased.qrCodeData ?? deceased.deepLink;
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      gapless: true,
      foregroundColor: foregroundColor ?? const Color(0xFF000000),
      backgroundColor: backgroundColor ?? const Color(0xFFFFFFFF),
    );
  }

  /// Export QR as image bytes (for admin download / print).
  Future<Uint8List?> qrToImageBytes(String data, {double size = 512}) async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: data,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.M,
      );
      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode!;
        final painter = QrPainter.withQr(
          qr: qrCode,
          gapless: true,
          emptyColor: const Color(0xFFFFFFFF),
        );
        final picData = await painter.toImageData(size);
        if (picData == null) return null;
        return picData.buffer.asUint8List(picData.offsetInBytes, picData.lengthInBytes);
      }
    } catch (_) {}
    return null;
  }
}
