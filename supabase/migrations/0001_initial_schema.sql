-- Migration 0001 : schéma initial Tea Racer Marketplace
-- À exécuter dans l'éditeur SQL Supabase (Dashboard > SQL Editor)

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- TYPES ENUM
-- ============================================================

CREATE TYPE season_type AS ENUM (
  'ete', 'mi-saison', 'printemps', 'automne', 'hiver', 'all-seasons'
);

CREATE TYPE partner_type AS ENUM (
  'amazon', 'dafy', 'motoblouz', 'fc-moto', 'revzilla', 'iCasque', 'autre'
);

-- ============================================================
-- TABLES
-- ============================================================

CREATE TABLE categories (
  id         UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  slug       TEXT        NOT NULL UNIQUE,
  name       TEXT        NOT NULL,
  icon       TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE products (
  id               UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
  slug             TEXT          NOT NULL UNIQUE,
  name             TEXT          NOT NULL,
  brand            TEXT          NOT NULL,
  category_id      UUID          NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
  subcategory      TEXT,
  -- Prix en centimes pour filtrage/tri fiable (ex: 55000 = 550,00 €)
  price_min        INTEGER       NOT NULL,
  price_max        INTEGER       NOT NULL,
  currency         VARCHAR(3)    NOT NULL DEFAULT 'EUR',
  season           season_type[] NOT NULL DEFAULT '{}',
  -- Note sur 10
  my_rating        SMALLINT      CHECK (my_rating >= 1 AND my_rating <= 10),
  pros             TEXT[]        NOT NULL DEFAULT '{}',
  cons             TEXT[]        NOT NULL DEFAULT '{}',
  -- ID YouTube strict (11 chars alphanum + _ -)
  youtube_video_id VARCHAR(11)   CHECK (youtube_video_id ~ '^[A-Za-z0-9_-]{11}$'),
  test_date        DATE,
  test_kilometers  INTEGER,
  created_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

CREATE TABLE product_images (
  id         UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID        NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  url        TEXT        NOT NULL,
  alt        TEXT,
  -- 0 = image principale
  position   SMALLINT    NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE affiliate_links (
  id         UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID         NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  partner    partner_type NOT NULL,
  url        TEXT         NOT NULL,
  is_primary BOOLEAN      NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  -- Un seul lien par partenaire par produit
  CONSTRAINT uq_affiliate_product_partner UNIQUE (product_id, partner)
);

CREATE TABLE clicks (
  id                UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id        UUID        NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  affiliate_link_id UUID        REFERENCES affiliate_links(id) ON DELETE SET NULL,
  -- UTM source (youtube, instagram, direct…) — limité pour éviter l'abus
  source            TEXT        CHECK (length(source) <= 200),
  user_agent        TEXT        CHECK (length(user_agent) <= 500),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TRIGGER updated_at sur products
-- ============================================================

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER products_set_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_products_slug        ON products(slug);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_created_at  ON products(created_at DESC);
-- Utile pour filtrer par fourchette de prix
CREATE INDEX idx_products_price       ON products(price_min, price_max);

CREATE INDEX idx_product_images_product_position ON product_images(product_id, position);

CREATE INDEX idx_affiliate_links_product_id ON affiliate_links(product_id);
-- UNIQUE : garantit un seul lien primaire par produit
CREATE UNIQUE INDEX idx_affiliate_links_one_primary
  ON affiliate_links(product_id) WHERE is_primary = TRUE;

CREATE INDEX idx_clicks_product_id ON clicks(product_id);
CREATE INDEX idx_clicks_created_at  ON clicks(created_at DESC);

CREATE INDEX idx_categories_slug ON categories(slug);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE categories      ENABLE ROW LEVEL SECURITY;
ALTER TABLE products        ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_images  ENABLE ROW LEVEL SECURITY;
ALTER TABLE affiliate_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE clicks          ENABLE ROW LEVEL SECURITY;

-- Lecture publique du catalogue
CREATE POLICY "public_read_categories"
  ON categories FOR SELECT
  USING (true);

CREATE POLICY "public_read_products"
  ON products FOR SELECT
  USING (true);

CREATE POLICY "public_read_product_images"
  ON product_images FOR SELECT
  USING (true);

CREATE POLICY "public_read_affiliate_links"
  ON affiliate_links FOR SELECT
  USING (true);

-- Écriture admin uniquement (magic link sur l'adresse admin)
CREATE POLICY "admin_write_categories"
  ON categories FOR ALL
  USING (auth.email() = 'contact@tea-racer.com')
  WITH CHECK (auth.email() = 'contact@tea-racer.com');

CREATE POLICY "admin_write_products"
  ON products FOR ALL
  USING (auth.email() = 'contact@tea-racer.com')
  WITH CHECK (auth.email() = 'contact@tea-racer.com');

CREATE POLICY "admin_write_product_images"
  ON product_images FOR ALL
  USING (auth.email() = 'contact@tea-racer.com')
  WITH CHECK (auth.email() = 'contact@tea-racer.com');

CREATE POLICY "admin_write_affiliate_links"
  ON affiliate_links FOR ALL
  USING (auth.email() = 'contact@tea-racer.com')
  WITH CHECK (auth.email() = 'contact@tea-racer.com');

-- Clicks : insertion anonyme avec vérification d'intégrité, lecture admin seulement
CREATE POLICY "public_insert_clicks"
  ON clicks FOR INSERT
  WITH CHECK (
    -- affiliate_link_id doit appartenir au même produit que product_id
    affiliate_link_id IS NULL OR EXISTS (
      SELECT 1 FROM affiliate_links al
      WHERE al.id = affiliate_link_id AND al.product_id = clicks.product_id
    )
  );

CREATE POLICY "admin_read_clicks"
  ON clicks FOR SELECT
  USING (auth.email() = 'contact@tea-racer.com');
