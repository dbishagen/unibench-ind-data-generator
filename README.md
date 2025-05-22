
# UniBench Test Data for Detection of Inclusion Dependencies

This repository contains test data for the detection of inclusion dependencies. The data set is based on the UniBench data set and is generated with the data generator provided in this repository. The data generator is written in Python and uses the Faker library.
The data is already imported into the databases which are provided as docker images.


**Contents:**

- [UniBench Test Data for Detection of Inclusion Dependencies](#unibench-test-data-for-detection-of-inclusion-dependencies)
  - [Quick Start](#quick-start)
  - [Test Data](#test-data)
  - [Data Generator](#data-generator)
    - [Installation](#installation)
    - [Usage](#usage)

## Quick Start

To start the databases with a scale factor of 0.01, run the following command:
```bash
DATA_SIZE=0.01 docker compose up
```

## Test Data

The following figure shows the UML diagram of the test data:

![UML diagram of the Unibench testdata](doc/test_data_diagram-v2.png)

The data is already imported into the databases which are provided as docker images.
There are also data sets in different sizes available:


| Scale Factor | Person / Customer | Order / Invoice | Vendor | Post  | Tag |
|--------------|-------------------|-----------------|--------|-------|-----|
| 0.0          | 4                 | 8               | 66     | 8     | 8   |
| 0.01         | 99                | 1422            | 66     | 12319 | 90  |
| 0.02         | 198               | 2845            | 66     | 24639 | 180 |
| 0.03         | 298               | 4267            | 66     | 36959 | 272 |
| 0.04         | 397               | 5690            | 66     | 49279 | 363 |


The following table shows the default credentials for the databases:

| Database | Username | Password      | Database Name |
|----------|----------|---------------|---------------|
| MySQL    | root     | root          | unibench      |
| Postgres | postgres | root          | unibench      |
| MongoDB  | -        | -             | unibench      |
| Neo4j    | neo4j    | neo4jpassword | neo4j         |



The following uml diagram shows the schema of the databases after the data import:

![UML diagram of the Unibench testdata after import](doc/test_data_diagram_dbs-v2.png)


The following figure shows the inclusion dependencies in the data set. The bold arrows with numbers indicate dependencies that always hold, while the small arrows with letters indicate dependencies that do not always hold.

![Inclusion dependencies in the Unibench testdata](doc/inclusion_dependencies_graph.png)

The following list shows the inclusion dependencies which are in the data set with scale factor 0.0:

```plaintext
PostgreSQL.customer.[mail]            ->  neo4j.Person.[mail]
neo4j.Person.[mail]                   ->  PostgreSQL.customer.[mail]
neo4j.Person.[person_id]              ->  PostgreSQL.customer.[customer_id]
PostgreSQL.customer.[customer_id]     ->  neo4j.Person.[person_id]
PostgreSQL.invoice.[customer_id]      ->  PostgreSQL.customer.[customer_id]
PostgreSQL.invoice.[customer_id]      ->  neo4j.Person.[person_id]
MongoDB.Order.[c_id]                  ->  PostgreSQL.invoice.[customer_id]
PostgreSQL.invoice.[customer_id]      ->  MongoDB.Order.[c_id]
MongoDB.Order.[c_id]                  ->  PostgreSQL.customer.[customer_id]
MongoDB.Order.[c_id]                  ->  neo4j.Person.[person_id]
MongoDB.Order.[_id]                   ->  PostgreSQL.invoice.[order_id]
PostgreSQL.invoice.[order_id]         ->  MongoDB.Order.[_id]
MongoDB.Order.[username]              ->  PostgreSQL.invoice.[username]
PostgreSQL.invoice.[username]         ->  MongoDB.Order.[username]
PostgreSQL.invoice.[username]         ->  PostgreSQL.customer.[username]
MongoDB.Order.[username]              ->  PostgreSQL.customer.[username]
MongoDB.vendor.[brand_id]             ->  PostgreSQL.vendor.[vendor_id]
MongoDB.vendor.[brand]                ->  PostgreSQL.vendor.[vendor]
neo4j.Tag.[vendors]                   ->  PostgreSQL.vendor.[vendor]
neo4j.Tag.[vendor_ids]                ->  PostgreSQL.vendor.[vendor_id]
```


## Data Generator

The data generator is written in Python and uses the Faker library to generate the data.

### Installation

Change to the data-generator directory
```bash
cd data-generator
```

Setup the venv
```bash
python -m venv venv
```

Activate the venv
```bash
source venv/bin/activate
```

Install the requirements
```bash
pip install -r requirements.txt
```

### Usage

To only generate the data run the data generator with the required scale factor and `-g` flag:
```bash
./run.sh -s 0.0 -g
```

To import the data into the databases and also build the docker images, run the data generator with the following command:
```bash
./run.sh -s 0.0 -l mongodb,neo4j,mysql,postgres -i -b
```
