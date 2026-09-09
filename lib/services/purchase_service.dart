import 'package:cloud_functions/cloud_functions.dart';

class PurchaseService {
  final FirebaseFunctions _functions =
      FirebaseFunctions.instance;

  /// Demande au serveur d'effectuer l'achat
  /// d'un abonnement.
  ///
  /// Le prix et la durée sont vérifiés côté serveur
  /// depuis Firestore.
  ///
  /// beneficiaryUid == null :
  /// achat pour l'utilisateur connecté.
  ///
  /// beneficiaryUid != null :
  /// achat pour un autre utilisateur.
  Future<String?> buySubscription({
    required String subscriptionId,
    required String subscriptionName,
    required int price,
    required int duration,
    String? beneficiaryUid,
  }) async {
    try {
      final callable =
          _functions.httpsCallable(
        'buySubscription',
      );

      final result =
          await callable.call({
        'subscriptionId': subscriptionId,
        'beneficiaryUid': beneficiaryUid,
      });

      if (result.data == null) {
        return "Réponse du serveur invalide.";
      }

      final data =
          Map<String, dynamic>.from(
        result.data as Map,
      );

      if (data['success'] == true) {
        return null;
      }

      return data['message']?.toString() ??
          "Impossible de terminer l'achat.";
    } on FirebaseFunctionsException catch (e) {
      switch (e.code) {
        case 'unauthenticated':
          return "Utilisateur non connecté.";

        case 'permission-denied':
          return e.message ??
              "Accès refusé.";

        case 'not-found':
          return e.message ??
              "Informations introuvables.";

        case 'failed-precondition':
          return e.message ??
              "L'achat ne peut pas être effectué.";

        case 'invalid-argument':
          return e.message ??
              "Données d'achat invalides.";

        default:
          return e.message ??
              "Une erreur serveur est survenue.";
      }
    } catch (e) {
      return "Impossible de contacter le serveur.";
    }
  }
}