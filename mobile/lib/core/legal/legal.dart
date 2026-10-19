import 'package:url_launcher/url_launcher.dart';

/// Hukuki doküman URL'leri. Bu adreslerde yayınlanan metinler:
/// docs/legal/gizlilik_politikasi.md ve docs/legal/kvkk_aydinlatma_metni.md
const String kPrivacyUrl = 'https://fisly.app/privacy';
const String kKvkkUrl = 'https://fisly.app/kvkk';

Future<void> openLegalUrl(String url) async {
  final uri = Uri.parse(url);
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
