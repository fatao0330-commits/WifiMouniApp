const {
  onCall,
  HttpsError,
} = require("firebase-functions/v2/https");

const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {defineSecret, defineString} = require("firebase-functions/params");

const admin = require("firebase-admin");
const crypto = require("crypto");

admin.initializeApp();

const db = admin.firestore();

/*
|--------------------------------------------------------------------------
| CONFIGURATION INFOBIP
|--------------------------------------------------------------------------
*/

const infobipApiKey = defineSecret("INFOBIP_API_KEY");
const infobipAppId = defineSecret("INFOBIP_APPLICATION_ID");
const infobipMsgId = defineSecret("INFOBIP_MESSAGE_ID");
const infobipSender = defineSecret("INFOBIP_SENDER");
const yengaPayApiKey = defineSecret("YENGAPAY_API_KEY");
const yengaPayOrganizationId = defineString("YENGAPAY_ORGANIZATION_ID", {
  default: "10905060",
});
const yengaPayEnvironment = defineString("YENGAPAY_ENVIRONMENT", {
  default: "sandbox",
});

const INFOBIP_SECRETS = [
  infobipApiKey,
  infobipAppId,
  infobipMsgId,
  infobipSender,
];
const RESET_SECRETS = INFOBIP_SECRETS;
const YENGAPAY_SECRETS = [yengaPayApiKey];

const INFOBIP_BASE_URL =
  "https://z49yk3.api.infobip.com";

/*
|--------------------------------------------------------------------------
| CONSTANTES DE SÉCURITÉ
|--------------------------------------------------------------------------
*/

const RESET_CODE_EXPIRATION_MINUTES = 15;
const RESET_TOKEN_EXPIRATION_MINUTES = 10;


/*
|--------------------------------------------------------------------------
| NORMALISATION DU NUMÉRO
|--------------------------------------------------------------------------
*/

function normalizePhone(phone) {
  if (!phone || typeof phone !== "string") {
    return null;
  }

  let value = phone.trim();

  value = value.replace(/[^\d+]/g, "");

  if (!value) {
    return null;
  }

  // 00225XXXXXXXXXX
  if (value.startsWith("00225")) {
    value = "+" + value.substring(2);
  }

  // 00XXXXXXXX
  else if (value.startsWith("00")) {
    value = "+" + value.substring(2);
  }

  // 225XXXXXXXXXX
  else if (value.startsWith("225")) {
    value = "+" + value;
  }

  // Numéro ivoirien local à 10 chiffres
  else if (
    /^\d{10}$/.test(value) &&
    /^(01|05|07)/.test(value)
  ) {
    value = "+225" + value;
  }

  // Ancien format 8 chiffres
  else if (/^\d{8}$/.test(value)) {
    value = "+225" + value;
  }

  // Numéro international sans +
  else if (!value.startsWith("+")) {
    value = "+" + value;
  }

  if (!/^\+\d{8,15}$/.test(value)) {
    return null;
  }

  return value;
}


/*
|--------------------------------------------------------------------------
| HASH SHA-256
|--------------------------------------------------------------------------
*/

function hashToken(token) {
  return crypto
    .createHash("sha256")
    .update(token)
    .digest("hex");
}


function hashPin(pin) {
  return crypto
    .createHash("sha256")
    .update(pin)
    .digest("hex");
}


/*
|--------------------------------------------------------------------------
| COMPARAISON SÉCURISÉE
|--------------------------------------------------------------------------
*/

function safeEqual(valueA, valueB) {
  if (
    typeof valueA !== "string" ||
    typeof valueB !== "string"
  ) {
    return false;
  }

  const a = Buffer.from(valueA);
  const b = Buffer.from(valueB);

  if (a.length !== b.length) {
    return false;
  }

  return crypto.timingSafeEqual(a, b);
}


/*
|--------------------------------------------------------------------------
| REQUÊTE INFOBIP
|--------------------------------------------------------------------------
*/

async function infobipRequest(
  path,
  options = {},
) {
  const apiKey =
    infobipApiKey.value();

  if (!apiKey) {
    throw new Error(
      "INFOBIP_API_KEY n'est pas configurée.",
    );
  }

  const response = await fetch(
    `${INFOBIP_BASE_URL}${path}`,
    {
      method:
        options.method || "GET",

      headers: {
        Authorization:
          `App ${apiKey}`,

        "Content-Type":
          "application/json",

        Accept:
          "application/json",

        ...(options.headers || {}),
      },

      body:
        options.body !== undefined
          ? JSON.stringify(options.body)
          : undefined,
    },
  );

  const text =
    await response.text();

  let data = {};

  try {
    data = text
      ? JSON.parse(text)
      : {};
  } catch (_) {
    data = {
      raw: text,
    };
  }

  if (!response.ok) {
    console.error(
      "Erreur Infobip:",
      {
        status: response.status,
        data: data,
      },
    );

    throw new Error(
      data?.requestError
        ?.serviceException
        ?.text ||
      data?.message ||
      `Erreur Infobip ${response.status}`,
    );
  }

  return data;
}


/*
|--------------------------------------------------------------------------
| EXTRACTION IDENTIFIANT
|--------------------------------------------------------------------------
|
| Le Flutter envoie maintenant :
|
| {
|   "identifier": "0700000000"
| }
|
*/

function getIdentifier(data) {
  if (!data) {
    return "";
  }

  return String(
    data.identifier || "",
  ).trim();
}

async function findUserByTelephone(phone, identifier) {
  const candidates = [...new Set([phone, String(identifier || "").trim()])];
  for (const candidate of candidates) {
    if (!candidate) continue;
    const snapshot = await db
      .collection("users")
      .where("telephone", "==", candidate)
      .limit(1)
      .get();
    if (!snapshot.empty) return snapshot;
  }
  return null;
}


/*
|--------------------------------------------------------------------------
| TRAITER UNE DEMANDE DE RECHARGE YENGAPAY
|--------------------------------------------------------------------------
*/

exports.processRechargeRequest = onDocumentCreated(
  {
    document: "recharge_requests/{requestId}",
    region: "us-central1",
    secrets: YENGAPAY_SECRETS,
    retry: true,
  },
  async (event) => {
    const requestSnapshot = event.data;
    if (!requestSnapshot) return;

    const requestRef = requestSnapshot.ref;
    const requestId = event.params.requestId;

    let claimed;
    try {
      claimed = await db.runTransaction(async (transaction) => {
        const current = await transaction.get(requestRef);
        if (!current.exists || current.get("status") !== "pending") {
          return false;
        }

        transaction.update(requestRef, {
          status: "processing",
          processingAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return true;
      });
    } catch (error) {
      console.error("YengaPay could not claim recharge request", {
        requestId,
        errorCode: error?.code || "claim_failed",
      });
      throw error;
    }

    if (!claimed) return;

    try {
      const recharge = requestSnapshot.data();
      const amount = recharge.amount;
      const currency = String(recharge.currency || "").trim().toUpperCase();
      const paymentMethodId = String(recharge.paymentMethod || "").trim();

      if (!Number.isSafeInteger(amount) || amount <= 0) {
        throw Object.assign(new Error("invalid_amount"), {code: "invalid_amount"});
      }
      if (currency !== "XOF") {
        throw Object.assign(new Error("unsupported_currency"), {code: "unsupported_currency"});
      }
      if (!paymentMethodId) {
        throw Object.assign(new Error("missing_payment_method"), {code: "missing_payment_method"});
      }

      const paymentMethodSnapshot = await db
        .collection("payment_methods")
        .doc(paymentMethodId)
        .get();
      if (!paymentMethodSnapshot.exists) {
        throw Object.assign(new Error("payment_method_not_found"), {code: "payment_method_not_found"});
      }
      const userUid = String(recharge.userUid || recharge.userId || "").trim();
      if (!userUid || recharge.userId !== userUid || recharge.userUid !== userUid) {
        throw Object.assign(new Error("invalid_recharge_owner"), {code: "invalid_recharge_owner"});
      }

      const userSnapshot = await db.collection("users").doc(userUid).get();
      const userData = userSnapshot.data();
      const verifiedPhone = normalizePhone(userData?.telephone);
      if (!userSnapshot.exists || userData?.phoneVerified !== true || !verifiedPhone) {
        throw Object.assign(new Error("customer_number_not_verified"), {
          code: "customer_number_not_verified",
        });
      }
      const requestedCustomerNumber = recharge.customerNumber == null ?
        verifiedPhone :
        normalizePhone(String(recharge.customerNumber).trim());
      if (!requestedCustomerNumber || requestedCustomerNumber !== verifiedPhone) {
        throw Object.assign(new Error("customer_number_not_verified"), {
          code: "customer_number_not_verified",
        });
      }
      const customerNumber = verifiedPhone;

      const paymentMethod = paymentMethodSnapshot.data();
      const isActive = paymentMethod.actif ?? paymentMethod.enabled ?? true;
      if (isActive !== true) {
        throw Object.assign(new Error("payment_method_disabled"), {code: "payment_method_disabled"});
      }

      const rawPaymentSource = String(
        paymentMethod.paymentSource ||
          paymentMethod.provider ||
          paymentMethod.slug ||
          paymentMethodId,
      ).trim().toLowerCase();
      const paymentSource = rawPaymentSource.replace(/[\s-]+/g, "_");
      if (!/^[a-z][a-z0-9_]{1,49}$/.test(paymentSource)) {
        throw Object.assign(new Error("invalid_payment_source"), {code: "invalid_payment_source"});
      }

      const environment = yengaPayEnvironment.value().trim().toLowerCase();
      const baseUrlByEnvironment = {
        sandbox: "https://yengapay.com",
        production: "https://yengapay.com",
      };
      const baseUrl = baseUrlByEnvironment[environment];
      const organizationId = yengaPayOrganizationId.value().trim();
      const apiKey = yengaPayApiKey.value();

      if (!baseUrl || !organizationId || !apiKey) {
        throw Object.assign(new Error("yengapay_configuration_missing"), {
          code: "yengapay_configuration_missing",
        });
      }

      const endpoint =
        `${baseUrl}/api/v1/organizations/${encodeURIComponent(organizationId)}` +
        "/payment-intent";
      const response = await fetch(endpoint, {
        method: "POST",
        headers: {
          "x-api-key": apiKey,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          paymentAmount: amount,
          currency: "XOF",
          customerNumber,
          paymentSource,
          reference: requestId,
        }),
        signal: AbortSignal.timeout(20000),
      });

      const responseText = await response.text();
      let result = {};
      try {
        result = responseText ? JSON.parse(responseText) : {};
      } catch (_) {
        result = {};
      }

      const providerStatus = String(
        result.status || result.data?.status || result.paymentIntent?.status || "",
      ).trim().toLowerCase();

      if (!response.ok) {
        throw Object.assign(new Error("yengapay_payment_failed"), {
          code: `yengapay_http_${response.status}`,
        });
      }

      const successfulStatuses = ["success", "succeeded", "completed", "paid"];
      const failedStatuses = ["failed", "failure", "rejected", "cancelled", "canceled", "error"];
      const paymentStatus = successfulStatuses.includes(providerStatus) ?
        "success" :
        failedStatuses.includes(providerStatus) ? "failed" : "pending";
      const providerReference = String(
        result.transactionId || result.paymentIntentId || result.id ||
          result.data?.transactionId || result.data?.paymentIntentId ||
          result.data?.id || "",
      );

      await requestRef.update({
        status: paymentStatus,
        paymentProvider: "yengapay",
        paymentProviderStatus: providerStatus,
        paymentProviderReference: providerReference,
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } catch (error) {
      const failureCode = String(error?.code || "yengapay_payment_failed")
        .replace(/[^a-zA-Z0-9_-]/g, "_")
        .slice(0, 80);
      try {
        await requestRef.update({
          status: "failed",
          paymentProvider: "yengapay",
          failureCode,
          processedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      } catch (updateError) {
        console.error("YengaPay failure status could not be saved", {
          requestId,
          errorCode: updateError?.code || "firestore_update_failed",
        });
        throw updateError;
      }

      console.error("YengaPay recharge failed", {requestId, failureCode});
    }
  },
);


/*
|--------------------------------------------------------------------------
| RÉINITIALISATION DU MOT DE PASSE PAR TÉLÉPHONE
|--------------------------------------------------------------------------
*/

exports.requestPasswordReset = onCall(
  {
    region: "us-central1",
    secrets: RESET_SECRETS,
  },
  async (request) => {
    try {
      const identifier = getIdentifier(request.data);
      const phone = normalizePhone(identifier);

      if (!phone) {
        throw new HttpsError(
          "invalid-argument",
          "Numéro de téléphone invalide.",
        );
      }

      const userSnapshot = await findUserByTelephone(phone, identifier);
      if (!userSnapshot) {
        throw new HttpsError(
          "not-found",
          "Aucun compte associé à ce numéro.",
        );
      }

      const user = userSnapshot.docs[0];
      const result = await infobipRequest(
        "/2fa/2/pin",
        {
          method: "POST",
          body: {
            applicationId: infobipAppId.value(),
            messageId: infobipMsgId.value(),
            from: infobipSender.value(),
            to: phone,
          },
        },
      );

      if (!result?.pinId) {
        throw new Error("Infobip n'a pas retourné de pinId.");
      }

      await db.collection("phone_password_resets").doc(user.id).set({
        uid: user.id,
        phone,
        pinId: result.pinId,
        status: "pending",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        expiresAt: admin.firestore.Timestamp.fromMillis(
          Date.now() + RESET_CODE_EXPIRATION_MINUTES * 60 * 1000,
        ),
      });

      return {
        success: true,
        maskedDestination: maskPhone(phone),
      };
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }
      console.error("requestPasswordReset error:", error);
      throw new HttpsError(
        "internal",
        "Impossible d'envoyer le code de vérification.",
      );
    }
  },
);


exports.verifyPasswordResetCode = onCall(
  {
    region: "us-central1",
    secrets: RESET_SECRETS,
  },
  async (request) => {
    try {
      const identifier = getIdentifier(request.data);
      const phone = normalizePhone(identifier);
      const code = String(request.data?.code || "").trim();

      if (!phone || !/^\d{4}$/.test(code)) {
        throw new HttpsError(
          "invalid-argument",
          "Code de vérification invalide.",
        );
      }

      const userSnapshot = await findUserByTelephone(phone, identifier);
      if (!userSnapshot) {
        throw new HttpsError(
          "not-found",
          "Aucun compte associé à ce numéro.",
        );
      }

      const uid = userSnapshot.docs[0].id;
      const resetRef = db.collection("phone_password_resets").doc(uid);
      const resetSnapshot = await resetRef.get();

      if (!resetSnapshot.exists) {
        throw new HttpsError(
          "failed-precondition",
          "Aucune demande de réinitialisation en cours.",
        );
      }

      const reset = resetSnapshot.data();
      if (reset.phone !== phone || reset.status !== "pending") {
        throw new HttpsError(
          "failed-precondition",
          "Cette demande de réinitialisation n'est plus valide.",
        );
      }

      if (!reset.expiresAt || reset.expiresAt.toMillis() < Date.now()) {
        await resetRef.update({status: "expired"});
        throw new HttpsError(
          "deadline-exceeded",
          "Le code de vérification a expiré.",
        );
      }

      const verification = await infobipRequest(
        `/2fa/2/pin/${encodeURIComponent(reset.pinId)}/verify`,
        {method: "POST", body: {pin: code}},
      );
      const verified = verification?.verified === true ||
        verification?.status === "VERIFIED" ||
        verification?.status === "verified";

      if (!verified) {
        throw new HttpsError(
          "permission-denied",
          "Code de vérification incorrect.",
        );
      }

      const resetToken = crypto.randomBytes(32).toString("hex");
      await resetRef.update({
        status: "verified",
        resetTokenHash: hashToken(resetToken),
        verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
        resetTokenExpiresAt: admin.firestore.Timestamp.fromMillis(
          Date.now() + RESET_TOKEN_EXPIRATION_MINUTES * 60 * 1000,
        ),
      });

      return {success: true, resetToken};
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }
      console.error("verifyPasswordResetCode error:", error);
      throw new HttpsError(
        "internal",
        "Impossible de vérifier le code.",
      );
    }
  },
);


exports.resetPasswordByPhone = onCall(
  {region: "us-central1", secrets: RESET_SECRETS},
  async (request) => {
    try {
      const phone = normalizePhone(getIdentifier(request.data));
      const resetToken = String(request.data?.resetToken || "").trim();
      const newPassword = String(request.data?.newPassword || "");

      if (!phone || !resetToken || newPassword.length < 6) {
        throw new HttpsError(
          "invalid-argument",
          "Numéro, code de vérification ou mot de passe invalide.",
        );
      }

      const userSnapshot = await findUserByTelephone(
        phone,
        getIdentifier(request.data),
      );
      if (!userSnapshot) {
        throw new HttpsError(
          "not-found",
          "Aucun compte associé à ce numéro.",
        );
      }

      const uid = userSnapshot.docs[0].id;
      const resetRef = db.collection("phone_password_resets").doc(uid);
      const resetSnapshot = await resetRef.get();
      if (!resetSnapshot.exists) {
        throw new HttpsError(
          "failed-precondition",
          "Aucune vérification valide.",
        );
      }

      const reset = resetSnapshot.data();
      if (
        reset.phone !== phone ||
        reset.status !== "verified" ||
        !reset.resetTokenExpiresAt ||
        reset.resetTokenExpiresAt.toMillis() < Date.now() ||
        !safeEqual(hashToken(resetToken), reset.resetTokenHash || "")
      ) {
        throw new HttpsError(
          "permission-denied",
          "La vérification a expiré. Demandez un nouveau code.",
        );
      }

      await admin.auth().updateUser(uid, {password: newPassword});
      await resetRef.update({
        status: "completed",
        resetTokenHash: admin.firestore.FieldValue.delete(),
        resetTokenExpiresAt: admin.firestore.FieldValue.delete(),
        completedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {success: true};
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }
      console.error("resetPasswordByPhone error:", error);
      throw new HttpsError(
        "internal",
        "Impossible de réinitialiser le mot de passe.",
      );
    }
  },
);


/*
|--------------------------------------------------------------------------
| 1. DEMANDER LA RÉINITIALISATION
|--------------------------------------------------------------------------
*/

exports.requestPinReset = onCall(
  {
    region: "us-central1",
    secrets: INFOBIP_SECRETS,
  },

  async (request) => {
    try {
      const identifier =
        getIdentifier(request.data);

      const phone =
        normalizePhone(identifier);

      if (!phone) {
        throw new HttpsError(
          "invalid-argument",
          "Numéro de téléphone invalide.",
        );
      }

      /*
       * Recherche du compte.
       */

      const snapshot =
        await db
          .collection("users")
          .where(
            "telephone",
            "==",
            phone,
          )
          .limit(1)
          .get();

      /*
       * Important :
       *
       * On ne révèle pas au client
       * si le numéro existe ou non.
       */

      if (snapshot.empty) {
        return {
          success: true,

          message:
            "Si ce numéro possède un compte, " +
            "un code de vérification sera envoyé.",
        };
      }

      const userDoc =
        snapshot.docs[0];

      const uid =
        userDoc.id;

      /*
       * Génération d'un nouveau code
       * via Infobip 2FA.
       */

      const result =
        await infobipRequest(
          "/2fa/2/pin",
          {
            method: "POST",

            body: {
              applicationId:
                infobipAppId.value(),

              messageId:
                infobipMsgId.value(),

              from:
                infobipSender.value(),

              to:
                phone,
            },
          },
        );

      const pinId =
        result?.pinId;

      if (!pinId) {
        console.error(
          "Infobip n'a pas retourné de pinId:",
          result,
        );

        throw new Error(
          "Infobip n'a pas retourné de pinId.",
        );
      }

      /*
       * Enregistre uniquement les informations
       * nécessaires à la vérification.
       *
       * Le PIN SMS n'est jamais enregistré.
       */

      await db
        .collection("pin_resets")
        .doc(uid)
        .set(
          {
            uid: uid,

            phone: phone,

            pinId: pinId,

            status: "pending",

            createdAt:
              admin.firestore.FieldValue
                .serverTimestamp(),

            expiresAt:
              admin.firestore.Timestamp
                .fromMillis(
                  Date.now() +
                    RESET_CODE_EXPIRATION_MINUTES *
                    60 *
                    1000,
                ),

            resetTokenHash:
              admin.firestore.FieldValue.delete(),

            resetTokenExpiresAt:
              admin.firestore.FieldValue.delete(),

            verifiedAt:
              admin.firestore.FieldValue.delete(),

            completedAt:
              admin.firestore.FieldValue.delete(),
          },
        );

      return {
        success: true,

        message:
          "Un code de vérification " +
          "a été envoyé par SMS.",

        /*
         * Le client n'a pas besoin
         * de connaître le pinId.
         */
        maskedDestination:
          maskPhone(phone),

        method:
          "phone",
      };
    } catch (error) {
      console.error(
        "requestPinReset error:",
        error,
      );

      if (
        error instanceof HttpsError
      ) {
        throw error;
      }

      throw new HttpsError(
        "internal",
        "Impossible d'envoyer " +
        "le code de vérification.",
      );
    }
  },
);


/*
|--------------------------------------------------------------------------
| MASQUER LE NUMÉRO
|--------------------------------------------------------------------------
*/

function maskPhone(phone) {
  if (!phone) {
    return "numéro masqué";
  }

  if (phone.length <= 7) {
    return phone;
  }

  const start =
    phone.substring(0, 4);

  const end =
    phone.substring(
      phone.length - 2,
    );

  return `${start}******${end}`;
}


/*
|--------------------------------------------------------------------------
| 2. VÉRIFIER LE CODE SMS
|--------------------------------------------------------------------------
*/

exports.verifyPinResetCode = onCall(
  {
    region: "us-central1",
    secrets: INFOBIP_SECRETS,
  },

  async (request) => {
    try {
      const identifier =
        getIdentifier(request.data);

      const phone =
        normalizePhone(identifier);

      const code =
        String(
          request.data?.code || "",
        ).trim();

      if (!phone) {
        throw new HttpsError(
          "invalid-argument",
          "Numéro de téléphone invalide.",
        );
      }

      /*
       * Ton interface Flutter utilise
       * un code à 4 chiffres.
       */

      if (!/^\d{4}$/.test(code)) {
        throw new HttpsError(
          "invalid-argument",
          "Code de vérification invalide.",
        );
      }

      /*
       * Recherche utilisateur.
       */

      const userSnapshot =
        await db
          .collection("users")
          .where(
            "telephone",
            "==",
            phone,
          )
          .limit(1)
          .get();

      if (userSnapshot.empty) {
        throw new HttpsError(
          "not-found",
          "Compte introuvable.",
        );
      }

      const uid =
        userSnapshot.docs[0].id;

      const resetRef =
        db
          .collection("pin_resets")
          .doc(uid);

      const resetSnapshot =
        await resetRef.get();

      if (!resetSnapshot.exists) {
        throw new HttpsError(
          "failed-precondition",
          "Aucune demande de " +
          "réinitialisation en cours.",
        );
      }

      const resetData =
        resetSnapshot.data();

      /*
       * Vérification du téléphone
       * associé à la demande.
       */

      if (
        resetData.phone !== phone
      ) {
        throw new HttpsError(
          "permission-denied",
          "Demande de réinitialisation invalide.",
        );
      }

      /*
       * Statut.
       */

      if (
        resetData.status !==
        "pending"
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Cette demande n'est plus valide.",
        );
      }

      /*
       * Expiration.
       */

      if (
        resetData.expiresAt &&
        resetData.expiresAt.toMillis() <
          Date.now()
      ) {
        await resetRef.update({
          status: "expired",
        });

        throw new HttpsError(
          "deadline-exceeded",
          "Le code de vérification a expiré.",
        );
      }

      /*
       * Vérification auprès d'Infobip.
       */

      const result =
        await infobipRequest(
          `/2fa/2/pin/${encodeURIComponent(
            resetData.pinId,
          )}/verify`,
          {
            method: "POST",

            body: {
              pin: code,
            },
          },
        );

      const verified =
        result?.verified === true ||
        result?.status === "VERIFIED" ||
        result?.status === "verified";

      if (!verified) {
        throw new HttpsError(
          "permission-denied",
          "Code de vérification incorrect.",
        );
      }

      /*
       * Génération d'un token temporaire.
       *
       * Le token brut est envoyé au téléphone.
       * Seul son hash est enregistré dans Firestore.
       */

      const resetToken =
        crypto
          .randomBytes(32)
          .toString("hex");

      const resetTokenHash =
        hashToken(resetToken);

      await resetRef.update({
        status: "verified",

        resetTokenHash:
          resetTokenHash,

        verifiedAt:
          admin.firestore.FieldValue
            .serverTimestamp(),

        resetTokenExpiresAt:
          admin.firestore.Timestamp
            .fromMillis(
              Date.now() +
                RESET_TOKEN_EXPIRATION_MINUTES *
                60 *
                1000,
            ),
      });

      return {
        success: true,

        message:
          "Code vérifié. Vous pouvez " +
          "maintenant définir un nouveau PIN.",

        resetToken:
          resetToken,
      };
    } catch (error) {
      console.error(
        "verifyPinResetCode error:",
        error,
      );

      if (
        error instanceof HttpsError
      ) {
        throw error;
      }

      throw new HttpsError(
        "internal",
        "Impossible de vérifier le code.",
      );
    }
  },
);


/*
|--------------------------------------------------------------------------
| 3. RÉINITIALISER LE PIN
|--------------------------------------------------------------------------
*/

exports.resetPin = onCall(
  {
    region: "us-central1",
  },

  async (request) => {
    try {
      const identifier =
        getIdentifier(request.data);

      const phone =
        normalizePhone(identifier);

      const resetToken =
        String(
          request.data?.resetToken || "",
        ).trim();

      const newPin =
        String(
          request.data?.newPin || "",
        ).trim();

      if (!phone) {
        throw new HttpsError(
          "invalid-argument",
          "Numéro de téléphone invalide.",
        );
      }

      if (!resetToken) {
        throw new HttpsError(
          "invalid-argument",
          "Jeton de réinitialisation manquant.",
        );
      }

      if (!/^\d{4}$/.test(newPin)) {
        throw new HttpsError(
          "invalid-argument",
          "Le nouveau PIN doit contenir " +
          "exactement 4 chiffres.",
        );
      }

      /*
       * Recherche du compte.
       */

      const userSnapshot =
        await db
          .collection("users")
          .where(
            "telephone",
            "==",
            phone,
          )
          .limit(1)
          .get();

      if (userSnapshot.empty) {
        throw new HttpsError(
          "not-found",
          "Compte introuvable.",
        );
      }

      const uid =
        userSnapshot.docs[0].id;

      const userRef =
        db
          .collection("users")
          .doc(uid);

      /*
       * Demande de réinitialisation.
       */

      const resetRef =
        db
          .collection("pin_resets")
          .doc(uid);

      const resetSnapshot =
        await resetRef.get();

      if (!resetSnapshot.exists) {
        throw new HttpsError(
          "failed-precondition",
          "Demande de réinitialisation introuvable.",
        );
      }

      const resetData =
        resetSnapshot.data();

      /*
       * Le SMS doit avoir été vérifié.
       */

      if (
        resetData.status !==
        "verified"
      ) {
        throw new HttpsError(
          "permission-denied",
          "Le numéro n'a pas été vérifié.",
        );
      }

      /*
       * Vérifie que le téléphone
       * correspond à la demande.
       */

      if (
        resetData.phone !== phone
      ) {
        throw new HttpsError(
          "permission-denied",
          "Demande de réinitialisation invalide.",
        );
      }

      /*
       * Vérification expiration token.
       */

      if (
        resetData.resetTokenExpiresAt &&
        resetData.resetTokenExpiresAt.toMillis() <
          Date.now()
      ) {
        await resetRef.update({
          status: "expired",
        });

        throw new HttpsError(
          "deadline-exceeded",
          "La session de réinitialisation a expiré.",
        );
      }

      /*
       * Vérification token.
       */

      const receivedHash =
        hashToken(resetToken);

      const storedHash =
        String(
          resetData.resetTokenHash || "",
        );

      if (
        !safeEqual(
          receivedHash,
          storedHash,
        )
      ) {
        throw new HttpsError(
          "permission-denied",
          "Jeton de réinitialisation invalide.",
        );
      }

      /*
       * Hash du nouveau PIN.
       */

      const pinHash =
        hashPin(newPin);

      /*
       * Mise à jour du compte.
       */

      await userRef.update({
        pinHash:
          pinHash,

        pinConfigured:
          true,

        securityUpdatedAt:
          admin.firestore.FieldValue
            .serverTimestamp(),
      });

      /*
       * Invalidation immédiate
       * du token.
       */

      await resetRef.update({
        status: "completed",

        resetTokenHash:
          admin.firestore.FieldValue
            .delete(),

        resetTokenExpiresAt:
          admin.firestore.FieldValue
            .delete(),

        completedAt:
          admin.firestore.FieldValue
            .serverTimestamp(),
      });

      return {
        success: true,

        message:
          "Votre PIN a été réinitialisé " +
          "avec succès.",
      };
    } catch (error) {
      console.error(
        "resetPin error:",
        error,
      );

      if (
        error instanceof HttpsError
      ) {
        throw error;
      }

      throw new HttpsError(
        "internal",
        "Impossible de réinitialiser le PIN.",
      );
    }
  },
);


/*
|--------------------------------------------------------------------------
| 4. CRÉER LE PIN
|--------------------------------------------------------------------------
*/

exports.createPin = onCall(
  {
    region: "us-central1",
  },

  async (request) => {
    try {
      /*
       * Utilisateur connecté obligatoire.
       */

      if (!request.auth) {
        throw new HttpsError(
          "unauthenticated",
          "Vous devez être connecté.",
        );
      }

      const uid =
        request.auth.uid;

      const pin =
        String(
          request.data?.pin || "",
        ).trim();

      if (!/^\d{4}$/.test(pin)) {
        throw new HttpsError(
          "invalid-argument",
          "Le PIN doit contenir " +
          "exactement 4 chiffres.",
        );
      }

      const userRef =
        db
          .collection("users")
          .doc(uid);

      const userSnapshot =
        await userRef.get();

      if (!userSnapshot.exists) {
        throw new HttpsError(
          "not-found",
          "Utilisateur introuvable.",
        );
      }

      const userData =
        userSnapshot.data();

      /*
       * Empêche de remplacer
       * un PIN existant.
       */

      if (
        userData.pinConfigured === true
      ) {
        throw new HttpsError(
          "already-exists",
          "Un PIN existe déjà.",
        );
      }

      const pinHash =
        hashPin(pin);

      await userRef.update({
        pinHash:
          pinHash,

        pinConfigured:
          true,

        securityUpdatedAt:
          admin.firestore.FieldValue
            .serverTimestamp(),
      });

      return {
        success: true,

        message:
          "PIN créé avec succès.",
      };
    } catch (error) {
      console.error(
        "createPin error:",
        error,
      );

      if (
        error instanceof HttpsError
      ) {
        throw error;
      }

      throw new HttpsError(
        "internal",
        "Impossible de créer le PIN.",
      );
    }
  },
);


/*
|--------------------------------------------------------------------------
| 5. VÉRIFIER LE PIN
|--------------------------------------------------------------------------
*/

exports.verifyPin = onCall(
  {
    region: "us-central1",
  },

  async (request) => {
    try {
      if (!request.auth) {
        throw new HttpsError(
          "unauthenticated",
          "Vous devez être connecté.",
        );
      }

      const uid =
        request.auth.uid;

      const pin =
        String(
          request.data?.pin || "",
        ).trim();

      if (!/^\d{4}$/.test(pin)) {
        throw new HttpsError(
          "invalid-argument",
          "PIN invalide.",
        );
      }

      const userSnapshot =
        await db
          .collection("users")
          .doc(uid)
          .get();

      if (!userSnapshot.exists) {
        throw new HttpsError(
          "not-found",
          "Utilisateur introuvable.",
        );
      }

      const userData =
        userSnapshot.data();

      if (
        userData.pinConfigured !== true
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Aucun PIN n'est configuré.",
        );
      }

      const pinHash =
        hashPin(pin);

      if (
        !safeEqual(
          pinHash,
          String(
            userData.pinHash || "",
          ),
        )
      ) {
        throw new HttpsError(
          "permission-denied",
          "PIN incorrect.",
        );
      }

      return {
        success: true,
        verified: true,
      };
    } catch (error) {
      console.error(
        "verifyPin error:",
        error,
      );

      if (
        error instanceof HttpsError
      ) {
        throw error;
      }

      throw new HttpsError(
        "internal",
        "Impossible de vérifier le PIN.",
      );
    }
  },
);


/*
|--------------------------------------------------------------------------
| 6. CHANGER LE PIN
|--------------------------------------------------------------------------
*/

exports.changePin = onCall(
  {
    region: "us-central1",
  },

  async (request) => {
    try {
      if (!request.auth) {
        throw new HttpsError(
          "unauthenticated",
          "Vous devez être connecté.",
        );
      }

      const uid =
        request.auth.uid;

      const currentPin =
        String(
          request.data?.currentPin || "",
        ).trim();

      const newPin =
        String(
          request.data?.newPin || "",
        ).trim();

      if (!/^\d{4}$/.test(currentPin)) {
        throw new HttpsError(
          "invalid-argument",
          "Ancien PIN invalide.",
        );
      }

      if (!/^\d{4}$/.test(newPin)) {
        throw new HttpsError(
          "invalid-argument",
          "Nouveau PIN invalide.",
        );
      }

      if (currentPin === newPin) {
        throw new HttpsError(
          "invalid-argument",
          "Le nouveau PIN doit être " +
          "différent de l'ancien.",
        );
      }

      const userRef =
        db
          .collection("users")
          .doc(uid);

      const userSnapshot =
        await userRef.get();

      if (!userSnapshot.exists) {
        throw new HttpsError(
          "not-found",
          "Utilisateur introuvable.",
        );
      }

      const userData =
        userSnapshot.data();

      if (
        userData.pinConfigured !== true
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Aucun PIN n'est configuré.",
        );
      }

      /*
       * Vérification ancien PIN.
       */

      const currentHash =
        hashPin(currentPin);

      if (
        !safeEqual(
          currentHash,
          String(
            userData.pinHash || "",
          ),
        )
      ) {
        throw new HttpsError(
          "permission-denied",
          "Ancien PIN incorrect.",
        );
      }

      /*
       * Nouveau hash.
       */

      const newHash =
        hashPin(newPin);

      await userRef.update({
        pinHash:
          newHash,

        pinConfigured:
          true,

        securityUpdatedAt:
          admin.firestore.FieldValue
            .serverTimestamp(),
      });

      return {
        success: true,

        message:
          "Votre PIN a été modifié " +
          "avec succès.",
      };
    } catch (error) {
      console.error(
        "changePin error:",
        error,
      );

      if (
        error instanceof HttpsError
      ) {
        throw error;
      }

      throw new HttpsError(
        "internal",
        "Impossible de modifier le PIN.",
      );
    }
  },
);