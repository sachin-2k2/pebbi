import 'dart:ui';
import 'package:flutter/material.dart';
import 'splash_config.dart';

/// Data model for floating decorative items around the screen.
class SplashDecorationItemData {
  const SplashDecorationItemData({
    required this.id,
    required this.emoji,
    required this.fractionX,
    required this.fractionY,
    this.size = 28.0,
    this.dropPriority = 1,
  });

  final String id;
  final String emoji;
  final double fractionX;
  final double fractionY;
  final double size;
  final int dropPriority; // 1 = lowest (dropped first), 5 = highest
}

/// Data model for multilingual pale greetings.
class SplashGreetingData {
  const SplashGreetingData({
    required this.text,
    required this.languageCode,
    required this.fractionX,
    required this.fractionY,
    this.fontSize = 14.0,
    this.opacity = 0.28,
    this.textDirection = TextDirection.ltr,
    this.dropPriority = 1,
  });

  final String text;
  final String languageCode;
  final double fractionX;
  final double fractionY;
  final double fontSize;
  final double opacity;
  final TextDirection textDirection;
  final int dropPriority;
}

/// Master configuration defining deterministic positions and clear zone bounds.
abstract final class SplashDecorationConfig {
  /// Computes the exact protected clear zone bounding box around the
  /// logo tile, wordmark, tagline, and loading dashes.
  static Rect computeClearZone(Size screenSize) {
    final cx = screenSize.width / 2;
    final cy = screenSize.height / 2;

    // Tile: 96x96 centered at (cx, cy) -> cy - 48 .. cy + 48
    // Wordmark + Tagline + Dashes sit below tile: down to cy + 144
    // We add a 16dp padding margin around the entire group:
    const padding = 16.0;
    const groupHalfWidth = 100.0; // half of 200dp max content width
    final top = cy - (SplashConfig.tileLogicalSize / 2) - padding;
    final bottom = cy + (SplashConfig.tileLogicalSize / 2) + 96.0 + padding;

    return Rect.fromLTRB(
      cx - groupHalfWidth - padding,
      top,
      cx + groupHalfWidth + padding,
      bottom,
    );
  }

  /// 11 floating decorative items.
  static const List<SplashDecorationItemData> floatingItems = [
    SplashDecorationItemData(
      id: 'hand',
      emoji: '👋',
      fractionX: 0.10,
      fractionY: 0.08,
      dropPriority: 3,
    ),
    SplashDecorationItemData(
      id: 'coffee',
      emoji: '☕',
      fractionX: 0.84,
      fractionY: 0.16,
      dropPriority: 3,
    ),
    SplashDecorationItemData(
      id: 'croissant',
      emoji: '🥐',
      fractionX: 0.50,
      fractionY: 0.24,
      dropPriority: 2,
    ),
    SplashDecorationItemData(
      id: 'sparkles',
      emoji: '✨',
      fractionX: 0.82,
      fractionY: 0.30,
      dropPriority: 4,
    ),
    SplashDecorationItemData(
      id: 'compass',
      emoji: '🧭',
      fractionX: 0.08,
      fractionY: 0.35,
      dropPriority: 2,
    ),
    SplashDecorationItemData(
      id: 'ticket',
      emoji: '🎫',
      fractionX: 0.90,
      fractionY: 0.46,
      dropPriority: 1,
    ),
    SplashDecorationItemData(
      id: 'heart',
      emoji: '💛',
      fractionX: 0.88,
      fractionY: 0.60,
      size: 22.0,
      dropPriority: 4,
    ),
    SplashDecorationItemData(
      id: 'flame',
      emoji: '🔥',
      fractionX: 0.08,
      fractionY: 0.62,
      dropPriority: 2,
    ),
    SplashDecorationItemData(
      id: 'bubble',
      emoji: '💬',
      fractionX: 0.89,
      fractionY: 0.72,
      dropPriority: 2,
    ),
    SplashDecorationItemData(
      id: 'star',
      emoji: '⭐',
      fractionX: 0.72,
      fractionY: 0.84,
      dropPriority: 3,
    ),
    SplashDecorationItemData(
      id: 'key',
      emoji: '🔑',
      fractionX: 0.22,
      fractionY: 0.88,
      dropPriority: 1,
    ),
  ];

  /// 10 Multilingual greetings.
  static const List<SplashGreetingData> greetings = [
    SplashGreetingData(
      text: 'مرحباً',
      languageCode: 'ar',
      fractionX: 0.26,
      fractionY: 0.77,
      fontSize: 15.0,
      textDirection: TextDirection.rtl,
      dropPriority: 2,
    ),
    SplashGreetingData(
      text: '你好',
      languageCode: 'zh',
      fractionX: 0.68,
      fractionY: 0.77,
      fontSize: 15.0,
      dropPriority: 2,
    ),
    SplashGreetingData(
      text: 'Bonjour',
      languageCode: 'fr',
      fractionX: 0.22,
      fractionY: 0.82,
      fontSize: 14.0,
      dropPriority: 3,
    ),
    SplashGreetingData(
      text: '안녕',
      languageCode: 'ko',
      fractionX: 0.62,
      fractionY: 0.82,
      fontSize: 14.0,
      dropPriority: 2,
    ),
    SplashGreetingData(
      text: 'Hallo',
      languageCode: 'de',
      fractionX: 0.06,
      fractionY: 0.87,
      fontSize: 13.0,
      dropPriority: 2,
    ),
    SplashGreetingData(
      text: 'Hola',
      languageCode: 'es',
      fractionX: 0.24,
      fractionY: 0.87,
      fontSize: 14.0,
      dropPriority: 3,
    ),
    SplashGreetingData(
      text: 'こんにちは',
      languageCode: 'ja',
      fractionX: 0.54,
      fractionY: 0.87,
      fontSize: 13.0,
      dropPriority: 2,
    ),
    SplashGreetingData(
      text: 'Hello',
      languageCode: 'en',
      fractionX: 0.06,
      fractionY: 0.93,
      fontSize: 14.0,
      dropPriority: 4,
    ),
    SplashGreetingData(
      text: 'नमस्ते',
      languageCode: 'hi',
      fractionX: 0.40,
      fractionY: 0.93,
      fontSize: 15.0,
      dropPriority: 2,
    ),
    SplashGreetingData(
      text: 'Olá',
      languageCode: 'pt',
      fractionX: 0.78,
      fractionY: 0.93,
      fontSize: 14.0,
      dropPriority: 2,
    ),
  ];
}
