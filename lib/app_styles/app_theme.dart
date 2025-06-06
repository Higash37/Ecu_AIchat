import 'package:flutter/material.dart';

class AppTheme {
  // メインカラー
  static const Color primaryColor = Color(0xFF5D4FFF); // メインカラー（アクセント、強調部分）
  static const Color secondaryColor = Color(0xFF83B1FF); // サブカラー（アイコンなど）
  static const Color userBubbleColor = Color(0xFF4CAF50); // グリーン（ユーザーメッセージバブル）
  static const Color backgroundColor = Color(0xFFF9F9F9); // Notion系ライトグレー背景
  static const Color cardColor = Color(0xFFFFFFFF); // カードの背景色（白）

  // テキストカラー
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textLight = Color(0xFF999999);

  // シャドウ
  static BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );
  // テキストスタイル
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    fontFamily: 'NotoSansJP',
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    fontFamily: 'NotoSansJP',
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    color: textPrimary,
    fontFamily: 'NotoSansJP',
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    color: textSecondary,
    fontFamily: 'NotoSansJP',
  );

  // ボタンスタイル
  static final ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static final ButtonStyle secondaryButton = OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    side: const BorderSide(color: primaryColor),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  // カードスタイル
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [cardShadow],
  );
  // チャットバブルスタイル（LINEとChatGPT風の融合）
  static BoxDecoration aiMessageBubble = BoxDecoration(
    color: Color(0xFFF0F7FF), // ChatGPT風の薄い青色
    borderRadius: const BorderRadius.only(
      topRight: Radius.circular(18),
      bottomLeft: Radius.circular(18),
      bottomRight: Radius.circular(18),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ],
  );

  static BoxDecoration userMessageBubble = BoxDecoration(
    color: Color(0xFFE1F5E4), // LINE風の薄緑色
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(18),
      bottomLeft: Radius.circular(18),
      bottomRight: Radius.circular(18),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ],
  );

  // リストタイルスタイル
  static BoxDecoration listTileDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // アプリバーテーマ
  static AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: Colors.white,
    centerTitle: true,
    elevation: 0,
    iconTheme: const IconThemeData(color: primaryColor),
    titleTextStyle: heading2,
  );
  // テーマデータ
  static ThemeData themeData = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: appBarTheme,
    fontFamily: 'NotoSansJP',
    textTheme: const TextTheme(
      displayLarge: heading1,
      displayMedium: heading2,
      bodyLarge: bodyText,
      bodyMedium: caption,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButton),
    outlinedButtonTheme: OutlinedButtonThemeData(style: secondaryButton),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
    ),
  );
}
