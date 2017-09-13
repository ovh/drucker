#!/bin/bash
#
# Install and compile themes with NPM

# No set-e because we catch the errors

pushd "$(pwd)" > /dev/null

# Main directories
DRUCKER_DIR="$(dirname $(dirname `readlink -f -- "$0"`))"    # druckerdir: father of this folder
PROJECT_DIR="$(dirname "${DRUCKER_DIR}")"                    # projectdir: grand-father of this folder

cd "${DRUCKER_DIR}/lib"

# load functions and environment variables
. functions

popd > /dev/null

# find every theme with a gulpfile defined
enumerate_compilable_themes () {
    local source_dirs=`find "$(docroot)/themes" -maxdepth 2 -mindepth 2 -iname package.json -print`
    local themes=()
    for dir in $source_dirs
    do
	    local theme_path="${dir%/package.json}"
        themes+=( "${theme_path}" )
    done

    echo "${themes[@]}"
}

# install node modules and run gulp compile to generate theme assets
compile_theme ()
{
    local theme_dir=$1
    pushd "$(pwd)" > /dev/null

    cd $theme_dir
    npm set progress=false && npm install && npm run compile
    local success=$?

    popd > /dev/null
    return $success
}

# entry point
main ()
{
    local themes="$(enumerate_compilable_themes)"
    local errors=()

    for theme in $themes
    do
        echo "Compiling $theme..."
        compile_theme $theme
        if [ "$?" -ne "0" ]; then
            errors+=("$theme")
        fi
    done

    if [ ! ${#errors[@]} -eq 0 ]; then
        for error in "${errors[@]}"
        do
            echo -e "\033[1;31m[ERROR]\033[0m Fail to compile $error"
        done
        exit 1
    fi
}

main
