#!/bin/zsh
declare -A version_maps
echo "${ZSH_VERSION}"
parent_path=$( cd "$(dirname "${(%):-%N}")" ; pwd -P ) # nals_flutter_project_template/tools
root_project_path=$(dirname $parent_path)

# echo $root_project_path

pubspec_app_path="$root_project_path/app/pubspec.yaml"
# echo $pubspec_app_path
pubspec_data_path="$root_project_path/data/pubspec.yaml"
pubspec_domain_path="$root_project_path/domain/pubspec.yaml"
pubspec_shared_path="$root_project_path/shared/pubspec.yaml"
pubspec_initializer_path="$root_project_path/initializer/pubspec.yaml"
pubspec_resources_path="$root_project_path/resources/pubspec.yaml"
pubspec_nals_lints_path="$root_project_path/nals_lints/pubspec.yaml"

pubspec_versions_path="$root_project_path/pub_versions.yaml"

pubspec_app=$(< $pubspec_app_path)
regex_pub_and_version="^\s*\w+:\s*^?\d+\..*"

n=1
while read line; do
    if [[ $line =~ $regex_pub_and_version ]]; then
        version_maps["${line%:*}"]="  $line" # and two space and remove version, Ex output: bloc_test
    fi
done < $pubspec_versions_path

replaceVersions() {
    echo "=====$1====="
    local file_path=$1
    local temp_file=$(mktemp)

    n=1
    while read line; do
        if [[ $line =~ $regex_pub_and_version ]]; then
            local key="${line%:*}"
            local value=${version_maps[$key]}
            if [[ -n $value && "  $line" != $value ]]; then
                echo "replaced $line by $value"
                echo "$value" >> "$temp_file"
            else
                echo "$line" >> "$temp_file"
            fi
        else
            echo "$line" >> "$temp_file"
        fi
        n=$((n+1))
    done < "$file_path"

    mv "$temp_file" "$file_path"
}

replaceVersions $pubspec_app_path
replaceVersions $pubspec_data_path
replaceVersions $pubspec_domain_path
replaceVersions $pubspec_shared_path
replaceVersions $pubspec_initializer_path
replaceVersions $pubspec_resources_path
replaceVersions $pubspec_nals_lints_path
