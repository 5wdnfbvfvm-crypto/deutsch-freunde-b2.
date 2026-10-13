# Deutsch Freunde B2 — mise en ligne (en 5 étapes)

## Étape 1 — Base de données (iPhone possible)
1. supabase.com > ton projet > **SQL Editor** > **New query**.
2. Ouvre `schema.sql`, copie tout, colle, appuie sur **Run**. Message attendu : « Success ».
3. **Authentication > Providers** : Email doit être activé.
   (Option test : **Authentication > Sign In / Providers > Email** > désactive « Confirm email » pour éviter l'e-mail de confirmation.)

## Étape 2 — Ta clé publique (iPhone possible)
Supabase > Project Settings > API Keys > copie la **Publishable key** (`sb_publishable_…`).
Ouvre `config.js` et remplace `COLLE_ICI_TA_PUBLISHABLE_KEY` par cette clé (garde les guillemets).
Jamais de clé « secret » ou « service_role » ici.

## Étape 3 — GitHub (ordinateur recommandé)
1. github.com > **New repository** > nom `deutsch-freunde-b2` > **Create**.
2. **uploading an existing file** : glisse TOUS les fichiers et dossiers du projet décompressé (index.html, app.js, config.js, sw.js, manifest.json, dossiers data et icons). **Commit changes**.

## Étape 4 — Lien public avec Vercel (iPhone possible)
1. vercel.com > **Sign up with GitHub** > **Add New > Project** > choisis `deutsch-freunde-b2` > **Deploy** (ne change aucun réglage).
2. Tu obtiens un lien `https://….vercel.app`. Envoie-le à tes amis.
3. Supabase > **Authentication > URL Configuration** : mets ce lien dans **Site URL**.

## Étape 5 — Installer sur l'écran d'accueil
- **iPhone** : ouvre le lien dans **Safari** > bouton Partager > **Sur l'écran d'accueil**.
- **Android** : Chrome > menu ⋮ > **Installer l'application**.

## Test à faire ensemble (rien n'est validé tant que ce n'est pas fait)
1. Créer 2 comptes (toi + un ami). 2. Créer un groupe, l'ami le rejoint avec le code.
3. Envoyer un message : il doit apparaître chez l'ami. 4. Un 3e compte hors groupe ne doit voir aucun message.
5. Ouvrir un salon Gruppenanruf à deux.

## Limites
Gratuit : Supabase (projet mis en pause si inactif ~1 semaine), Vercel, Jitsi. Pas encore fait : correction IA (payante à l'usage), import de PDF dans l'app (le contenu de ton PDF est déjà intégré).
