#! /bin/bash
kill $(jps | grep -i "SparkSubmit" | tr -cd "[0-9]") || echo "no spark run"
