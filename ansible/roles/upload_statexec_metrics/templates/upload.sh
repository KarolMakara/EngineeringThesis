find ${METRICS_PATH} -type f -name "*.prom" -print0 | while IFS= read -r -d '' file; do

    # Find instance name
    instance=$(grep -Eo 'instance="[^"]+"' $file | head -n 1 | awk -F'"' '{print $2}'  )
    role=$(grep -Eo 'role="[^"]+"' $file | head -n 1 | awk -F'"' '{print $2}'  )

    # Prometheus metrics
    curl -X POST ${VMSERVER}/api/v1/import/prometheus -T "$file" \
        || { echo "Cannot import $file" ;  exit 1; }

    # Grafana annotations
    grep "^#grafana-annotation" $file | while IFS= read -r line; do
        # Format: #grafana-annotation <annotation>
        annotation=$(echo $line | sed 's/^#grafana-annotation //')
        curl -so /dev/null -X POST -H "Content-Type: application/json" -d "${annotation}" http://${GRAFANA}/api/annotations \
            || { echo "Cannot create grafana annotations from $file" ;  exit 1; }
    done
done