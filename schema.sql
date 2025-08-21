-- Represent the developers.
CREATE TABLE "developers" (
    "id" INTEGER PRIMARY KEY,
    "name" TEXT NOT NULL,
    "website" TEXT DEFAULT NULL
);

-- Represent the provinces of Vietnam.
CREATE TABLE "provinces" (
    "id" INTEGER PRIMARY KEY,
    "name" TEXT NOT NULL UNIQUE,
    "code" INTEGER NOT NULL
);

-- Represent the industrial zones and its frastructure.
CREATE TABLE "industrial_zones" (
    "id" INTEGER PRIMARY KEY,
    "name" TEXT NOT NULL,
    "province_id" INTEGER,
    "is_active" TEXT NOT NULL CHECK("is_active" IN ('Y', 'N')),
    "area" NUMERIC NOT NULL,
    "water" NUMERIC,
    "electricity" NUMERIC,
    "wastewater" NUMERIC,
    "expired_year" INTEGER,
    "lat" REAL,
    "long" REAL,
    FOREIGN KEY ("province_id") REFERENCES "provinces"("id")
);

-- Represent the development of each zone throughout the years.
CREATE TABLE "develop_zones" (
    "id" INTEGER PRIMARY KEY,
    "developer_id" INTEGER,
    "zone_id" INTEGER,
    "start_year" INTEGER,
    "end_year" INTEGER,
    "is_valid" TEXT NOT NULL CHECK("is_valid" IN ('Y', 'N')),
    FOREIGN KEY ("zone_id") REFERENCES "industrial_zones"("id"),
    FOREIGN KEY ("developer_id") REFERENCES "developers"("id") ON DELETE RESTRICT
);

-- Represent current available industrial zone plots in Vietnam.
CREATE TABLE "available_plots" (
    "id" INTEGER PRIMARY KEY,
    "identifier" INTEGER NOT NULL,
    "zone_id" INTEGER NOT NULL,
    "area" NUMERIC NOT NULL,
    FOREIGN KEY ("zone_id") REFERENCES "industrial_zones"("id") ON DELETE CASCADE
);

-- Represent the Industrial Zone Management Board of each province.
CREATE TABLE "izmbs" (
    "id" INTEGER PRIMARY KEY,
    "name" TEXT NOT NULL,
    "province_id" INTEGER,
    FOREIGN KEY ("province_id") REFERENCES "provinces"("id")
);

-- Represent all the sectors according to a chosen standard, such as GICS.
CREATE TABLE "sectors" (
    "id" INTEGER PRIMARY KEY,
    "name" TEXT NOT NULL
);

-- Represent the special regulation industrial zones have for the sectors.
CREATE TABLE "regulate" (
    "id" INTEGER PRIMARY KEY,
    "zone_id" INTEGER,
    "sector_id" INTEGER,
    "regulate" TEXT NOT NULL CHECK("regulate" IN ('promote', 'prohibit')),
    FOREIGN KEY ("zone_id") REFERENCES "industrial_zones"("id"),
    FOREIGN KEY ("sector_id") REFERENCES "sectors"("id") ON DELETE RESTRICT
);

-- Archive deleted plots from "available_plots" table.
CREATE TABLE "deleted_plots" (
    "id" INTEGER PRIMARY KEY,
    "original_id" INTEGER NOT NULL,
    "identifier" INTEGER NOT NULL,
    "zone_id" INTEGER NOT NULL,
    "area" NUMERIC NOT NULL,
    "delete_time" DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("zone_id") REFERENCES "industrial_zones"("id")
);

-- Create indexes for common queries to improve performance.
CREATE INDEX "infrastructure_index"
ON "industrial_zones"("water", "electricity", "wastewater");

CREATE INDEX "sector_regulate_index"
ON "regulate"("zone_id", "sector_id", "regulate");

CREATE INDEX "zone_index"
ON "industrial_zones"("name");

CREATE INDEX "is_active_index"
ON "industrial_zones"("is_active");

-- Create trigger to automatically add deleted plot once a user delete an available plot.
CREATE TRIGGER archived_deleted_plots
AFTER DELETE ON "available_plots"
BEGIN
    INSERT INTO "deleted_plots" ("original_id", "identifier", "zone_id", "area")
    VALUES (OLD."id", OLD."identifier", OLD."zone_id", OLD."area");
END;

-- Create a view for active zones.
CREATE VIEW "active_zones" AS
SELECT "industrial_zones"."name" AS "Active Zones",
        "provinces"."name" AS "Provinces",
        "industrial_zones"."area" AS "Area",
        "industrial_zones"."water" AS "Water (m3)",
        "industrial_zones"."electricity" AS "Electricity (MWH)",
        "industrial_zones"."wastewater" AS "Wastewater (m3)",
        "industrial_zones"."expired_year" AS "Expiration Year"
FROM "industrial_zones"
JOIN "provinces" ON "provinces"."id" = "industrial_zones"."province_id"
WHERE "industrial_zones"."is_active" = 'Y'
ORDER BY "Active Zones" ASC, "Provinces" ASC;
