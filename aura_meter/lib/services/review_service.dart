import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Requests an in-app store review at a high-satisfaction moment (a rare pull),
/// while respecting sensible limits so users are never spammed.
class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final InAppReview _inAppReview = InAppReview.instance;

  /// Ask for a review after a delightful event. Only fires once the user has
  /// scanned enough to be invested, and at most once every ~30 days.
  Future<void> maybeRequestReview({required int totalScans}) async {
    if (totalScans < 5) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastMs = prefs.getInt('lastReviewRequestMs') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      const thirtyDaysMs = 30 * 24 * 60 * 60 * 1000;
      if (now - lastMs < thirtyDaysMs) return;

      if (await _inAppReview.isAvailable()) {
        await prefs.setInt('lastReviewRequestMs', now);
        await _inAppReview.requestReview();
      }
    } catch (e) {
      debugPrint('Review request failed: $e');
    }
  }
}
