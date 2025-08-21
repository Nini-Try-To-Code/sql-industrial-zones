-- Query to search for suitable available plots given criteria.
SELECT "available_plots"."identifier" AS "Available Plots",
        "industrial_zones"."name" AS "Industrial Zones",
        "provinces"."name" AS "Provinces",
        "available_plots"."area" AS "Area"
FROM "available_plots"
JOIN "industrial_zones" ON "industrial_zones"."id" = "available_plots"."zone_id"
JOIN "provinces" ON "provinces"."id" = "industrial_zones"."province_id"
WHERE "industrial_zones"."is_active" = 'Y'
AND "available_plots"."area" BETWEEN 10 AND 20
AND "provinces"."name" IN ('Bac Ninh', 'Hai Phong', 'Ha Noi')
AND "industrial_zones"."water" > 18000
AND "industrial_zones"."electricity" > 64
AND "industrial_zones"."wastewater" > 8000
AND NOT EXISTS (
    SELECT 1
    FROM "regulate"
    JOIN "sectors" ON "sectors"."id" = "regulate"."sector_id"
    WHERE LOWER("sectors"."name") LIKE '%chemical%'
    AND "regulate"."regulate" = 'prohibit'
)
ORDER BY "Available Plots" ASC;

-- Query to search for current developers given the name of the industrial zone.
SELECT "name" AS "Developers", "website" AS "Website"
FROM "developers"
WHERE "id" = (
    SELECT "developer_id"
    FROM "develop_zones"
    WHERE "zone_id" = (
        SELECT "id"
        FROM "industrial_zones"
        WHERE "name" = 'Thanh Khe'
    )
    AND "is_valid" = 'Y'
);

-- Query to search for authority of a given zone.
SELECT "name" AS "Industrial Zone Management Boards",
        "provinces"."name" AS "Provinces"
FROM "izmbs"
JOIN "provinces" ON "provinces"."id" = "izmbs"."province_id"
WHERE "provinces"."id" = (
    SELECT "province_id"
    FROM "industrial_zones"
    WHERE "name" = 'Thanh Khe'
);

-- Query to retrieve coordinates data of all zones based on active status for GIS mapping.
SELECT "name", "lat", "long", "area"
FROM "industrial_zones"
WHERE "is_active" = 'Y';

-- Query to find zones completing infrastructure and open to investors in a given year.
SELECT "industrial_zones"."name" AS "Industrial Zones",
        "provinces"."name" AS "Provinces",
        "industrial_zones"."is_active" AS "Active Status"
FROM "industrial_zones"
JOIN "provinces" ON "provinces"."id" = "industrial_zones"."province_id"
JOIN "develop_zones" ON "develop_zones"."zone_id" = "industrial_zones"."id"
WHERE "develop_zones"."end_year" = 2026;

-- Query to find most populat sectors that zones promote or prohibit.
SELECT "sectors"."name" AS "Sectors", COUNT(*) AS "No of Zones Promoting"
FROM "sectors"
JOIN "regulate" ON "regulate"."sector_id" = "sectors"."id"
WHERE "regulate" = 'promote'
GROUP BY "sectors"."name"
ORDER BY "No of Zones Promoting" DESC, "Sectors" ASC
LIMIT 30;

-- Query to find provinces with the largest industrial zone area.
SELECT "provinces"."name" AS "Provinces",
        SUM("industrial_zones"."area") AS "Total IZ Area"
FROM "industrial_zones"
JOIN "provinces" ON "provinces"."id" = "industrial_zones"."province_id"
GROUP BY "provinces"."name"
ORDER BY "Total IZ Area" DESC, "Provinces" ASC
LIMIT 10;

-- Add a new available plot
INSERT INTO "available_plots" ("identifier", "zone_id", "area")
VALUES ('D6', 67, 15);

-- Add newly approved zone.
INSERT INTO "industrial_zones" ("name", "province_id", "is_active", "area")
VALUES ('Son Hoang', 45, 'N', 699);

-- Update data for zones with master plan or infrastructure in place.
UPDATE "industrial_zones"
SET "water" = 20000,
    "electricity" = 120,
    "wastewater" = 6000,
    "lat" = 10.848756678335652,
    "long" = 106.74806359269144
WHERE "name" = 'Son Hoang';

-- Add a new sector the zone want to promote/prohibit.
INSERT INTO "regulate" ("zone_id", "sector_id", "regulate")
VALUES (35, 55, 'promote');

-- Remove a plot that is no longer available.
DELETE FROM "available_plots"
WHERE "identifier" = 'E5'
AND "zone_id" = 25;
