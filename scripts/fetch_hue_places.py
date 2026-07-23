import urllib.request
import urllib.parse
import json
import os
import sys

# Set encoding for Windows terminal
if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8')

# Overpass API URL
OVERPASS_URL = "https://overpass-api.de/api/interpreter"

# Overpass QL query to fetch historic sites, tourism attractions, restaurants, and cafes in Hue city area
overpass_query = """
[out:json][timeout:25];
(
  node["historic"](16.35,107.45,16.55,107.68);
  node["tourism"](16.35,107.45,16.55,107.68);
  node["amenity"~"restaurant|cafe"](16.35,107.45,16.55,107.68);
);
out body;
"""

def fetch_hue_places():
    print("[INFO] Dang ket noi toi Overpass API de lay du lieu dia diem tai Hue...")
    data_encoded = urllib.parse.urlencode({'data': overpass_query}).encode('utf-8')
    req = urllib.request.Request(OVERPASS_URL, data=data_encoded, headers={'User-Agent': 'CodoKyHueApp/1.0'})

    try:
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode('utf-8'))

        elements = result.get('elements', [])
        places = []

        for element in elements:
            tags = element.get('tags', {})
            name = tags.get('name')
            if not name:
                continue

            # Classify category
            category = 'attraction'
            if 'historic' in tags:
                historic_type = tags.get('historic', '')
                category = 'tomb' if 'tomb' in historic_type else 'attraction'
            elif tags.get('tourism') == 'attraction':
                category = 'attraction'
            elif tags.get('amenity') in ['restaurant', 'cafe']:
                category = 'restaurant'

            places.append({
                'id': str(element['id']),
                'name': name,
                'category': category,
                'latitude': element['lat'],
                'longitude': element['lon'],
                'address': tags.get('addr:street', 'Thua Thien Hue'),
                'rating': 4.5,
            })

        output_path = os.path.join(os.path.dirname(__file__), 'hue_places_seed.json')
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(places, f, ensure_ascii=False, indent=2)

        print(f"[SUCCESS] Da trich xuat {len(places)} dia diem tai Hue vao file:\n   {output_path}")

    except Exception as e:
        print(f"[ERROR] Loi khi tai du lieu tu Overpass API: {e}")

if __name__ == '__main__':
    fetch_hue_places()
