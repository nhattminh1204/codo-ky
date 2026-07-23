import urllib.request
import urllib.parse
import json
import os
import sys
import math

# Set encoding for Windows terminal
if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8')

OVERPASS_SERVERS = [
    "https://overpass-api.de/api/interpreter",
    "https://overpass.kumi.systems/api/interpreter",
    "https://maps.mail.ru/osm/tools/overpass/api/interpreter",
]

overpass_query = """
[out:json][timeout:30];
(
  node["amenity"="place_of_worship"](16.35,107.45,16.58,107.68);
  way["amenity"="place_of_worship"](16.35,107.45,16.58,107.68);
  relation["amenity"="place_of_worship"](16.35,107.45,16.58,107.68);

  node["building"~"temple|pagoda"](16.35,107.45,16.58,107.68);
  way["building"~"temple|pagoda"](16.35,107.45,16.58,107.68);

  node["historic"](16.35,107.45,16.58,107.68);
  way["historic"](16.35,107.45,16.58,107.68);
  relation["historic"](16.35,107.45,16.58,107.68);

  node["tourism"~"attraction|museum|viewpoint"](16.35,107.45,16.58,107.68);
  way["tourism"~"attraction|museum|viewpoint"](16.35,107.45,16.58,107.68);

  node["amenity"~"restaurant|cafe"](16.35,107.45,16.58,107.68);
);
out center;
"""

def haversine_distance(lat1, lon1, lat2, lon2):
    R = 6371000.0  # Earth radius in meters
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dlat / 2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c

def fetch_hue_places():
    print("[INFO] Dang ket noi toi Overpass API de lay du lieu dia diem tai Hue...")
    data_encoded = urllib.parse.urlencode({'data': overpass_query}).encode('utf-8')

    res = None
    for server in OVERPASS_SERVERS:
        try:
            print(f"[INFO] Thu ket noi {server}...")
            req = urllib.request.Request(server, data=data_encoded, headers={'User-Agent': 'CodoKyHueApp/1.0'})
            with urllib.request.urlopen(req, timeout=35) as response:
                res = json.loads(response.read().decode('utf-8'))
                print(f"[SUCCESS] Ket noi thanh cong {server}")
                break
        except Exception as e:
            print(f"[WARN] Khong the ket noi {server}: {e}")

    if not res:
        print("[ERROR] Tat ca cac server Overpass deu ban hoac timeout!")
        return

    elements = res.get('elements', [])
    raw_places = []
    seen_ids = set()

    for element in elements:
        element_id = f"{element['type']}/{element['id']}"
        if element_id in seen_ids:
            continue
        seen_ids.add(element_id)

        tags = element.get('tags', {})
        name = tags.get('name')
        if not name:
            continue

        lat = element.get('lat') or (element.get('center', {}).get('lat'))
        lon = element.get('lon') or (element.get('center', {}).get('lon'))

        if not lat or not lon:
            continue

        name_lower = name.lower().strip()
        amenity = tags.get('amenity', '')
        historic = tags.get('historic', '')
        building = tags.get('building', '')
        religion = tags.get('religion', '')

        # Check non-buddhist worship (Church, Cathedral, Cao Dai, etc.)
        is_other_worship = (
            religion in ['christian', 'caodai', 'muslim', 'hindu'] or
            any(k in name_lower for k in ['nhà thờ', 'nha tho', 'thánh thất', 'thanh that', 'giáo xứ', 'giao xu', 'cathedral', 'church'])
        )

        if is_other_worship:
            category = 'worship_other'
        elif 'chùa' in name_lower or 'chua ' in name_lower or building in ['temple', 'pagoda'] or (amenity == 'place_of_worship' and religion == 'buddhist'):
            category = 'temple'
        elif 'lăng' in name_lower or 'lang ' in name_lower or historic == 'tomb':
            category = 'tomb'
        elif amenity in ['restaurant', 'cafe', 'fast_food', 'food_court']:
            category = 'restaurant'
        else:
            category = 'attraction'

        raw_places.append({
            'id': str(element['id']),
            'osm_type': element['type'],
            'name': name,
            'category': category,
            'latitude': lat,
            'longitude': lon,
            'address': tags.get('addr:street', 'Thừa Thiên Huế'),
            'rating': 4.5,
        })

    print(f"[INFO] Tong so ban ghi tho thu duoc tu Overpass: {len(raw_places)}")

    # Deduplication Logic: same name AND distance < 100 meters
    unique_places = []
    duplicate_pairs = []

    for item in raw_places:
        is_dup = False
        item_name = item['name'].strip().lower()

        for existing in unique_places:
            existing_name = existing['name'].strip().lower()
            if item_name == existing_name:
                dist = haversine_distance(item['latitude'], item['longitude'], existing['latitude'], existing['longitude'])
                if dist < 100.0:
                    is_dup = True
                    duplicate_pairs.append({
                        'name': item['name'],
                        'kept_id': existing['id'],
                        'kept_type': existing['osm_type'],
                        'removed_id': item['id'],
                        'removed_type': item['osm_type'],
                        'distance_meters': round(dist, 1)
                    })
                    break

        if not is_dup:
            unique_places.append(item)

    # Filter out 'worship_other' from final seed (or count it separately)
    final_seed = [p for p in unique_places if p['category'] != 'worship_other']

    # Clean unused debug keys before saving
    for p in final_seed:
        p.pop('osm_type', None)

    script_dir = os.path.dirname(__file__)
    assets_path = os.path.join(script_dir, '..', 'assets', 'data', 'hue_places_seed.json')
    script_path = os.path.join(script_dir, 'hue_places_seed.json')

    for path in [assets_path, script_path]:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(final_seed, f, ensure_ascii=False, indent=2)

    print("\n=================== BÁO CÁO CHI TIẾT PHO-PIPELINE DỮ LIỆU ===================")
    print(f"1. Tổng số bản ghi thô từ Overpass API: {len(raw_places)}")
    print(f"2. Số lượng bản ghi trùng lặp bị loại bỏ (distance < 100m & cùng tên): {len(duplicate_pairs)}")
    print("   Ví dụ các cặp trùng điển hình phát hiện:")
    for idx, dp in enumerate(duplicate_pairs[:5], 1):
        print(f"   - Cặp {idx}: '{dp['name']}' (Giữ ID {dp['kept_type']}/{dp['kept_id']}, Bỏ ID {dp['removed_type']}/{dp['removed_id']}, Khoảng cách: {dp['distance_meters']}m)")

    from collections import Counter
    all_cats = Counter(p['category'] for p in unique_places)
    print("\n3. Thống kê toàn bộ sau Dedupe (bao gồm worship_other):")
    for cat, count in all_cats.items():
        print(f"   - {cat}: {count}")

    seed_cats = Counter(p['category'] for p in final_seed)
    total_seed = len(final_seed)
    print(f"\n4. Thống kê SEED DATA CHÍNH THỨC trong assets/data/hue_places_seed.json ({total_seed} địa điểm):")
    for cat, count in seed_cats.items():
        pct = (count / total_seed) * 100
        print(f"   - {cat}: {count} ({pct:.2f}%)")
    print("========================================================================\n")

if __name__ == '__main__':
    fetch_hue_places()
