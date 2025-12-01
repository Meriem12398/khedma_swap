import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_offer.dart';

class ApiService {
  /// ⚠️ HNE T7OT URL MTA3 MOCKI:
  /// Exemple: 'https://mocki.io/v1/XXXXXXXX'
  static const String baseUrl = 'https://mocki.io/v1/8da47e46-4d3c-4585-b695-c78fb21da408';

  /// GET: jلب kol l'offres
  static Future<List<ServiceOffer>> fetchOffers() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ServiceOffer.fromJson(e)).toList();
    } else {
      throw Exception(
        'Erreur de chargement des offres (${response.statusCode})',
      );
    }
  }

  /// POST: ajout offre jdida (ken mocki ykhalih)
  static Future<ServiceOffer> createOffer(ServiceOffer offer) async {
    final body = offer.toJson()..remove('id');

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ServiceOffer.fromJson(data);
    } else {
      throw Exception(
        'Erreur lors de l\'ajout (${response.statusCode})',
      );
    }
  }

  /// PUT: modification offre
  static Future<ServiceOffer> updateOffer(ServiceOffer offer) async {
    final url = '$baseUrl/${offer.id}';

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(offer.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ServiceOffer.fromJson(data);
    } else {
      throw Exception(
        'Erreur lors de la modification (${response.statusCode})',
      );
    }
  }

  /// DELETE: tn7i offre
  static Future<void> deleteOffer(int id) async {
    final url = '$baseUrl/$id';

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Erreur lors de la suppression (${response.statusCode})',
      );
    }
  }
}
