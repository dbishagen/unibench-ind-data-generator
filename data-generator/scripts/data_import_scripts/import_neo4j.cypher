


// cat import_neo4j.cypher | cypher-shell -u neo4j -p neo4jpassword -d neo4j


// All nodes and relationships.
MATCH (n) DETACH DELETE n;


LOAD CSV FROM 'file:////data/person.csv' AS row
MERGE (p:Person {person_id: toInteger(row[0]), mail: row[1]})
RETURN p.person_id, p.mail, p.username;

LOAD CSV FROM 'file:////data/tag.csv' AS row
MERGE (t:Tag {tag_id: toInteger(row[0]), name : row[1], vendors: toStringList(split(row[2], ';')), vendor_ids: toIntegerList(split(row[3], ';'))})
RETURN t.tag_id, t.name, t.vendors, t.vendor_ids;

LOAD CSV FROM 'file:////data/HAS_INTEREST.csv' AS row
MATCH (p:Person {person_id: toInteger(row[0])}), (t:Tag {tag_id: toInteger(row[1])})
MERGE (p)-[:HAS_INTEREST]->(t)
RETURN p.person_id, t.tag_id;


MATCH (p:Person)
REMOVE p.username;