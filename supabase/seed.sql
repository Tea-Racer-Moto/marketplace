-- Seed Tea Racer — données de test réalistes
-- À exécuter APRÈS la migration 0001
-- Les UUID sont générés dynamiquement via CTEs avec RETURNING

WITH

-- ============================================================
-- CATÉGORIES
-- ============================================================
cats AS (
  INSERT INTO categories (slug, name, icon) VALUES
    ('casques',   'Casques',   'helmet'),
    ('vestes',    'Vestes',    'jacket'),
    ('gants',     'Gants',     'glove'),
    ('pantalons', 'Pantalons', 'pants'),
    ('bottes',    'Bottes',    'boot')
  RETURNING id, slug
),

-- ============================================================
-- PRODUITS
-- ============================================================

-- 1. Shoei NXR2 — casque intégral sport
shoei AS (
  INSERT INTO products (
    slug, name, brand, category_id, subcategory,
    price_min, price_max, currency,
    season, my_rating, pros, cons,
    youtube_video_id, test_date, test_kilometers
  )
  SELECT
    'shoei-nxr2',
    'NXR2',
    'Shoei',
    cats.id,
    'Intégral sport',
    55000, 70000, 'EUR',
    ARRAY['ete', 'mi-saison']::season_type[],
    9,
    ARRAY[
      'Aération excellente, pas de sensation d''étouffement même en ville',
      'Visière Pinlock 120 incluse, zéro buée en hiver',
      'Coque légère (1 450 g en taille M), pas de fatigue sur longue distance',
      'Finitions premium, mécanisme d''ouverture de visière précis'
    ],
    ARRAY[
      'Prix élevé — compter 600 € minimum pour une couleur unie',
      'Coiffe étroite aux tempes pour les crânes ronds (adapté ovale long)'
    ],
    'AbCdEfG1234', -- youtube_video_id à remplacer
    '2024-05-15',
    3200
  FROM cats WHERE cats.slug = 'casques'
  RETURNING id, slug
),

-- 2. Dainese Avro 5 Tex — veste mi-saison
dainese AS (
  INSERT INTO products (
    slug, name, brand, category_id, subcategory,
    price_min, price_max, currency,
    season, my_rating, pros, cons,
    youtube_video_id, test_date, test_kilometers
  )
  SELECT
    'dainese-avro-5-tex',
    'Avro 5 Tex',
    'Dainese',
    cats.id,
    'Veste textile mi-saison',
    32000, 42000, 'EUR',
    ARRAY['mi-saison', 'printemps', 'automne']::season_type[],
    8,
    ARRAY[
      'Membrane Gore-Tex Pro intégrée — vraiment imperméable, pas juste déperlant',
      'Protections CE niveau 2 épaules et coudes d''origine, dos niveau 1 inclus',
      'Coupe sport mais portée correctement avec un jean — pas trop motard',
      'Finitions Dainese au niveau du prix, rien à redire'
    ],
    ARRAY[
      'Peu de rangements — deux poches extérieures, c''est tout',
      'Coupe cintrée : si tu fais du L en t-shirt prends un XL',
      'Pas de liner thermique — à prévoir si tu roules sous 10°C'
    ],
    NULL,
    '2024-03-20',
    1800
  FROM cats WHERE cats.slug = 'vestes'
  RETURNING id, slug
),

-- 3. Five RFX1 — gants été
five AS (
  INSERT INTO products (
    slug, name, brand, category_id, subcategory,
    price_min, price_max, currency,
    season, my_rating, pros, cons,
    youtube_video_id, test_date, test_kilometers
  )
  SELECT
    'five-rfx1',
    'RFX1',
    'Five Gloves',
    cats.id,
    'Gants été sport',
    8000, 11000, 'EUR',
    ARRAY['ete']::season_type[],
    8,
    ARRAY[
      'Légèreté exemplaire — on oublie qu''on les porte au bout de 10 min',
      'Protection carbone sur les phalanges, kevlar sur la paume',
      'Grip précis : bonne transmission des retours du guidon',
      'Écran tactile compatible sans retirer le gant'
    ],
    ARRAY[
      'Chauds par forte chaleur (35°C+) — prévoir perforés pour l''été caniculaire',
      'Aucune résistance à la pluie, à associer à des sur-gants si besoin',
      'Taille petit — prendre une taille au-dessus de son habitude'
    ],
    NULL,
    '2024-06-10',
    950
  FROM cats WHERE cats.slug = 'gants'
  RETURNING id, slug
)

-- ============================================================
-- LIENS AFFILIÉS
-- ============================================================
INSERT INTO affiliate_links (product_id, partner, url, is_primary)

  -- Shoei NXR2
  SELECT id, 'motoblouz'::partner_type, 'https://www.motoblouz.com/recherche/shoei+nxr2', TRUE  FROM shoei
  UNION ALL
  SELECT id, 'dafy'::partner_type,      'https://www.dafy-moto.com/recherche?q=shoei+nxr2', FALSE FROM shoei
  UNION ALL
  SELECT id, 'amazon'::partner_type,    'https://www.amazon.fr/s?k=shoei+nxr2', FALSE FROM shoei

  UNION ALL

  -- Dainese Avro 5 Tex
  SELECT id, 'motoblouz'::partner_type, 'https://www.motoblouz.com/recherche/dainese+avro+5+tex', TRUE  FROM dainese
  UNION ALL
  SELECT id, 'fc-moto'::partner_type,   'https://www.fc-moto.de/fr/search?q=dainese+avro+5+tex', FALSE FROM dainese

  UNION ALL

  -- Five RFX1
  SELECT id, 'motoblouz'::partner_type, 'https://www.motoblouz.com/recherche/five+rfx1', TRUE  FROM five
  UNION ALL
  SELECT id, 'amazon'::partner_type,    'https://www.amazon.fr/s?k=five+rfx1+gants+moto', FALSE FROM five;
