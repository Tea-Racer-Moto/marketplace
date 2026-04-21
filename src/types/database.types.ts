// Types générés manuellement depuis supabase/migrations/0001_initial_schema.sql

export type Season =
  | "ete"
  | "mi-saison"
  | "printemps"
  | "automne"
  | "hiver"
  | "all-seasons"

export type Partner =
  | "amazon"
  | "dafy"
  | "motoblouz"
  | "fc-moto"
  | "revzilla"
  | "iCasque"
  | "autre"

// ============================================================
// Entités de base
// ============================================================

export interface Category {
  id: string
  slug: string
  name: string
  icon: string | null
  created_at: string
}

export interface Product {
  id: string
  slug: string
  name: string
  brand: string
  category_id: string
  subcategory: string | null
  // Prix en centimes (ex: 55000 = 550,00 €)
  price_min: number
  price_max: number
  currency: string
  season: Season[]
  my_rating: number | null
  pros: string[]
  cons: string[]
  youtube_video_id: string | null
  test_date: string | null
  test_kilometers: number | null
  created_at: string
  updated_at: string
}

export interface ProductImage {
  id: string
  product_id: string
  url: string
  alt: string | null
  position: number
  created_at: string
}

export interface AffiliateLink {
  id: string
  product_id: string
  partner: Partner
  url: string
  is_primary: boolean
  created_at: string
}

export interface Click {
  id: string
  product_id: string
  affiliate_link_id: string | null
  source: string | null
  user_agent: string | null
  created_at: string
}

// ============================================================
// Types composites (résultats de jointures)
// ============================================================

export interface ProductWithRelations extends Product {
  category: Category | null
  images: ProductImage[]
  affiliate_links: AffiliateLink[]
}

export interface ProductCard
  extends Pick<
    Product,
    "id" | "slug" | "name" | "brand" | "price_min" | "price_max" | "currency" | "my_rating" | "season"
  > {
  category: Pick<Category, "slug" | "name"> | null
  cover_image: Pick<ProductImage, "url" | "alt"> | null
  primary_link: Pick<AffiliateLink, "id" | "partner" | "url"> | null
}

// ============================================================
// Types pour les formulaires admin
// ============================================================

// updated_at géré par trigger DB, id et created_at auto-générés
export type ProductInsert = Omit<Product, "id" | "created_at" | "updated_at">
export type ProductUpdate = Partial<ProductInsert>

export type CategoryInsert = Omit<Category, "id" | "created_at">

export type AffiliateLinkInsert = Omit<AffiliateLink, "id" | "created_at">

export type ClickInsert = Omit<Click, "id" | "created_at">

// ============================================================
// Helpers
// ============================================================

/** Convertit un prix en centimes en chaîne affichable (ex: 55000 → "550 €") */
export function formatPrice(cents: number, currency = "EUR"): string {
  return new Intl.NumberFormat("fr-FR", {
    style: "currency",
    currency,
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(cents / 100)
}
