import 'dart:io';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

class ExcelService {
  static final _db = FirebaseFirestore.instance;

  static const _months = [
    'Yanvar','Fevral','Mart','Aprel','May','Iyun',
    'Iyul','Avgust','Sentabr','Oktabr','Noyabr','Dekabr'
  ];

  static const _fullDays = [
    'Dushanba','Seshanba','Chorshanba',
    'Payshanba','Juma','Shanba','Yakshanba'
  ];

  // ── OYLIK JADVAL EKSPORT ───────────────────────────────
  static Future<String?> exportMonthlyShifts({
    required int year,
    required int month,
    required Function(String) onProgress,
  }) async {
    try {
      onProgress('Ma\'lumotlar yuklanmoqda...');

      // Ruxsat so'rash
      if (Platform.isAndroid) {
        final status =
        await Permission.storage.request();
        if (!status.isGranted) {
          return 'Fayl saqlash uchun ruxsat kerak';
        }
      }

      final monthStr = month.toString().padLeft(2, '0');
      final monthStart = '$year-$monthStr-01';
      final monthEnd = '$year-$monthStr-31';

      // Smenalarni olish
      final shiftsSnap = await _db
          .collection('shifts')
          .where('date', isGreaterThanOrEqualTo: monthStart)
          .where('date', isLessThanOrEqualTo: monthEnd)
          .orderBy('date')
          .get();

      // Ishchilarni olish
      final workersSnap = await _db
          .collection('users')
          .where('role', isEqualTo: 'worker')
          .orderBy('name')
          .get();

      onProgress('Excel fayli yaratilmoqda...');

      // Workbook yaratish
      final workbook = Workbook();
      workbook.worksheets.clear();

      // ── 1-SHEET: Umumiy jadval ──────────────────────
      final sheet1 = workbook.worksheets.addWithName(
          '${_months[month - 1]} $year');
      _buildMonthlySheet(
          sheet1, shiftsSnap.docs, workersSnap.docs,
          year, month);

      // ── 2-SHEET: Ishchi statistikasi ──────────────
      final sheet2 = workbook.worksheets
          .addWithName('Statistika');
      _buildStatsSheet(
          sheet2, shiftsSnap.docs, workersSnap.docs,
          year, month);

      onProgress('Fayl saqlanmoqda...');

      // Faylni saqlash
      final bytes = workbook.saveAsStream();
      workbook.dispose();

      final dir = await getExternalStorageDirectory();
      final fileName =
          'Mario_${_months[month - 1]}_$year.xlsx';
      final file = File('${dir!.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);

      onProgress('Tayyor!');
      return file.path;
    } catch (e) {
      return null;
    }
  }

  // ── OYLIK SHEET ────────────────────────────────────────
  static void _buildMonthlySheet(
      Worksheet sheet,
      List<QueryDocumentSnapshot> shifts,
      List<QueryDocumentSnapshot> workers,
      int year,
      int month,
      ) {
    // Oyning barcha kunlari
    final daysInMonth =
        DateTime(year, month + 1, 0).day;
    final dates = List.generate(
      daysInMonth,
          (i) => DateTime(year, month, i + 1),
    );

    // ── SARLAVHA ────────────────────────────────────────
    sheet.getRangeByName('A1').setText('Mario Fabrika');
    sheet.getRangeByName('A1').cellStyle.bold = true;
    sheet.getRangeByName('A1').cellStyle.fontSize = 14;

    sheet.getRangeByName('A2').setText(
        '${_months[month - 1]} $year — Smena jadvali');
    sheet.getRangeByName('A2').cellStyle.fontSize = 11;

    // ── USTUN SARLAVHALARI ──────────────────────────────
    final headerRow = 4;
    sheet.getRangeByIndex(headerRow, 1).setText('№');
    sheet.getRangeByIndex(headerRow, 2).setText('Ishchi ismi');

    for (int i = 0; i < dates.length; i++) {
      final date = dates[i];
      final cell =
      sheet.getRangeByIndex(headerRow, i + 3);
      cell.setText('${date.day}\n'
          '${_dayNames(date.weekday)}');
      cell.cellStyle.bold = true;
      cell.cellStyle.hAlign = HAlignType.center;
      cell.cellStyle.wrapText = true;

      // Dam olish kunlari sariq
      if (date.weekday >= 6) {
        cell.cellStyle.backColor = '#FFF3CD';
      } else {
        cell.cellStyle.backColor = '#E8F4F8';
      }
    }

    // Jami, Kunduzgi, Tungi ustunlari
    final totalCol = dates.length + 3;
    sheet.getRangeByIndex(headerRow, totalCol)
        .setText('Jami soat');
    sheet.getRangeByIndex(headerRow, totalCol + 1)
        .setText('Kunduzgi');
    sheet.getRangeByIndex(headerRow, totalCol + 2)
        .setText('Tungi');
    sheet.getRangeByIndex(headerRow, totalCol + 3)
        .setText('Dam olish');

    // Header style
    final headerRange = sheet.getRangeByIndex(
        headerRow, 1, headerRow, totalCol + 3);
    headerRange.cellStyle.bold = true;
    headerRange.cellStyle.fontSize = 10;

    // ── ISHCHILAR SATRLARI ──────────────────────────────
    for (int wi = 0; wi < workers.length; wi++) {
      final worker = workers[wi];
      final workerData =
      worker.data() as Map<String, dynamic>;
      final workerName = workerData['name'] ?? '';
      final row = headerRow + wi + 1;

      // Raqam va ism
      sheet.getRangeByIndex(row, 1).setNumber(wi + 1);
      sheet.getRangeByIndex(row, 2).setText(workerName);
      sheet.getRangeByIndex(row, 2).cellStyle.bold = true;

      int totalMinutes = 0;
      int morningCount = 0;
      int nightCount = 0;
      int offCount = 0;

      // Har bir kun uchun
      for (int di = 0; di < dates.length; di++) {
        final date = dates[di];
        final dateStr = _formatDate(date);
        final cell =
        sheet.getRangeByIndex(row, di + 3);

        // Bu ishchining bu kundagi smenasi
        final shift = shifts.firstWhere(
              (s) {
            final d = s.data() as Map;
            return d['workerId'] == worker.id &&
                d['date'] == dateStr;
          },
          orElse: () => shifts.first,
        );

        final hasShift = shifts.any((s) {
          final d = s.data() as Map;
          return d['workerId'] == worker.id &&
              d['date'] == dateStr;
        });

        if (hasShift) {
          final shiftData =
          shift.data() as Map<String, dynamic>;
          final type = shiftData['type'] ?? '';
          final start = shiftData['startTime'] ?? '';
          final end = shiftData['endTime'] ?? '';

          String cellText;
          String bgColor;

          switch (type) {
            case 'morning':
              cellText = start.isNotEmpty
                  ? '$start-$end'
                  : 'K';
              bgColor = '#FAECE7';
              morningCount++;
              // Soat hisoblash
              if (start.isNotEmpty && end.isNotEmpty) {
                totalMinutes +=
                    _calcMinutes(start, end);
              }
              break;
            case 'night':
              cellText = start.isNotEmpty
                  ? '$start-$end'
                  : 'T';
              bgColor = '#EEEDFE';
              nightCount++;
              if (start.isNotEmpty && end.isNotEmpty) {
                totalMinutes +=
                    _calcMinutes(start, end);
              }
              break;
            case 'half':
              cellText = start.isNotEmpty
                  ? '$start-$end'
                  : 'Y';
              bgColor = '#EAF3DE';
              morningCount++;
              if (start.isNotEmpty && end.isNotEmpty) {
                totalMinutes +=
                    _calcMinutes(start, end);
              }
              break;
            case 'off':
              cellText = 'D';
              bgColor = '#F1EFE8';
              offCount++;
              break;
            default:
              cellText = '';
              bgColor = '#FFFFFF';
          }

          cell.setText(cellText);
          cell.cellStyle.backColor = bgColor;
          cell.cellStyle.hAlign = HAlignType.center;
          cell.cellStyle.fontSize = 8;
        } else {
          cell.cellStyle.backColor = '#FFFFFF';
        }

        // Dam olish kuni
        if (date.weekday >= 6 && !hasShift) {
          cell.cellStyle.backColor = '#FFF9E6';
        }
      }

      // Jami statistika
      final totalHours = totalMinutes ~/ 60;
      final totalMins = totalMinutes % 60;
      sheet.getRangeByIndex(row, totalCol)
          .setText('${totalHours}s ${totalMins}m');
      sheet.getRangeByIndex(row, totalCol + 1)
          .setNumber(morningCount.toDouble());
      sheet.getRangeByIndex(row, totalCol + 2)
          .setNumber(nightCount.toDouble());
      sheet.getRangeByIndex(row, totalCol + 3)
          .setNumber(offCount.toDouble());

      // Juft/toq satr rangi
      if (wi % 2 == 0) {
        sheet
            .getRangeByIndex(row, 1, row, totalCol + 3)
            .cellStyle
            .backColor = '#FAFAFA';
      }
    }

    // ── USTUN KENGLIGINI SOZLASH ─────────────────────
    sheet.autoFitColumn(1);
    sheet.autoFitColumn(2);
    for (int i = 3; i < dates.length + 3; i++) {
      sheet.getRangeByIndex(1, i)
          .columnWidth = 6;
    }

    // ── IZOH ────────────────────────────────────────────
    final legendRow = headerRow + workers.length + 2;
    sheet.getRangeByIndex(legendRow, 1)
        .setText('Izoh:');
    sheet.getRangeByIndex(legendRow, 2)
        .setText('K = Kunduzgi');
    sheet.getRangeByIndex(legendRow, 2)
        .cellStyle.backColor = '#FAECE7';
    sheet.getRangeByIndex(legendRow, 3)
        .setText('T = Tungi');
    sheet.getRangeByIndex(legendRow, 3)
        .cellStyle.backColor = '#EEEDFE';
    sheet.getRangeByIndex(legendRow, 4)
        .setText('Y = Yarim smena');
    sheet.getRangeByIndex(legendRow, 4)
        .cellStyle.backColor = '#EAF3DE';
    sheet.getRangeByIndex(legendRow, 5)
        .setText('D = Dam olish');
    sheet.getRangeByIndex(legendRow, 5)
        .cellStyle.backColor = '#F1EFE8';
  }

  // ── STATISTIKA SHEET ───────────────────────────────────
  static void _buildStatsSheet(
      Worksheet sheet,
      List<QueryDocumentSnapshot> shifts,
      List<QueryDocumentSnapshot> workers,
      int year,
      int month,
      ) {
    // Sarlavha
    sheet.getRangeByName('A1')
        .setText('Ishchi statistikasi');
    sheet.getRangeByName('A1').cellStyle.bold = true;
    sheet.getRangeByName('A1').cellStyle.fontSize = 14;
    sheet.getRangeByName('A2')
        .setText('${_months[month - 1]} $year');

    // Header
    const headers = [
      '№', 'Ishchi', 'Jami soat', 'Ish kuni',
      'Kunduzgi', 'Tungi', 'Yarim', 'Dam olish',
      'O\'rtacha soat/kun'
    ];

    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.getRangeByIndex(4, i + 1);
      cell.setText(headers[i]);
      cell.cellStyle.bold = true;
      cell.cellStyle.backColor = '#C0392B';
      cell.cellStyle.fontColor = '#FFFFFF';
      cell.cellStyle.hAlign = HAlignType.center;
    }

    // Ishchilar
    for (int wi = 0; wi < workers.length; wi++) {
      final worker = workers[wi];
      final workerData =
      worker.data() as Map<String, dynamic>;
      final workerName = workerData['name'] ?? '';
      final row = wi + 5;

      final workerShifts = shifts.where((s) {
        final d = s.data() as Map;
        return d['workerId'] == worker.id;
      }).toList();

      int totalMinutes = 0;
      int morningCount = 0;
      int nightCount = 0;
      int halfCount = 0;
      int offCount = 0;

      for (final shift in workerShifts) {
        final d = shift.data() as Map<String, dynamic>;
        final type = d['type'] ?? '';
        final start = d['startTime'] ?? '';
        final end = d['endTime'] ?? '';

        switch (type) {
          case 'morning':
            morningCount++;
            if (start.isNotEmpty && end.isNotEmpty) {
              totalMinutes += _calcMinutes(start, end);
            }
            break;
          case 'night':
            nightCount++;
            if (start.isNotEmpty && end.isNotEmpty) {
              totalMinutes += _calcMinutes(start, end);
            }
            break;
          case 'half':
            halfCount++;
            if (start.isNotEmpty && end.isNotEmpty) {
              totalMinutes += _calcMinutes(start, end);
            }
            break;
          case 'off':
            offCount++;
            break;
        }
      }

      final workDays =
          morningCount + nightCount + halfCount;
      final totalHours = totalMinutes ~/ 60;
      final avgHours = workDays > 0
          ? (totalMinutes / 60 / workDays)
          .toStringAsFixed(1)
          : '0';

      sheet.getRangeByIndex(row, 1)
          .setNumber(wi + 1);
      sheet.getRangeByIndex(row, 2)
          .setText(workerName);
      sheet.getRangeByIndex(row, 3)
          .setText('$totalHours soat');
      sheet.getRangeByIndex(row, 4)
          .setNumber(workDays.toDouble());
      sheet.getRangeByIndex(row, 5)
          .setNumber(morningCount.toDouble());
      sheet.getRangeByIndex(row, 6)
          .setNumber(nightCount.toDouble());
      sheet.getRangeByIndex(row, 7)
          .setNumber(halfCount.toDouble());
      sheet.getRangeByIndex(row, 8)
          .setNumber(offCount.toDouble());
      sheet.getRangeByIndex(row, 9)
          .setText(avgHours);

      // Juft/toq rang
      if (wi % 2 == 0) {
        sheet
            .getRangeByIndex(row, 1, row, 9)
            .cellStyle
            .backColor = '#FFF5F5';
      }
    }

    // AutoFit
    for (int i = 1; i <= 9; i++) {
      sheet.autoFitColumn(i);
    }
  }

  // ── YORDAMCHI ──────────────────────────────────────────
  static int _calcMinutes(String start, String end) {
    try {
      final sp = start.split(':');
      final ep = end.split(':');
      var s = int.parse(sp[0]) * 60 + int.parse(sp[1]);
      var e = int.parse(ep[0]) * 60 + int.parse(ep[1]);
      if (e < s) e += 24 * 60;
      return e - s;
    } catch (_) {
      return 0;
    }
  }

  static String _dayNames(int weekday) {
    const names = ['Du','Se','Ch','Pa','Ju','Sh','Ya'];
    return names[weekday - 1];
  }

  static String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  // ── FAYLNI OCHISH ──────────────────────────────────────
  static Future<void> openFile(String path) async {
    await OpenFile.open(path);
  }
}