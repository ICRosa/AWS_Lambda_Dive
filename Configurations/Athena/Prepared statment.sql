PREPARE hourly_query FROM
SELECT count("created_at") FROM "gha-db"."ghadata.ghactivity" WHERE created_at BETWEEN ? AND ?