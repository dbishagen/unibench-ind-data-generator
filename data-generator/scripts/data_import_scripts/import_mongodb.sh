#!/bin/bash


mongoimport --drop --db unibench --collection Order --jsonArray /import/order.json