import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';

enum FeedbackKind { bug, suggestion, complaint, other }

extension FeedbackKindLabel on FeedbackKind {
  String get apiValue => name;
  String get label => switch (this) {
        FeedbackKind.bug => 'Hata bildirimi',
        FeedbackKind.suggestion => 'Öneri',
        FeedbackKind.complaint => 'Şikayet',
        FeedbackKind.other => 'Diğer',
      };
}

final feedbackSubmitProvider = Provider((ref) {
  return FeedbackSubmitter(ref.read(apiClientProvider));
});

class FeedbackSubmitter {
  final ApiClient _api;
  FeedbackSubmitter(this._api);

  Future<void> submit({
    required FeedbackKind kind,
    required String subject,
    required String message,
  }) async {
    await _api.dio.post('/feedback', data: {
      'kind': kind.apiValue,
      'subject': subject,
      'message': message,
    });
  }
}
