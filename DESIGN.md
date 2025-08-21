# Design Document

By Minh Uyen Nhi Nguyen

Video overview: https://youtu.be/ZnrWdcMEuP8

## Scope

This database stores information on industrial zones in Vietnam for three primary purposes:
* To support manufacturing and consulting firms in evaluating and selecting suitable locations for future manufacturing operations.
* To enable economists and researchers to analyze trends and dynamics within the manufacturing sector.
* To assist government authorities in monitoring, managing, and optimizing land use and productivity for industrial purposes.

The scope of this database includes:
* Industrial zones, with basic identifying information and infrastructure/utility data.
* Developers, including core identification details.
* Provincial industrial zone management boards, with associated identifiers.
* Provinces of Vietnam, along with their corresponding management boards and industrial zones (if any).
* Available land plots, detailing their location within zones/clusters and their dimensions.
* Permitted or promoted industry sectors for each zone.
* Zone development data, including the developer, the associated zone, year of infrastructure commencement, and expected year of completion.

Out of scope are elements such as:
* Workforce or talent availability in the area
* Land prices or lease costs
* Individual companies operating within the zones
* Industrial clusters

## Functional Requirements

Developers are allowed to update information related to the industrial zones they manage. This includes details about available land plots, industry sectors being promoted or restricted within the zone, and progress updates if the zone is under development. However, developers cannot edit zones managed by other developers, nor can they modify information about other developers or government authorities.

Industrial Zone Management Boards (IZMBs) act as database administrators for their respective provinces. They are responsible for managing provincial-level data, such as industrial zones, developer assignments, and management board details. IZMBs can approve or reject updates submitted by developers and track land use and development progress within their jurisdiction. However, they cannot alter commercial data submitted by developers—such as specific land availability figures—and they are restricted from editing data belonging to other provinces.

Economists, researchers, and consultants have view-only access. They can search, filter, and review data on industrial zones, permitted sectors, and development timelines for analytical or advisory purposes. However, they do not have permission to modify or submit any data within the system.

## Representation

Entities are captured in SQLite tables with the following schema.

### Entities

The database includes the following entities:

#### Developers

The `developers` table include:
* `id`, which specifies the unique ID for the developer as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `name`, which shows the name of the developer as `TEXT`. Name is a must, so this has a `NOT NULL` constraint.
* `website`, which gives the official link of the developer company as `TEXT`. Some companies do not have website, so this can be null.

#### Provinces

The `provinces` table include:
* `id`, which specifies the unique ID for the province as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `name`, which shows the name of the province as `TEXT`. Name is a must, so this has a `NOT NULL` constraint. Each province name is unique, so `UNIQUE` constraint is applied.
* `code`, which contains the provincial code as Vietnam administration system regulates as `INTEGER`. This is consistent, publicly available and essential for government reports, so it has a `NOT NULL` constraints.

#### Industrial Zones

The `industrial_zones` table includes:
* `id`, which specifies the unique ID for the zone as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `name`, which shows the name of the zones as `TEXT`. Name is a must, so this has a `NOT NULL` constraint.
* `province_id`, which contains the provincial ID that the zone locates in as an `INTEGER`. This column is a foreign key reference to the `id` field in `provinces` table to ensure data integrity.
* `is_active`, which indicates whether the zone is ready to welcome secondary investors as `TEXT`. This must be filled, hence being applied a `NOT NULL` constraint. Moreover, it is applied another constraint to check if its value is either 'Y', 'N' (yes or no).
* `area`, which specifies the total areas in ha for facility construction as `NUMERIC`. This is important, as some investors may require a site in a major/big zone. Therefore, it has a `NOT NULL` constraint.
* `water`, which shows the current supply of water in m3 per day and night at the zone as `NUMERIC`.
* `electricity`, which specifies the current supply of electricity in MWH at the zone as `NUMERIC`.
* `wastewater`, which contains the capacity of wastewater treatment in m3 of the zone per day and night as `NUMERIC`.
* `expired_year`, which specifies the expected last year the zone is granted use for industrial use as `INTEGER`.
* `lat`, which indicates the latitude of the zone as `REAL`, as latitude can be expressed as something like xx.xxxxxx using GG Maps. This is not always available, especially for zones in planning stage, so no constraints.
* `long`, which indicates the longtitude of the zone as `REAL`. Same reasons as `lat`.

#### Develop Zones

The `develop_zones` table includes:
* `id`, which specifies the unique ID for zone development as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `developer_id`, which shows the developer ID as `INTEGER`. This column is a foreign key reference to the `id` field in `developers` table to ensure data integrity. This foreign key has `ON DELETE RESTRICT` to prevent deletion of a developer while there is still a zone development tied to it.
* `zone_id`, which specifies the zone ID that the developer has/had developed as `INTEGER`. This column is a foreign key reference to the `id` field in `industrial_zones` table to ensure data integrity.
* `start_year`, which stores the year that the developer will/started construction of infrastructure in that zone as `INTEGER`.
* `end_year`, which stores the year that the developer is expected to complete/has completed construction of infrastructure in that zone as `INTEGER`.
* `is_valid`, which indicates whether the developer is still granted the right to develop that zone or if it has been provoked as `TEXT`. This must be filled, hence being applied a `NOT NULL` constraint. Moreover, it is applied another constraint to check if its value is either 'Y', 'N' (yes or no).

#### Available Plots

The `available_plots` table includes:
* `id`, which specifies the unique ID for the plot as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `identifier`, which shows the code/identifiers the developer give the plot as `TEXT`. This has `NOT NULL` constraint.
* `zone_id`, which contains the zone ID that the plot locates in as an `INTEGER`. This column is a foreign key reference to the `id` field in `industrial_zones` table to ensure data integrity. This foreign key has `ON DELETE CASCADE`, as the removal of a zone should remove associated available plots as well.
* `area`, which indicates the area of the available plot in ha as `NUMERIC`. This must be filled for reference, hence `NOT NULL` constraint is applied.

#### Industrial Zone Management Boards (IZMBs)

The `izmbs` table includes:
* `id`, which specifies the unique ID for the IZMB as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `name`, which shows the name of the IZMB as `TEXT`. Name is a must, so `NOT NULL` constraint is applied.
* `province_id`, which specifies the zone ID that the IZMB has authority in as `INTEGER`. This column is a foreign key reference to the `id` field in `industrial_zones` table to ensure data integrity.

#### Sectors

The `sectors` table includes:
* `id`, which specifies the unique ID for the each industry sector as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `name`, which indicates the name of the industry sector as `TEXT` such as chemical and F&B. Name is a must, so `NOT NULL` constraint is applied.

#### Regulate

The `regulate` table includes:
* `id`, which specifies the unique ID for each sector regulation of the zone as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `zone_id`, which indicate the zone ID as `INTEGER`. This column is a foreign key reference to the `id` field in `industrial_zones` table to ensure data integrity.
* `sector_id`, which indicate the sector ID that the zone has specified their regulation about as `INTEGER`. This column is a foreign key reference to the `id` field in `sectors` table to ensure data integrity. This foreign key has `ON DELETE RESTRICT` to prevent deletion of a sector while there is still a regulation tied to it.
* `regulate`, which shows the regulation policy of the zone on the sector as `TEXT`. This must be filled, hence being applied a `NOT NULL` constraint. Moreover, it is applied another constraint to check if its value is either 'promote' or 'prohibit'.

#### Deleted Plots
The `deleted_plots` serves as an archive for any deletion on `available_plots` table to ensure data consistency. The table includes:
* `id`, which specifies the unique ID for the deletion of a plot as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `original_id`, which stores the original ID of the deleted plot in the `available_plots` table for reference as `INTEGER`. As ID is never `NOT NULL`, this is `NOT NULL` as well.
* `identifier`, which shows the code/identifiers the developer give the deleted plot as `TEXT`. This has `NOT NULL` constraint.
* `zone_id`, which contains the zone ID that the deleted plot locates in as an `INTEGER`. This column is a foreign key reference to the `id` field in `industrial_zones` table to ensure data integrity.
* `area`, which indicates the area of the deleted plot in ha as `NUMERIC`. This must be filled for reference, hence `NOT NULL` constraint is applied.
* `delete_time`, which indicates the time of deletion of said plot as `DATETIME`. The default time is the timestamp at which the trigger to archive the plot after deletion in `available_plots` table.

### Relationships

The below entity relationship diagram describes the relationships among the entities in the database.

![ER Diagram](diagram.png)

As detailed by the diagram:
* An industrial zone can only locate in one province. However, a province can have zero to many industrial zones.
* A developer can be the investors of zero or many zones at the same time. A zone itself can have zero (if the government has not approved any investment policy for the zone) or many developers at the same time.
* An industrial zone can be fully occupied, meaning having zero available plots, or have one to many available plots ready to be leased. However, one plot can only locate in one zone.
* A province can have zero or one IZMB overseeing the development of industrial lands in the province. One IZMB can oversee just one province.
* A zone can have special regulations (prohibit or promote) for no or many industry sectors, as the goverment regulates. One sector can be prohibited or promoted by many zones at the same time. In cases where a zone simply allows the sector, there is no need to include such data.

## Optimizations

Several indexes were created based on expected query patterns, particularly on fields used frequently in WHERE, JOIN, and ORDER BY clauses:
* `infrastructure_index` is used to speed up filtering zones based on infrastructure availability.
* `sector_regulate_index` aims to optimize lookups for whether a sector is promoted or prohibited in a zone.
* `zone_index` supports fast lookup of zones by name, useful in nested subqueries.
* `is_active_index` accelerates queries filtering for currently active zones.

A view on active zones was provided to simplify reporting and dashboards, as users typically focus on zones that are currently operational rather than expired or in planning.

A trigger was implemented to record all historical data on deletion of available plots. The trigger automatically copies a deleted `available_plots` entry into the `deleted_plots` archive table.It helps ensure traceability and non-destructive deletions.

## Limitations

Some limitations are as below:
* Limited tracking of historical records: For now, it only archives deletion of available plots.
* No access control: The design assumes full access for querying and modifying data.
* Limited geospatial capabilities: the database does not support spatial data types or queries (e.g., proximity search, zone boundaries).
* Too simple input validation: For fields like `regulate` or `active`, the status can be very complicated sometimes. With the default values, the database cannot capture well exceptional cases.
* No financial or operational data: Critical factors like lease prices, operating companies, workforce availability, or economic performance of zones are out of scope.
