import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/contact_model.dart';
import '../../services/contact_service.dart';
import '../subscription/buy_subscription_page.dart';
import 'add_contact_page.dart';

enum ContactAction {
  buy,
  copy,
  share,
  delete,
}

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final ContactService _contactService = ContactService();

  final TextEditingController _searchController =
      TextEditingController();

  String _search = "";

  bool _selectionMode = false;

  bool _deleting = false;

  final Set<String> _selectedIds = <String>{};

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (!mounted) return;

    setState(() {
      _search = _searchController.text
          .trim()
          .toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(
      _onSearchChanged,
    );

    _searchController.dispose();

    super.dispose();
  }

  // ----------------------------------------------------------
  // COPIER L'ID
  // ----------------------------------------------------------

  Future<void> _copyId(
    String id,
  ) async {
    await Clipboard.setData(
      ClipboardData(text: id),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "ID copié dans le presse-papiers.",
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // PARTAGER L'ID
  // ----------------------------------------------------------

  Future<void> _shareId(
    String id,
    String contactName,
  ) async {
    await Share.share(
      "Voici l'ID WiFi Mouni de "
      "$contactName : $id",
      subject: "Contact WiFi Mouni",
    );
  }

  // ----------------------------------------------------------
  // OUVRIR LA PAGE D'AJOUT
  // ----------------------------------------------------------

  Future<void> _openAddContactPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddContactPage(),
      ),
    );

    if (!mounted) return;

    // Le StreamBuilder de la page se mettra
    // automatiquement à jour.
    setState(() {});
  }

  // ----------------------------------------------------------
  // ACHETER UN ABONNEMENT POUR LE CONTACT
  // ----------------------------------------------------------

  Future<void> _buyForContact(
    ContactModel contact,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BuySubscriptionPage(
          initialReceiverId: contact.userId,
        ),
      ),
    );
  }
      // ----------------------------------------------------------
  // MODE SÉLECTION
  // ----------------------------------------------------------

  void _startSelection(
    ContactModel contact,
  ) {
    if (_deleting) return;

    setState(() {
      _selectionMode = true;
      _selectedIds.add(contact.id);
    });
  }

  void _toggleSelection(
    ContactModel contact,
  ) {
    if (_deleting) return;

    setState(() {
      if (_selectedIds.contains(contact.id)) {
        _selectedIds.remove(contact.id);
      } else {
        _selectedIds.add(contact.id);
      }

      if (_selectedIds.isEmpty) {
        _selectionMode = false;
      }
    });
  }

  void _changeCheckbox(
    ContactModel contact,
    bool? value,
  ) {
    if (_deleting) return;

    setState(() {
      if (value == true) {
        _selectedIds.add(contact.id);
        _selectionMode = true;
      } else {
        _selectedIds.remove(contact.id);
      }

      if (_selectedIds.isEmpty) {
        _selectionMode = false;
      }
    });
  }

  void _cancelSelection() {
    if (_deleting) return;

    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  // ----------------------------------------------------------
  // SUPPRIMER LES CONTACTS SÉLECTIONNÉS
  // ----------------------------------------------------------

  Future<void> _deleteSelected() async {
    if (_deleting || _selectedIds.isEmpty) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Supprimer les contacts ?",
          ),
          content: Text(
            "Voulez-vous supprimer "
            "${_selectedIds.length} contact(s) ?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                "Supprimer",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _deleting = true;
    });

    try {
      final ids = List<String>.from(
        _selectedIds,
      );

      for (final id in ids) {
        await _contactService.deleteContact(id);
      }

      if (!mounted) return;

      setState(() {
        _selectedIds.clear();
        _selectionMode = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Contacts supprimés.",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              "Exception: ",
              "",
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _deleting = false;
        });
      }
    }
  }

  // ----------------------------------------------------------
  // SUPPRIMER TOUS LES CONTACTS
  // ----------------------------------------------------------

  Future<void> _deleteAllContacts() async {
    if (_deleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Supprimer tous les contacts ?",
          ),
          content: const Text(
            "Cette action supprimera tous vos contacts. "
            "Elle est irréversible.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                "Tout supprimer",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _deleting = true;
    });

    try {
      await _contactService.deleteAllContacts();

      if (!mounted) return;

      setState(() {
        _selectedIds.clear();
        _selectionMode = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Tous les contacts ont été supprimés.",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              "Exception: ",
              "",
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _deleting = false;
        });
      }
    }
  }
      // ----------------------------------------------------------
  // ACTION DU MENU CONTACT
  // ----------------------------------------------------------

  Future<void> _handleContactAction(
    ContactAction action,
    ContactModel contact,
  ) async {
    switch (action) {
      case ContactAction.buy:
        await _buyForContact(contact);
        break;

      case ContactAction.copy:
        await _copyId(contact.userId);
        break;

      case ContactAction.share:
        await _shareId(
          contact.userId,
          contact.nom,
        );
        break;

      case ContactAction.delete:
        if (_deleting) return;

        try {
          setState(() {
            _deleting = true;
          });

          await _contactService.deleteContact(
            contact.id,
          );

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Contact supprimé.",
              ),
            ),
          );
        } catch (e) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.toString().replaceFirst(
                  "Exception: ",
                  "",
                ),
              ),
            ),
          );
        } finally {
          if (mounted) {
            setState(() {
              _deleting = false;
            });
          }
        }

        break;
    }
  }

  // ----------------------------------------------------------
  // AVATAR
  // ----------------------------------------------------------

  Widget _buildAvatar(
    ContactModel contact,
  ) {
    final name = contact.nom.trim();

    return CircleAvatar(
      radius: 27,
      child: Text(
        name.isNotEmpty
            ? name[0].toUpperCase()
            : "?",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // MENU TROIS POINTS
  // ----------------------------------------------------------

  Widget _buildPopupMenu(
    ContactModel contact,
  ) {
    return PopupMenuButton<ContactAction>(
      enabled: !_deleting,
      onSelected: (action) {
        _handleContactAction(
          action,
          contact,
        );
      },
      itemBuilder: (context) {
        return const [
          PopupMenuItem<ContactAction>(
            value: ContactAction.buy,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.wifi,
              ),
              title: Text(
                "Acheter un abonnement",
              ),
            ),
          ),

          PopupMenuItem<ContactAction>(
            value: ContactAction.copy,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.copy,
              ),
              title: Text(
                "Copier l'ID",
              ),
            ),
          ),

          PopupMenuItem<ContactAction>(
            value: ContactAction.share,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.share,
              ),
              title: Text(
                "Partager l'ID",
              ),
            ),
          ),

          PopupMenuDivider(),

          PopupMenuItem<ContactAction>(
            value: ContactAction.delete,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.delete,
                color: Colors.red,
              ),
              title: Text(
                "Supprimer",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ];
      },
    );
  }

  // ----------------------------------------------------------
  // CARTE CONTACT
  // ----------------------------------------------------------

  Widget _buildContactCard(
    ContactModel contact,
  ) {
    final selected =
        _selectedIds.contains(contact.id);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: ListTile(
        onLongPress: () {
          _startSelection(contact);
        },
        onTap: () {
          if (_selectionMode) {
            _toggleSelection(contact);
          } else {
            _buyForContact(contact);
          }
        },
        leading: _selectionMode
            ? Checkbox(
                value: selected,
                onChanged: (value) {
                  _changeCheckbox(
                    contact,
                    value,
                  );
                },
              )
            : _buildAvatar(contact),

        title: Text(
          contact.nom,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(
            top: 4,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                "ID : ${contact.userId}",
              ),

              if (contact.telephone
                  .trim()
                  .isNotEmpty)
                Text(
                  "Téléphone : "
                  "${contact.telephone}",
                ),
            ],
          ),
        ),

        trailing: _selectionMode
            ? null
            : _buildPopupMenu(contact),
      ),
    );
  }

  // ----------------------------------------------------------
  // FILTRAGE DES CONTACTS
  // ----------------------------------------------------------

  List<ContactModel> _filterContacts(
    List<ContactModel> contacts,
  ) {
    if (_search.isEmpty) {
      return contacts;
    }

    return contacts.where((contact) {
      final name =
          contact.nom.toLowerCase();

      final id =
          contact.userId.toLowerCase();

      final phone =
          contact.telephone.toLowerCase();

      return name.contains(_search) ||
          id.contains(_search) ||
          phone.contains(_search);
    }).toList();
  }
      // ----------------------------------------------------------
  // INTERFACE
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

        leading: _selectionMode
            ? IconButton(
                icon: const Icon(
                  Icons.close,
                ),
                onPressed: _deleting
                    ? null
                    : _cancelSelection,
              )
            : null,

        title: _selectionMode
            ? Text(
                "${_selectedIds.length} sélectionné(s)",
              )
            : const Text("Contacts"),

        actions: [
          if (_selectionMode) ...[
            IconButton(
              tooltip: "Supprimer",
              icon: const Icon(
                Icons.delete,
              ),
              onPressed: _deleting ||
                      _selectedIds.isEmpty
                  ? null
                  : _deleteSelected,
            ),
          ] else ...[
            IconButton(
              tooltip: "Supprimer tout",
              icon: const Icon(
                Icons.delete_sweep,
              ),
              onPressed: _deleting
                  ? null
                  : _deleteAllContacts,
            ),

            IconButton(
              tooltip: "Ajouter un contact",
              icon: const Icon(
                Icons.person_add,
              ),
              onPressed: _deleting
                  ? null
                  : _openAddContactPage,
            ),
          ],
        ],
      ),

      floatingActionButton:
          _selectionMode
              ? null
              : FloatingActionButton(
                  tooltip:
                      "Ajouter un contact",
                  onPressed: _deleting
                      ? null
                      : _openAddContactPage,
                  child: const Icon(
                    Icons.person_add,
                  ),
                ),

      body: Column(
        children: [
          // --------------------------------------------------
          // RECHERCHE
          // --------------------------------------------------

          Padding(
            padding:
                const EdgeInsets.all(16),
            child: TextField(
              controller:
                  _searchController,
              textInputAction:
                  TextInputAction.search,
              decoration:
                  InputDecoration(
                hintText:
                    "Rechercher un contact...",
                prefixIcon:
                    const Icon(
                  Icons.search,
                ),
                suffixIcon:
                    _search.isEmpty
                        ? null
                        : IconButton(
                            icon:
                                const Icon(
                              Icons.clear,
                            ),
                            onPressed:
                                () {
                              _searchController
                                  .clear();
                            },
                          ),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),
            ),
          ),

          // --------------------------------------------------
          // LISTE
          // --------------------------------------------------

          Expanded(
            child: StreamBuilder<
                List<ContactModel>>(
              stream:
                  _contactService
                      .getContacts(),

              builder:
                  (context, snapshot) {
                if (snapshot
                        .connectionState ==
                    ConnectionState
                        .waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        20,
                      ),
                      child: Text(
                        "Impossible de charger "
                        "les contacts.\n\n"
                        "${snapshot.error}",
                        textAlign:
                            TextAlign.center,
                      ),
                    ),
                  );
                }

                final contacts =
                    snapshot.data ?? [];

                final filteredContacts =
                    _filterContacts(
                  contacts,
                );

                if (contacts.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding:
                          EdgeInsets.all(
                        20,
                      ),
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 70,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            "Aucun contact.",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            "Ajoutez un contact "
                            "avec son ID WiFi Mouni.",
                            textAlign:
                                TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (filteredContacts
                    .isEmpty) {
                  return const Center(
                    child: Text(
                      "Aucun contact trouvé.",
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    // Les données sont déjà
                    // synchronisées en temps réel
                    // par Firestore.
                    await Future<void>.delayed(
                      const Duration(
                        milliseconds: 300,
                      ),
                    );
                  },
                  child: ListView.builder(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.only(
                      bottom: 90,
                    ),
                    itemCount:
                        filteredContacts
                            .length,
                    itemBuilder:
                        (context, index) {
                      final contact =
                          filteredContacts[
                              index];

                      return _buildContactCard(
                        contact,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}