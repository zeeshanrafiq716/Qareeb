/// Provider Quick Stats Model
class ProviderQuickStatsModel {
  final int viewsToday;
  final int contactsToday;

  const ProviderQuickStatsModel({
    this.viewsToday = 32,
    this.contactsToday = 19,
  });

  factory ProviderQuickStatsModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] is Map<String, dynamic>
        ? json['stats'] as Map<String, dynamic>
        : (json['data'] is Map<String, dynamic>
            ? (json['data']['stats'] is Map<String, dynamic>
                ? json['data']['stats'] as Map<String, dynamic>
                : json['data'] as Map<String, dynamic>)
            : json);

    return ProviderQuickStatsModel(
      viewsToday: (stats['viewsToday'] as num?)?.toInt() ?? 32,
      contactsToday: (stats['contactsToday'] as num?)?.toInt() ?? 19,
    );
  }

  Map<String, dynamic> toJson() => {
        'viewsToday': viewsToday,
        'contactsToday': contactsToday,
      };

  static const ProviderQuickStatsModel defaults = ProviderQuickStatsModel();
}

/// Provider Views Card Analytics
class ProviderViewsCardData {
  final List<int> counts;
  final List<String> trends;
  final List<int> barValues;

  const ProviderViewsCardData({
    this.counts = const [24, 21, 184, 268, 345],
    this.trends = const ['+12%', '+5%', '+18%', '+22%', '+15%'],
    this.barValues = const [1, 3, 4, 7, 4, 2, 3],
  });

  factory ProviderViewsCardData.fromJson(Map<String, dynamic> json) {
    List<int> parseCounts(dynamic list) {
      if (list is List) {
        return list.map((e) => (e as num).toInt()).toList();
      }
      return const [24, 21, 184, 268, 345];
    }

    List<String> parseStrings(dynamic list) {
      if (list is List) {
        return list.map((e) => e.toString()).toList();
      }
      return const ['+12%', '+5%', '+18%', '+22%', '+15%'];
    }

    return ProviderViewsCardData(
      counts: parseCounts(json['counts']),
      trends: parseStrings(json['trends']),
      barValues: parseCounts(json['barValues']),
    );
  }

  static const ProviderViewsCardData defaults = ProviderViewsCardData();
}

/// Provider Contacts Received Analytics
class ProviderContactsCardData {
  final List<int> counts;
  final List<int> callsCounts;
  final List<int> whatsAppCounts;
  final List<String> trends;
  final List<int> barValues;

  const ProviderContactsCardData({
    this.counts = const [19, 14, 128, 195, 260],
    this.callsCounts = const [11, 8, 74, 112, 150],
    this.whatsAppCounts = const [8, 6, 54, 83, 110],
    this.trends = const ['+33%', '+10%', '+25%', '+18%', '+20%'],
    this.barValues = const [2, 3, 4, 3, 4, 1, 2],
  });

  factory ProviderContactsCardData.fromJson(Map<String, dynamic> json) {
    List<int> parseCounts(dynamic list, List<int> fallback) {
      if (list is List && list.isNotEmpty) {
        return list.map((e) => (e as num).toInt()).toList();
      }
      return fallback;
    }

    List<String> parseStrings(dynamic list) {
      if (list is List && list.isNotEmpty) {
        return list.map((e) => e.toString()).toList();
      }
      return const ['+33%', '+10%', '+25%', '+18%', '+20%'];
    }

    return ProviderContactsCardData(
      counts: parseCounts(json['counts'], const [19, 14, 128, 195, 260]),
      callsCounts: parseCounts(json['callsCounts'], const [11, 8, 74, 112, 150]),
      whatsAppCounts: parseCounts(json['whatsAppCounts'], const [8, 6, 54, 83, 110]),
      trends: parseStrings(json['trends']),
      barValues: parseCounts(json['barValues'], const [2, 3, 4, 3, 4, 1, 2]),
    );
  }

  static const ProviderContactsCardData defaults = ProviderContactsCardData();
}

/// Complete Provider Dashboard Analytics Model
class ProviderDashboardModel {
  final String? providerId;
  final ProviderQuickStatsModel stats;
  final ProviderViewsCardData viewsCard;
  final ProviderContactsCardData contactsCard;

  const ProviderDashboardModel({
    this.providerId,
    this.stats = ProviderQuickStatsModel.defaults,
    this.viewsCard = ProviderViewsCardData.defaults,
    this.contactsCard = ProviderContactsCardData.defaults,
  });

  factory ProviderDashboardModel.fromJson(Map<String, dynamic> rawJson) {
    final json = rawJson['data'] is Map<String, dynamic>
        ? rawJson['data'] as Map<String, dynamic>
        : rawJson;

    return ProviderDashboardModel(
      providerId: json['providerId']?.toString(),
      stats: json['stats'] is Map<String, dynamic>
          ? ProviderQuickStatsModel.fromJson(json['stats'] as Map<String, dynamic>)
          : ProviderQuickStatsModel.defaults,
      viewsCard: json['viewsCard'] is Map<String, dynamic>
          ? ProviderViewsCardData.fromJson(json['viewsCard'] as Map<String, dynamic>)
          : ProviderViewsCardData.defaults,
      contactsCard: json['contactsCard'] is Map<String, dynamic>
          ? ProviderContactsCardData.fromJson(json['contactsCard'] as Map<String, dynamic>)
          : ProviderContactsCardData.defaults,
    );
  }

  static const ProviderDashboardModel defaults = ProviderDashboardModel();
}
