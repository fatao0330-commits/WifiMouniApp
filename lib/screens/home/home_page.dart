import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/user_model.dart';
import '../../services/user_service.dart';

// ============================================================
// PAGES
// ============================================================

import '../contact/contact_page.dart';
import '../history/history_page.dart';
import '../profile/profile_page.dart';
import '../qr/my_qr_page.dart';
import '../qr/scanner_qr_page.dart';
import '../subscription/buy_subscription_page.dart';
import '../wallet/recharge_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UserService _userService = UserService();

  int _selectedIndex = 0;

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),

      appBar: AppBar(
        backgroundColor: const Color(0xFF101010),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "WiFi Mouni",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: "Notifications",
            icon: const Icon(
              Icons.notifications_none,
            ),
            onPressed: () {
              _showComingSoon(
                "Les notifications seront disponibles prochainement.",
              );
            },
          ),
        ],
      ),

      body: _selectedIndex == 0
          ? _buildHomeContent()
          : _buildSelectedPage(),

      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF1B1B1B),
        indicatorColor: Colors.blue.withOpacity(0.20),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Accueil",
          ),
          NavigationDestination(
            icon: Icon(Icons.contacts_outlined),
            selectedIcon: Icon(Icons.contacts),
            label: "Contacts",
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: "Historique",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Profil",
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE ACCUEIL
  // ============================================================

  Widget _buildHomeContent() {
    return StreamBuilder<UserModel>(
      stream: _userService.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "Erreur de chargement :\n${snapshot.error}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: Text(
              "Aucune donnée utilisateur.",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          );
        }

        final user = snapshot.data!;

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  "Bonjour ${user.nom} 👋",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "ID : ${user.userId}",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    IconButton(
                      tooltip: "Copier l'ID",
                      icon: const Icon(
                        Icons.copy,
                        size: 18,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        _copyUserId(user.userId);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                _buildBalanceCard(user),

                const SizedBox(height: 20),

                _buildSubscriptionCard(user),

                const SizedBox(height: 25),

                const Text(
                  "Actions rapides",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                GridView.count(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.4,
                  children: [
                    // ==================================================
                    // RECHARGER
                    // ==================================================

                    _buildActionCard(
                      icon:
                          Icons.account_balance_wallet,
                      title: "Recharger",
                      color: Colors.green,
                      onTap: _openRechargePage,
                    ),

                    // ==================================================
                    // ABONNEMENT
                    // ==================================================

                    _buildActionCard(
                      icon: Icons.wifi,
                      title: "Acheter\nabonnement",
                      color: Colors.blue,
                      onTap:
                          _openBuySubscriptionPage,
                    ),

                    // ==================================================
                    // MON QR
                    // ==================================================

                    _buildActionCard(
                      icon: Icons.qr_code,
                      title: "Mon QR Code",
                      color: Colors.orange,
                      onTap: _openMyQrPage,
                    ),

                    // ==================================================
                    // SCANNER
                    // ==================================================

                    _buildActionCard(
                      icon:
                          Icons.qr_code_scanner,
                      title: "Scanner QR",
                      color: Colors.purple,
                      onTap: _openScannerQrPage,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  "Dernières activités",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                _buildActivitiesCard(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // SOLDE
  // ============================================================

  Widget _buildBalanceCard(UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            "Solde disponible",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            "${user.solde} FCFA",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ABONNEMENT
  // ============================================================

  Widget _buildSubscriptionCard(UserModel user) {
    final bool active =
        user.statut.toLowerCase() == "actif" &&
        user.joursRestants > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.wifi,
                color: Colors.blue,
              ),
              SizedBox(width: 10),
              Text(
                "Abonnement",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            user.nomAbonnement.isEmpty
                ? "Aucun abonnement actif"
                : user.nomAbonnement,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 15),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: active
                  ? Colors.green.withOpacity(0.20)
                  : Colors.red.withOpacity(0.20),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  active
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: active
                      ? Colors.green
                      : Colors.red,
                ),

                const SizedBox(width: 10),

                Text(
                  active
                      ? "Internet actif"
                      : "Internet expiré",
                  style: TextStyle(
                    color: active
                        ? Colors.green
                        : Colors.red,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Jours restants",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              Text(
                "${user.joursRestants} jour(s)",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARTE ACTION
  // ============================================================

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1B1B),
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white10,
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),

            const SizedBox(height: 10),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ACTIVITÉS
  // ============================================================

  Widget _buildActivitiesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.history,
            color: Colors.grey,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Vos dernières opérations apparaîtront ici.",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NAVIGATION DES ONGLETS
  // ============================================================

  Widget _buildSelectedPage() {
    switch (_selectedIndex) {
      case 1:
        return const ContactPage();

      case 2:
        return const HistoryPage();

      case 3:
        return const ProfilePage();

      default:
        return _buildHomeContent();
    }
  }

  // ============================================================
  // RECHARGE
  // ============================================================

  void _openRechargePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RechargePage(),
      ),
    );
  }

  // ============================================================
  // MON QR CODE
  // ============================================================

  void _openMyQrPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MyQrPage(),
      ),
    );
  }

  // ============================================================
  // SCANNER QR
  // ============================================================

  void _openScannerQrPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ScannerQrPage(),
      ),
    );
  }

  // ============================================================
  // ACHETER ABONNEMENT
  // ============================================================

  void _openBuySubscriptionPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const BuySubscriptionPage(),
      ),
    );
  }

  // ============================================================
  // COPIER ID
  // ============================================================

  void _copyUserId(String userId) {
    Clipboard.setData(
      ClipboardData(text: userId),
    );

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content:
            Text("ID copié dans le presse-papiers."),
      ),
    );
  }

  // ============================================================
  // MESSAGE TEMPORAIRE
  // ============================================================

  void _showComingSoon(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}