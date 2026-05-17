import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CsvExportService {
  const CsvExportService();

  Future<String> writeReportCsv({
    required String csv,
    required DateTime month,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/fisly-${month.year}-${month.month.toString().padLeft(2, '0')}.csv',
    );
    await file.writeAsString(csv, flush: true);
    return file.path;
  }

  Future<void> shareReportCsv({
    required String csv,
    required DateTime month,
    bool isTurkish = false,
  }) async {
    final path = await writeReportCsv(csv: csv, month: month);
    final filename =
        'fisly-${month.year}-${month.month.toString().padLeft(2, '0')}.csv';
    await SharePlus.instance.share(
      ShareParams(
        title: isTurkish ? 'Fişly CSV Dışa Aktarım' : 'Fisly CSV Export',
        subject: filename,
        text: isTurkish
            ? 'Fişly aylık harcama raporu'
            : 'Fisly monthly expense report',
        files: [XFile(path, mimeType: 'text/csv', name: filename)],
        fileNameOverrides: [filename],
      ),
    );
  }
}
