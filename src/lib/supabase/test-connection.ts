// Script de test de connexion Supabase
// Usage : npx tsx --env-file=.env.local src/lib/supabase/test-connection.ts

import { createClient } from "@supabase/supabase-js"

const url = process.env.NEXT_PUBLIC_SUPABASE_URL
const key = process.env.SUPABASE_SERVICE_ROLE_KEY

if (!url || !key) {
  console.error("❌ Variables d'environnement manquantes (NEXT_PUBLIC_SUPABASE_URL ou SUPABASE_SERVICE_ROLE_KEY)")
  process.exit(1)
}

const supabase = createClient(url, key)

async function testConnection() {
  console.log("🔌 Test de connexion Supabase…\n")

  // Vérifie que les tables existent et sont accessibles
  const tables = ["categories", "products", "product_images", "affiliate_links", "clicks"] as const

  for (const table of tables) {
    const { count, error } = await supabase
      .from(table)
      .select("*", { count: "exact", head: true })

    if (error) {
      console.error(`❌ ${table.padEnd(20)} Erreur : ${error.message}`)
    } else {
      console.log(`✅ ${table.padEnd(20)} ${count ?? 0} ligne(s)`)
    }
  }

  // Test d'une jointure simple
  const { data: products, error: joinError } = await supabase
    .from("products")
    .select("slug, name, categories(name)")
    .limit(3)

  if (joinError) {
    console.error(`\n❌ Jointure products→categories : ${joinError.message}`)
  } else {
    console.log(`\n✅ Jointure OK — ${products.length} produit(s) récupéré(s)`)
    products.forEach((p) => console.log(`   • ${p.name}`))
  }

  console.log("\n🏁 Test terminé.")
}

testConnection().catch((err) => {
  console.error("Erreur inattendue :", err)
  process.exit(1)
})
