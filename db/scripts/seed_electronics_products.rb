require 'faker'

puts "🌱 Seeding electronic categories..."
category_names = [
  "Smartphones",
  "Laptops",
  "Tablets",
  "Smartwatches",
  "Headphones",
  "Cameras",
  "Drones",
  "Gaming Consoles",
  "Monitors",
  "Accessories"
]

categories = category_names.map { |name| Category.find_or_create_by!(name: name) }
puts "✅ Created #{categories.count} categories."

statuses = { available: 0, out_of_stock: 1, discontinued: 2, unavailable: 3 }

brands = [
  "QuantumX", "ZenTech", "AeroCore", "Hyperion", "PulseOne", "NovaLink",
  "OptiGear", "FusionLabs", "ChronoEdge", "Vertex"
]

def generate_product_name(category_name, brands)
  brand = brands.sample
  model_number = "#{('A'..'Z').to_a.sample}#{rand(1..999)}"
  suffix = [ "Pro", "Lite", "Max", "Air", "Plus", "Edge", "X", "Ultra" ].sample

  case category_name
  when "Smartphones"
    "#{brand} #{[ 'One', 'Vibe', 'Pulse', 'Nova', 'Flow', 'Edge' ].sample} #{suffix}"
  when "Laptops"
    "#{brand} #{[ 'Book', 'Pad', 'Note', 'Core', 'Flex' ].sample} #{suffix}"
  when "Tablets"
    "#{brand} #{[ 'Tab', 'Slate', 'NotePad' ].sample} #{suffix}"
  when "Smartwatches"
    "#{brand} #{[ 'Watch', 'Time', 'Chrono', 'Pulse' ].sample} #{suffix}"
  when "Headphones"
    "#{brand} #{[ 'Sound', 'Beat', 'Tone', 'Audio' ].sample} #{suffix}"
  when "Cameras"
    "#{brand} #{[ 'Vision', 'Capture', 'Lens', 'Shot' ].sample} #{suffix}"
  when "Drones"
    "#{brand} #{[ 'Flyer', 'Hawk', 'Falcon', 'Air', 'Scout' ].sample} #{suffix}"
  when "Gaming Consoles"
    "#{brand} #{[ 'Station', 'Play', 'Box', 'Core', 'Deck' ].sample} #{suffix}"
  when "Monitors"
    "#{brand} #{[ 'View', 'Screen', 'Vision', 'Display' ].sample} #{suffix}"
  when "Accessories"
    "#{brand} #{[ 'Dock', 'Stand', 'Cable', 'Case', 'Charger' ].sample} #{suffix}"
  else
    "#{brand} Device #{suffix}"
  end
end

def generate_product_description(category_name)
  case category_name
  when "Smartphones"
    "A high-end smartphone featuring a powerful processor, vivid AMOLED display, and advanced AI camera system."
  when "Laptops"
    "Lightweight and powerful laptop designed for professionals, featuring ultra-fast SSD and long battery life."
  when "Tablets"
    "Versatile tablet perfect for streaming, productivity, and creative work, with exceptional display clarity."
  when "Smartwatches"
    "Modern smartwatch that tracks fitness, heart rate, and notifications, with a sleek, customizable design."
  when "Headphones"
    "Premium noise-cancelling headphones delivering immersive sound and comfort for all-day listening."
  when "Cameras"
    "Professional-grade camera offering 4K video capture, superior autofocus, and outstanding low-light performance."
  when "Drones"
    "Advanced drone equipped with 4K stabilization, obstacle detection, and GPS-assisted flight for smooth control."
  when "Gaming Consoles"
    "Next-generation gaming console with lightning-fast load times, 8K support, and a large library of exclusive titles."
  when "Monitors"
    "High-resolution monitor with adaptive sync and wide color gamut, ideal for gaming or creative professionals."
  when "Accessories"
    "Durable and efficient accessory designed to complement and protect your devices in everyday use."
  end
end

puts "🌱 Seeding 100 unique electronic products for Store #1..."

100.times do |i|
  category = categories.sample
  name = generate_product_name(category.name, brands)
  description = generate_product_description(category.name)

  product = Product.create!(
    name: name,
    description: description,
    quantity: rand(5..200),
    price: Faker::Commerce.price(range: 49.99..1499.99),
    status: statuses.values.sample,
    store_id: 1
  )

  product.categories << category

  puts "✅ Created #{i + 1}: #{product.name} (#{category.name})"
end

puts "🎉 Done! Created 100 realistic electronic products across #{categories.count} categories."
