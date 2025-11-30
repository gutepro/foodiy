abstract class TranslationService {
  Future<String> translateText({
    required String text,
    required String fromLanguageCode,
    required String toLanguageCode,
  });
}

class FakeTranslationService implements TranslationService {
  @override
  Future<String> translateText({
    required String text,
    required String fromLanguageCode,
    required String toLanguageCode,
  }) async {
    // TODO: Replace with real backend translation call (Cloud Function).
    return text;
  }
}

class TranslationServiceProvider {
  static final TranslationService instance = FakeTranslationService();
}
