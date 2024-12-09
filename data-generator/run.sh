#!/bin/bash


CONTAINER_REGISTRY="registry.gitlab.com/dbishagen/unibench-ind-data-generator"
DOCKER_IMAGE_MONGO_NAME="mongo"
#DOCKER_IMAGE_MONGO_VERSION="4.4.29-focal-unibench-"
DOCKER_IMAGE_MONGO_VERSION="8.0.0-rc11-jammy-unibench-"
DOCKER_IMAGE_MYSQL_NAME="mysql"
DOCKER_IMAGE_MYSQL_VERSION="9.1.0-unibench-"
DOCKER_IMAGE_NEO4J_NAME="neo4j"
DOCKER_IMAGE_NEO4J_VERSION="5.25.1-unibench-"
DOCKER_IMAGE_POSTGRES_NAME="postgres"
DOCKER_IMAGE_POSTGRES_VERSION="17.1-unibench-"


# script path
SCRIPT_PATH=$(dirname $(realpath -s $0))

MONGODB_DATA_DIR_PATH=$(realpath -s ${SCRIPT_PATH}/docker/mongodb/mongodb_data)
MYSQL_DATA_DIR_PATH=$(realpath -s ${SCRIPT_PATH}/docker/mysql/mysql_data)
NEO4J_DATA_DIR_PATH=$(realpath -s ${SCRIPT_PATH}/docker/neo4j/neo4j_data)
POSTGRES_DATA_DIR_PATH=$(realpath -s ${SCRIPT_PATH}/docker/postgres/postgres_data)




function generate_data()
{
    # check if the folder data_sf_scale_str exist under the data directory
    if [ -d "$2" ]; then
        echo "Data for scale $1 already exists!"
        exit 0
    fi
    # create the folder data_sf_scale_str
    mkdir -p $2
    # generate data
    python ${SCRIPT_PATH}/scripts/gen-data.py $1
}




function import_data_into_dbs()
{
    local dbs=$1
    local data_dir_path=$2
    # loop over the list of databases and print each one
    for db in $(echo $dbs | sed "s/,/ /g")
    do
        printf "\nImporting data into $db ...\n"
        # case for each database
        case $db in
            "mongodb")
                rm -rf ${MONGODB_DATA_DIR_PATH}
                mkdir -p ${MONGODB_DATA_DIR_PATH}
                bash ${SCRIPT_PATH}/scripts/docker_import_mongodb.sh ${data_dir_path} ${MONGODB_DATA_DIR_PATH}
                ;;
            "mysql")
                rm -rf ${MYSQL_DATA_DIR_PATH}
                mkdir -p ${MYSQL_DATA_DIR_PATH}
                bash ${SCRIPT_PATH}/scripts/docker_import_mysql.sh ${data_dir_path} ${MYSQL_DATA_DIR_PATH}
                ;;
            "neo4j")
                rm -rf ${NEO4J_DATA_DIR_PATH}
                mkdir -p ${NEO4J_DATA_DIR_PATH}
                bash ${SCRIPT_PATH}/scripts/docker_import_neo4j.sh ${data_dir_path} ${NEO4J_DATA_DIR_PATH}
                ;; 
            "postgres")
                rm -rf ${POSTGRES_DATA_DIR_PATH}
                mkdir -p ${POSTGRES_DATA_DIR_PATH}
                bash ${SCRIPT_PATH}/scripts/docker_import_postgres.sh ${data_dir_path} ${POSTGRES_DATA_DIR_PATH}
                ;;
            *)
                echo "Error: $db is not a supported database"
                exit 1
                ;;
        esac
    done
}




function build_docker_image()
{
    for db in $(echo $1 | sed "s/,/ /g")
    do
        printf "\nBuilding Docker image for $db ...\n"
        # case for each database
        case $db in
            "mongodb")
                cd ${MONGODB_DATA_DIR_PATH}/../
                docker image build -t \
                ${CONTAINER_REGISTRY}/${DOCKER_IMAGE_MONGO_NAME}:${DOCKER_IMAGE_MONGO_VERSION}${scale} .
                cd ${SCRIPT_PATH}
                ;;
            "mysql")
                cd ${MYSQL_DATA_DIR_PATH}/../
                docker image build -t \
                ${CONTAINER_REGISTRY}/${DOCKER_IMAGE_MYSQL_NAME}:${DOCKER_IMAGE_MYSQL_VERSION}${scale} .
                cd ${SCRIPT_PATH}
                ;;
            "neo4j")
                cd ${NEO4J_DATA_DIR_PATH}/../
                docker image build -t \
                ${CONTAINER_REGISTRY}/${DOCKER_IMAGE_NEO4J_NAME}:${DOCKER_IMAGE_NEO4J_VERSION}${scale} .
                cd ${SCRIPT_PATH}
                ;;
            "postgres")
                cd ${POSTGRES_DATA_DIR_PATH}/../
                docker image build -t \
                ${CONTAINER_REGISTRY}/${DOCKER_IMAGE_POSTGRES_NAME}:${DOCKER_IMAGE_POSTGRES_VERSION}${scale} .
                cd ${SCRIPT_PATH}
                ;;
            *)
                echo "Error: $db is not a supported database"
                exit 1
                ;;
        esac
    done
}




function push_docker_image()
{
    for db in $(echo $1 | sed "s/,/ /g")
    do
        echo "Push Docker image for $db"
        # case for each database
        case $db in
            "mongodb")
                docker image push ${CONTAINER_REGISTRY}/${DOCKER_IMAGE_MONGO_NAME}:${DOCKER_IMAGE_MONGO_VERSION}${scale}
                ;;
            "mysql")
                docker image push ${CONTAINER_REGISTRY}/${DOCKER_IMAGE_MYSQL_NAME}:${DOCKER_IMAGE_MYSQL_VERSION}${scale}
                ;;
            "neo4j")
                docker image push ${CONTAINER_REGISTRY}/${DOCKER_IMAGE_NEO4J_NAME}:${DOCKER_IMAGE_NEO4J_VERSION}${scale}
                ;; 
            "postgres")
                docker image push ${CONTAINER_REGISTRY}/${DOCKER_IMAGE_POSTGRES_NAME}:${DOCKER_IMAGE_POSTGRES_VERSION}${scale}
                ;;
            *)
                echo "Error: $db is not a supported database"
                exit 1
                ;;
        esac
    done
}




function delete_docker_image()
{
    for db in $(echo $1 | sed "s/,/ /g")
    do
        echo "Delete Docker image for $db"
        # case for each database
        case $db in
            "mongodb")
                docker rmi ${CONTAINER_REGISTRY}/${DOCKER_IMAGE_MONGO_NAME}:${DOCKER_IMAGE_MONGO_VERSION}${scale}
                ;;
            "mysql")
                docker rmi ${CONTAINER_REGISTRY}/${DOCKER_IMAGE_MYSQL_NAME}:${DOCKER_IMAGE_MYSQL_VERSION}${scale}
                ;;
            "neo4j")
                docker rmi ${CONTAINER_REGISTRY}/${DOCKER_IMAGE_NEO4J_NAME}:${DOCKER_IMAGE_NEO4J_VERSION}${scale}
                ;;
            "postgres")
                docker rmi ${CONTAINER_REGISTRY}/${DOCKER_IMAGE_POSTGRES_NAME}:${DOCKER_IMAGE_POSTGRES_VERSION}${scale}
                ;;
            *)
                echo "Error: $db is not a supported database"
                exit 1
                ;;
        esac
    done
}



function print_help()
{
    echo "Usage: run.sh -s <scale> [-g] [-d <databases>] [-i] [-b] [-p] [-d]"
    echo "Options:"
    echo "  -h: Print this help message"
    echo "  -s: Scale factor"
    echo "  -g: Generate data"
    echo "  -l: Databases to use (comma separated list)"
    echo "  -i: Import data into databases"
    echo "  -b: Build Docker image"
    echo "  -p: Push Docker image"
    echo "  -d: Delete Docker image"
    echo "Example:"
    echo "  ./run.sh -s 0.01 -g -l mongodb,mysql,neo4j,postgres -i -b -p -d"
    exit 0
}



function main()
{
    scale=""
    generate=0
    dbs=""
    import_dbs=0
    build_docker_image=0
    push_docker_image=0
    delete_docker_image=0

    # parse command line arguments
    while getopts "hs:gl:ibpd" opt; do
        case $opt in
            h)
                print_help
                ;;
            s)
                scale=$OPTARG
                ;;
            g)
                generate=1
                ;;
            l)
                dbs=$OPTARG
                ;;
            i)
                import_dbs=1
                ;;
            b)
                build_docker_image=1
                ;;
            p)
                push_docker_image=1
                ;;
            d)
                delete_docker_image=1
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                exit 1
                ;;
        esac
    done

    # check if scale is set
    if [ -z "$scale" ]; then
        echo "Error: scale is not set"
        exit 1
    fi

    # check if scale is a number >= 0 and a float
    if ! [[ $scale =~ ^[0-9]+([.][0-9]+)?$ ]]; then
        echo "Error: scale is not a number >= 0"
        exit 1
    fi

    data_dir_path=$(realpath -s ${SCRIPT_PATH}/data/data_sf_$(echo $scale | sed 's/\./_/g'))

    printf "\n## Data Generator ##\n"
    printf "SCALE_FACTOR: $scale\n"
    printf "DATA_PATH: ${data_dir_path}\n"
    printf "TARGET_DBS: $dbs\n\n"

    # generate the data if the flag is set
    if [ $generate -eq 1 ]; then
        generate_data $scale $data_dir_path
    fi

    # check if dbs is set
    if ! [ -z "$dbs" ]; then
        # check if dbs is a list with at least one element
        if ! [[ $dbs =~ ^[a-zA-Z0-9_]+(,[a-zA-Z0-9_]+)*$ ]]; then
            echo "Error: dbs is not a list"
            exit 1
        else
            # import the data into the databases if the flag is set
            if [ $import_dbs -eq 1 ]; then
                import_data_into_dbs $dbs $data_dir_path
            fi

            # build the docker image if the flag is set
            if [ $build_docker_image -eq 1 ]; then
                build_docker_image $dbs
            fi

            # push the docker image if the flag is set
            if [ $push_docker_image -eq 1 ]; then
                push_docker_image $dbs
            fi

            # delete the docker image if the flag is set
            if [ $delete_docker_image -eq 1 ]; then
                delete_docker_image $dbs
            fi
        fi
    fi
}




# execute main
main "$@"

