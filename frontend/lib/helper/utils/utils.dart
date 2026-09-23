import 'package:flutter/material.dart';
import 'package:qr_app/helper/extensions/extensions.dart';

class Utils {
  static String formatDate(
    dynamic dateInput, {
    String pattern = 'dd/MM/yyyy', // Mặc định dd/MM/yyyy
    String fallback = '-',
  }) {
    if (dateInput == null) return fallback;

    try {
      DateTime? parsedDate;

      if (dateInput is DateTime) {
        parsedDate = dateInput;
      } else if (dateInput is String) {
        if (dateInput.trim().isEmpty) return fallback;
        // Parse chuỗi ISO 8601 (VD: 2026-09-06T16:07:29.697Z)
        parsedDate = DateTime.tryParse(dateInput.trim())?.toLocal();
      }

      if (parsedDate == null) return fallback;

      // Xử lý định dạng đầu ra thủ công không cần thư viện ngoài
      String day = parsedDate.day.toString().padLeft(2, '0');
      String month = parsedDate.month.toString().padLeft(2, '0');
      String year = parsedDate.year.toString();
      String hour = parsedDate.hour.toString().padLeft(2, '0');
      String minute = parsedDate.minute.toString().padLeft(2, '0');

      switch (pattern) {
        case 'dd/MM/yyyy':
          return '$day/$month/$year';
        case 'yyyy-MM-dd':
          return '$year-$month-$day';
        case 'dd/MM/yyyy HH:mm':
          return '$day/$month/$year $hour:$minute';
        default:
          return '$day/$month/$year';
      }
    } catch (e) {
      debugPrint("❌ Lỗi format date: $e");
      return fallback;
    }
  }

  static String getDateStringFromDateTime(
    DateTime dateTime, {
    bool showMonthShort = false,
  }) {
    String date = dateTime.day < 10
        ? "0${dateTime.day}"
        : dateTime.day.toString();
    late String month;
    if (showMonthShort) {
      month = dateTime.getMonthName();
    } else {
      month = dateTime.month < 10
          ? "0${dateTime.month}"
          : dateTime.month.toString();
    }

    String year = dateTime.year.toString();
    String separator = showMonthShort ? " " : "/";
    return "$date$separator$month$separator$year";
  }

  static String getTimeStringFromDateTime(
    DateTime dateTime, {
    bool showSecond = true,
  }) {
    String hour = dateTime.hour.toString();
    if (dateTime.hour > 12) {
      hour = (dateTime.hour - 12).toString();
    }

    String minute = dateTime.minute < 10
        ? "0${dateTime.minute}"
        : dateTime.minute.toString();
    String second = "";

    if (showSecond) {
      second = dateTime.second < 10
          ? "0${dateTime.second}"
          : dateTime.second.toString();
    }
    String meridian = "";
    meridian = dateTime.hour < 12 ? " AM" : " PM";

    return "$hour:$minute${showSecond ? ":" : ""}$second$meridian";
  }

  static String getDateTimeStringFromDateTime(
    DateTime dateTime, {
    bool showSecond = true,
    bool showDate = true,
    bool showTime = true,
    bool showMonthShort = false,
  }) {
    if (showDate && !showTime) {
      return getDateStringFromDateTime(dateTime);
    } else if (!showDate && showTime) {
      return getTimeStringFromDateTime(dateTime, showSecond: showSecond);
    }
    return "${getDateStringFromDateTime(dateTime, showMonthShort: showMonthShort)} ${getTimeStringFromDateTime(dateTime, showSecond: showSecond)}";
  }

  static String getStorageStringFromByte(int bytes) {
    double b = bytes.toDouble(); //1024
    double k = bytes / 1024; //1
    double m = k / 1024; //0.001
    double g = m / 1024; //...
    double t = g / 1024; //...

    if (t >= 1) {
      return "${t.toStringAsFixed(2)} TB";
    } else if (g >= 1) {
      return "${g.toStringAsFixed(2)} GB";
    } else if (m >= 1) {
      return "${m.toStringAsFixed(2)} MB";
    } else if (k >= 1) {
      return "${k.toStringAsFixed(2)} KB";
    } else {
      return "${b.toStringAsFixed(2)} Bytes";
    }
  }
}
