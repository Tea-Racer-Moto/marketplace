# Projet : Dressing Moto Tea Racer

## Contexte
Web app servant de dressing/comparateur d'équipements moto pour ma communauté YouTube (chaîne Tea Racer Moto).
Objectif : rediriger vers des sites partenaires via liens d'affiliation (pas de vente directe).
Je suis le seul admin. Public cible : motards francophones, majoritairement sur mobile.

## Stack technique
- Framework : Next.js 15 (App Router) + TypeScript
- Style : Tailwind CSS v4 + shadcn/ui pour les composants
- DB & Auth : Supabase (PostgreSQL + Auth magic link)
- Images : next/image + Supabase Storage
- Analytics : Plausible (RGPD-friendly)
- Déploiement : Vercel
- Embed YouTube : lite-youtube-embed (perfs mobiles)

## Règles de code
- TypeScript strict, pas de any
- Commentaires en français pour la logique métier, anglais pour le technique
- Composants Server par défaut, Client uniquement si nécessaire (interactivité)
- Mobile-first : tout doit être pensé pour un écran 375px d'abord
- Accessibilité : labels ARIA, contrastes WCAG AA minimum
- Pas de hover-only : tout interactif au tap

## Design
- Thème sombre par défaut (fond #0A0A0A, texte #FAFAFA)
- Accent : orange vif (#FF6B00) pour CTA et éléments importants
- Typographie : Inter pour l'UI, à définir pour les titres
- Esthétique : épurée, premium, pas "site de comparateur cheap"

## Architecture des données (Supabase)
- products : id, slug, name, brand, category_id, subcategory, price_range, season[], my_rating, pros[], cons[], youtube_video_id, test_date, test_kilometers, created_at
- categories : id, slug, name, icon
- product_images : id, product_id, url, alt, position
- affiliate_links : id, product_id, partner (amazon/dafy/etc), url, is_primary
- clicks : id, product_id, affiliate_link_id, source (utm), user_agent, created_at

## Flow admin prioritaire
Mon use case n°1 : ajouter un produit depuis mon téléphone en moins d'1 minute.
Toute décision UX admin doit être jugée à cette aune.

## Conformité
- Mention "Liens affiliés" obligatoire et visible (DGCCRF)
- Page "Comment je teste" avec ma méthodo
- Pas de cookies tiers sans consentement (d'où Plausible)

## Comportement attendu de Claude Code
- Travaille étape par étape, attends ma validation avant de passer à la suite
- Si une de mes décisions semble sous-optimale, challenge-la avant d'exécuter
- Propose des choix techniques quand il y a ambiguïté, ne décide pas seul
- Avant toute modification de structure DB ou ajout de dépendance, demande
- Préfère éditer les fichiers existants plutôt qu'en créer de nouveaux quand possible
