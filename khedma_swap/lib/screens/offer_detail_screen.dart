import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/service_offer.dart';

class OfferDetailScreen extends StatelessWidget {
  final ServiceOffer offer;

  const OfferDetailScreen({super.key, required this.offer});

  Future<void> _openInMaps(BuildContext context) async {
    // na3mlou query: titre + ville + Tunisie
    final query = Uri.encodeComponent('${offer.title}, ${offer.city}, Tunisie');

    // URL officielle mta3 Google Maps search
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // y7ell Google Maps / navigateur
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir la carte.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(offer.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person_outline),
                      const SizedBox(width: 8),
                      Text(
                        offer.offeredBy,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      const Icon(Icons.location_on_outlined),
                      const SizedBox(width: 4),
                      Text(
                        offer.city,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.check),
                        label: Text('Offre : ${offer.offersSkill}'),
                      ),
                      Chip(
                        avatar: const Icon(Icons.search),
                        label: Text('Recherche : ${offer.needsSkill}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    offer.description.isEmpty
                        ? 'Pas de description fournie.'
                        : offer.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // 👇 bouton géolocalisation (ouvrir dans Google Maps)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openInMaps(context),
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Voir sur la carte'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
