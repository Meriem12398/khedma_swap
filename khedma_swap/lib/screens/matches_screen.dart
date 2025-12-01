import 'package:flutter/material.dart';
import '../models/service_offer.dart';
import '../services/api_service.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  bool _isLoading = false;
  String? _error;
  List<ServiceOffer> _offers = [];
  List<_OfferMatch> _matches = [];

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final offers = await ApiService.fetchOffers();
      final matches = _findMatches(offers);

      setState(() {
        _offers = offers;
        _matches = matches;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<_OfferMatch> _findMatches(List<ServiceOffer> offers) {
    final List<_OfferMatch> result = [];

    for (int i = 0; i < offers.length; i++) {
      for (int j = i + 1; j < offers.length; j++) {
        final a = offers[i];
        final b = offers[j];

        final bool skillSwap =
            a.offersSkill.toLowerCase() == b.needsSkill.toLowerCase() &&
            a.needsSkill.toLowerCase() == b.offersSkill.toLowerCase();

        if (skillSwap) {
          result.add(_OfferMatch(a: a, b: b));
        }
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Khedma Match'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    'Erreur: $_error',
                    textAlign: TextAlign.center,
                  ),
                )
              : _matches.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucun match trouvé pour le moment.\nAjoutez plus d\'offres pour voir des KhedmaSwap 😉',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadMatches,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _matches.length,
                        itemBuilder: (context, index) {
                          final m = _matches[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.swap_horiz),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${m.a.offeredBy} ⇄ ${m.b.offeredBy}',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${m.a.offersSkill} ⇄ ${m.a.needsSkill}',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${m.a.city} / ${m.b.city}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  const Divider(height: 16),
                                  Text(
                                    'Offre 1 : ${m.a.title}',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  Text(
                                    'Offre 2 : ${m.b.title}',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _OfferMatch {
  final ServiceOffer a;
  final ServiceOffer b;

  _OfferMatch({required this.a, required this.b});
}
