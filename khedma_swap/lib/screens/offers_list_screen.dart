import 'package:flutter/material.dart';
import '../models/service_offer.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'offer_detail_screen.dart';
import 'matches_screen.dart';

class OffersListScreen extends StatefulWidget {
  const OffersListScreen({super.key});

  @override
  State<OffersListScreen> createState() => _OffersListScreenState();
}

class _OffersListScreenState extends State<OffersListScreen> {
  List<ServiceOffer> _offers = [];
  bool _isLoading = false;
  String? _error;
  String _search = '';

  List<ServiceOffer> get _filteredOffers {
    if (_search.isEmpty) return _offers;
    final q = _search.toLowerCase();
    return _offers.where((o) {
      return o.title.toLowerCase().contains(q) ||
          o.city.toLowerCase().contains(q) ||
          o.offersSkill.toLowerCase().contains(q) ||
          o.needsSkill.toLowerCase().contains(q) ||
          o.offeredBy.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await ApiService.fetchOffers();
      setState(() {
        _offers = list;
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

  Future<void> _openAddDialog() async {
    final newOffer = await showDialog<ServiceOffer>(
      context: context,
      builder: (context) => const OfferFormDialog(),
    );

    if (newOffer != null) {
      try {
        // essayer d'envoyer à l'API
        final created = await ApiService.createOffer(newOffer);
        setState(() {
          _offers.add(created);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offre ajoutée avec succès 🎉')),
        );
      } catch (e) {
        // si l’API ne supporte pas POST, on peut au moins l’ajouter localement
        setState(() {
          _offers.add(newOffer);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Offre ajoutée localement (API non disponible) : $e',
            ),
          ),
        );
      }
    }
  }

  Future<void> _openEditDialog(ServiceOffer offer) async {
    final updated = await showDialog<ServiceOffer>(
      context: context,
      builder: (context) => OfferFormDialog(initialOffer: offer),
    );

    if (updated != null) {
      try {
        final updatedFromApi = await ApiService.updateOffer(updated);
        setState(() {
          final index = _offers.indexWhere((o) => o.id == updatedFromApi.id);
          if (index != -1) {
            _offers[index] = updatedFromApi;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offre modifiée ✔️')),
        );
      } catch (e) {
        // fallback local
        setState(() {
          final index = _offers.indexWhere((o) => o.id == updated.id);
          if (index != -1) {
            _offers[index] = updated;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Offre modifiée localement (API non disponible) : $e',
            ),
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(ServiceOffer offer) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'offre ?'),
        content: Text('Voulez-vous supprimer "${offer.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await ApiService.deleteOffer(offer.id);
        setState(() {
          _offers.removeWhere((o) => o.id == offer.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offre supprimée 🗑️')),
        );
      } catch (e) {
        // fallback local
        setState(() {
          _offers.removeWhere((o) => o.id == offer.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Offre supprimée localement (API non disponible) : $e',
            ),
          ),
        );
      }
    }
  }

  void _onOfferLongPress(ServiceOffer offer) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Modifier'),
              onTap: () {
                Navigator.of(context).pop();
                _openEditDialog(offer);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Supprimer'),
              onTap: () {
                Navigator.of(context).pop();
                _confirmDelete(offer);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    AuthService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final offers = _filteredOffers;
    final user = AuthService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('KhedmaSwap - Catalogue'),
        actions: [
          IconButton(
            tooltip: 'Khedma Match',
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MatchesScreen(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Déconnexion',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 12, bottom: 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Bonjour, ${user.name} 👋',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Recherche par skill, ville, nom...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Text(
                          'Erreur: $_error',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : offers.isEmpty
                        ? const Center(
                            child: Text(
                              'Pas d\'offres pour le moment.',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadOffers,
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: offers.length,
                              itemBuilder: (context, index) {
                                final offer = offers[index];
                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      child: Text(
                                        offer.offeredBy.isNotEmpty
                                            ? offer.offeredBy[0].toUpperCase()
                                            : '?',
                                      ),
                                    ),
                                    title: Text(offer.title),
                                    subtitle: Text(
                                      '${offer.offersSkill} → cherche ${offer.needsSkill}\n'
                                      '${offer.offeredBy} - ${offer.city}',
                                    ),
                                    isThreeLine: true,
                                    trailing:
                                        const Icon(Icons.chevron_right),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              OfferDetailScreen(offer: offer),
                                        ),
                                      );
                                    },
                                    onLongPress: () =>
                                        _onOfferLongPress(offer),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class OfferFormDialog extends StatefulWidget {
  final ServiceOffer? initialOffer;

  const OfferFormDialog({super.key, this.initialOffer});

  @override
  State<OfferFormDialog> createState() => _OfferFormDialogState();
}

class _OfferFormDialogState extends State<OfferFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _cityController = TextEditingController();
  final _offeredByController = TextEditingController();
  final _offersSkillController = TextEditingController();
  final _needsSkillController = TextEditingController();

  bool get _isEdit => widget.initialOffer != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final o = widget.initialOffer!;
      _titleController.text = o.title;
      _descController.text = o.description;
      _cityController.text = o.city;
      _offeredByController.text = o.offeredBy;
      _offersSkillController.text = o.offersSkill;
      _needsSkillController.text = o.needsSkill;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _cityController.dispose();
    _offeredByController.dispose();
    _offersSkillController.dispose();
    _needsSkillController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final id = _isEdit ? widget.initialOffer!.id : 0; // 0: API y7ot id

    final offer = ServiceOffer(
      id: id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      city: _cityController.text.trim(),
      offeredBy: _offeredByController.text.trim(),
      offersSkill: _offersSkillController.text.trim(),
      needsSkill: _needsSkillController.text.trim(),
    );

    Navigator.of(context).pop(offer);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? 'Modifier l\'offre' : 'Nouvelle offre'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Titre obligatoire' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _offeredByController,
                decoration:
                    const InputDecoration(labelText: 'Offert par (nom)'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nom obligatoire' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'Ville'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Ville obligatoire' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _offersSkillController,
                decoration:
                    const InputDecoration(labelText: 'Compétence offerte'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Obligatoire' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _needsSkillController,
                decoration:
                    const InputDecoration(labelText: 'Compétence recherchée'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Obligatoire' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(_isEdit ? 'Enregistrer' : 'Ajouter'),
        ),
      ],
    );
  }
}
