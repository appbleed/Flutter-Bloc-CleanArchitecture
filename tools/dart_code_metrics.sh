#!/bin/bash

check_metrics() {
    local module=$1
    echo "metrics_$module running..."
    local metrics_output
    metrics_output=$(make "metrics_$module")
    echo "$metrics_output"

    if echo "$metrics_output" | grep -iq "Warning"; then
        echo "*** METRICS_${module^^}_ERROR contain Warning***: $metrics_output"
        exit 1
    fi

    if echo "$metrics_output" | grep -iq "Alarm"; then
        echo "*** METRICS_${module^^}_ERROR contain Alarm***: $metrics_output"
        exit 1
    fi

    echo "*** METRICS_${module^^}_SUCCESS ***"
    echo ""
}

modules=("app" "data" "domain" "shared")

for module in "${modules[@]}"; do
    check_metrics "$module"
done