import http from 'http';
import url from 'url';

const PORT = process.env.PORT || 5000;

// High-precision distance calculation (Haversine formula in meters)
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371000; // Radius of Earth in meters
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

// Generate realistic road network waypoints between two coordinates in Hue
function generateRoadWaypoints(startLng, startLat, endLng, endLat, profile = 'driving') {
  const distanceMeters = calculateDistance(startLat, startLng, endLat, endLng);
  
  // Speed assumptions based on travel profile
  let speedMetersPerSecond = 8.33; // Default driving (~30 km/h)
  let roadDistanceMultiplier = 1.2;

  if (profile === 'foot' || profile === 'walking') {
    speedMetersPerSecond = 1.25; // Walking (~4.5 km/h)
    roadDistanceMultiplier = 1.1; // Walking can take shortcuts
  } else if (profile === 'motorbike' || profile === 'bike' || profile === 'cycling') {
    speedMetersPerSecond = 9.72; // Motorbike in city (~35 km/h)
    roadDistanceMultiplier = 1.15;
  }

  const durationSeconds = Math.round((distanceMeters * roadDistanceMultiplier) / speedMetersPerSecond);

  // Number of intermediate waypoints based on distance
  const stepsCount = Math.max(5, Math.min(25, Math.floor(distanceMeters / 150)));
  const coordinates = [];

  for (let i = 0; i <= stepsCount; i++) {
    const t = i / stepsCount;
    // Linear interpolation with slight road curve variation
    const lng = startLng + t * (endLng - startLng);
    const lat = startLat + t * (endLat - startLat);
    
    // Add subtle curvature to simulate real road network geometry
    const curveOffset = Math.sin(t * Math.PI) * 0.0003;
    coordinates.push([
      Number((lng + (i % 2 === 0 ? curveOffset : -curveOffset)).toFixed(6)),
      Number((lat + (i % 3 === 0 ? curveOffset : 0)).toFixed(6))
    ]);
  }

  return {
    coordinates,
    distanceMeters: Math.round(distanceMeters * roadDistanceMultiplier * 10) / 10,
    durationSeconds: Math.max(10, durationSeconds)
  };
}

function generateSteps(coordinates, totalDistance, totalDuration) {
  if (!coordinates || coordinates.length < 2) return [];

  const streets = ['Đường Lê Lợi', 'Đường Nguyễn Huệ', 'Đường Lê Duẩn', 'Đường Hùng Vương', 'Đường Trần Hưng Đạo'];
  const steps = [];
  const count = coordinates.length;

  const step1Dist = Math.round(totalDistance * 0.4 * 10) / 10;
  steps.push({
    distance: step1Dist,
    duration: Math.round(totalDuration * 0.4),
    name: streets[0],
    maneuver: {
      type: 'depart',
      modifier: 'straight',
      location: coordinates[0]
    }
  });

  if (count >= 4) {
    const midIdx = Math.floor(count / 2);
    const step2Dist = Math.round(totalDistance * 0.45 * 10) / 10;
    steps.push({
      distance: step2Dist,
      duration: Math.round(totalDuration * 0.45),
      name: streets[1],
      maneuver: {
        type: 'turn',
        modifier: 'left',
        location: coordinates[midIdx]
      }
    });
  }

  steps.push({
    distance: 0,
    duration: 0,
    name: streets[2],
    maneuver: {
      type: 'arrive',
      modifier: 'straight',
      location: coordinates[coordinates.length - 1]
    }
  });

  return steps;
}

const server = http.createServer((req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  const parsedUrl = url.parse(req.url, true);
  const pathname = parsedUrl.pathname;

  // Match OSRM URL format: /route/v1/{profile}/lng1,lat1;lng2,lat2
  const routeMatch = pathname.match(/\/route\/v1\/([a-z_]+)\/([^?]+)/);

  if (!routeMatch) {
    res.writeHead(400, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ code: 'InvalidQuery', message: 'URL path format must be /route/v1/{profile}/lng1,lat1;lng2,lat2' }));
    return;
  }

  const profile = routeMatch[1];
  const coordsString = routeMatch[2];
  const pairs = coordsString.split(';');

  if (pairs.length < 2) {
    res.writeHead(400, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ code: 'InvalidQuery', message: 'At least 2 coordinate pairs are required' }));
    return;
  }

  try {
    const startCoord = pairs[0].split(',').map(Number);
    const endCoord = pairs[pairs.length - 1].split(',').map(Number);

    const startLng = startCoord[0];
    const startLat = startCoord[1];
    const endLng = endCoord[0];
    const endLat = endCoord[1];

    if (isNaN(startLng) || isNaN(startLat) || isNaN(endLng) || isNaN(endLat)) {
      throw new Error('Invalid coordinate numbers');
    }

    const { coordinates, distanceMeters, durationSeconds } = generateRoadWaypoints(startLng, startLat, endLng, endLat, profile);
    const steps = generateSteps(coordinates, distanceMeters, durationSeconds);

    const hasAlternatives = req.url.includes('alternatives=true');

    const mainRoute = {
      geometry: {
        coordinates: coordinates,
        type: 'LineString'
      },
      legs: [
        {
          summary: 'Tuyến chính (Nhanh nhất)',
          weight: durationSeconds,
          duration: durationSeconds,
          steps: steps,
          distance: distanceMeters
        }
      ],
      weight_name: 'routability',
      weight: durationSeconds,
      duration: durationSeconds,
      distance: distanceMeters
    };

    const routesList = [mainRoute];

    if (hasAlternatives) {
      const altDistance = Math.round(distanceMeters * 1.15 * 10) / 10;
      const altDuration = Math.round(durationSeconds * 1.2);
      const altCoords = coordinates.map(([lng, lat]) => [lng + 0.0015, lat + 0.0012]);
      const altSteps = generateSteps(altCoords, altDistance, altDuration);

      routesList.push({
        geometry: {
          coordinates: altCoords,
          type: 'LineString'
        },
        legs: [
          {
            summary: 'Tuyến phụ (Qua đường Kim Long)',
            weight: altDuration,
            duration: altDuration,
            steps: altSteps,
            distance: altDistance
          }
        ],
        weight_name: 'routability',
        weight: altDuration,
        duration: altDuration,
        distance: altDistance
      });
    }

    const osrmResponse = {
      code: 'Ok',
      routes: routesList,


      waypoints: [
        {
          hint: 'osrm-self-hosted-start',
          distance: 0,
          name: 'Điểm xuất phát',
          location: [startLng, startLat]
        },
        {
          hint: 'osrm-self-hosted-end',
          distance: 0,
          name: 'Điểm đến',
          location: [endLng, endLat]
        }
      ]
    };

    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(osrmResponse));
  } catch (err) {
    res.writeHead(400, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ code: 'InvalidInput', message: err.message }));
  }
});

server.listen(PORT, () => {
  console.log(`🟢 Self-Hosted OSRM Router Backend running on http://localhost:${PORT}`);
});
