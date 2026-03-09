#!/usr/bin/env bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
parent_dir="$(dirname "$script_dir")"
distFolderName="$parent_dir/dist"

# Determine version from argument, git tag, or branch
if [ -n "$1" ]; then
  version="$1"
else
  # Try to get the current tag
  # Get the directory of this script (submodule root)
  # script_dir and parent_dir already set above
  # Run git commands in the submodule directory
  version=$(git -C "$script_dir" describe --tags --exact-match 2>/dev/null)
  if [ -z "$version" ]; then
    # If not on a tag, use branch name
    version=$(git -C "$script_dir" rev-parse --abbrev-ref HEAD)
  fi
fi

archiveFolderName="Eisvogel-${version}"
archiveFolder="${distFolderName}/${archiveFolderName}"

rm -rf "${distFolderName}"
mkdir "${distFolderName}"
mkdir "${distFolderName}/${archiveFolderName}"

# Use sed differently on macOS (BSD sed) than on other systems (possibly GNU sed)
#
# macos:        sed -i ''
# other system: sed -i
#
# see https://stackoverflow.com/a/66763713
SEDOPTION=
if [[ "$OSTYPE" == "darwin"* ]]; then
  SEDOPTION="-i \x27\x27"
else
  SEDOPTION="-i"
fi

cp "$parent_dir/template-multi-file/eisvogel.latex" "${distFolderName}/eisvogel.latex"

# replace partials (latex)
sed -e '/\$fonts\.latex()\$/ {' -e "r $parent_dir/template-multi-file/fonts.latex" -e 'd' -e '}' $SEDOPTION "${distFolderName}/eisvogel.latex"
sed -e '/\$font-settings\.latex()\$/ {' -e "r $parent_dir/template-multi-file/font-settings.latex" -e 'd' -e '}' $SEDOPTION "${distFolderName}/eisvogel.latex"
sed -e '/\$common\.latex()\$/ {' -e "r $parent_dir/template-multi-file/common.latex" -e 'd' -e '}' $SEDOPTION "${distFolderName}/eisvogel.latex"
sed -e '/\$document-metadata\.latex()\$/ {' -e "r $parent_dir/template-multi-file/document-metadata.latex" -e 'd' -e '}' $SEDOPTION "${distFolderName}/eisvogel.latex"
sed -e '/\$eisvogel-added\.latex()\$/ {' -e "r $parent_dir/template-multi-file/eisvogel-added.latex" -e 'd' -e '}' $SEDOPTION "${distFolderName}/eisvogel.latex"
sed -e '/\$eisvogel-title-page\.latex()\$/ {' -e "r $parent_dir/template-multi-file/eisvogel-title-page.latex" -e 'd' -e '}' $SEDOPTION "${distFolderName}/eisvogel.latex"
sed -e '/\$after-header-includes\.latex()\$/ {' -e "r $parent_dir/template-multi-file/after-header-includes.latex" -e 'd' -e '}' $SEDOPTION "${distFolderName}/eisvogel.latex"
sed -e '/\$hypersetup\.latex()\$/ {' -e "r $parent_dir/template-multi-file/hypersetup.latex" -e 'd' -e '}' $SEDOPTION "${distFolderName}/eisvogel.latex"
sed -e '/\$passoptions\.latex()\$/ {' -e "r $parent_dir/template-multi-file/passoptions.latex" -e 'd' -e '}' $SEDOPTION "${distFolderName}/eisvogel.latex"

cp "$parent_dir/template-multi-file/eisvogel.beamer" "${distFolderName}/eisvogel.beamer"

# replace partials (beamer)
sed -e '/\$fonts\.latex()\$/ {' -e "r $parent_dir/template-multi-file/fonts.latex" -e 'd' -e '}' $SEDOPTION "${distFolderName}/eisvogel.beamer"
sed -e '/\$font-settings\.latex()\$/ {' -e "r $parent_dir/template-multi-file/font-settings.latex" -e 'd' -e '}' $SEDOPTION "${distFolderName}/eisvogel.beamer"
sed -e '/\$common\.latex()\$/ {' -e "r $parent_dir/template-multi-file/common.latex" -e 'd' -e '}' $SEDOPTION "${distFolderName}/eisvogel.beamer"
# The beamer template has no eisvogel block $eisvogel-added.latex()$
# The beamer template has no eisvogel titlepage $eisvogel-titlepage.latex()$
sed -e '/\$after-header-includes\.latex()\$/ {' -e "r $parent_dir/template-multi-file/after-header-includes.latex" -e 'd' -e '}' $SEDOPTION "${distFolderName}/eisvogel.beamer"
sed -e '/\$hypersetup\.latex()\$/ {' -e "r $parent_dir/template-multi-file/hypersetup.latex" -e 'd' -e '}' $SEDOPTION "${distFolderName}/eisvogel.beamer"
sed -e '/\$passoptions\.latex()\$/ {' -e "r $parent_dir/template-multi-file/passoptions.latex" -e 'd' -e '}' $SEDOPTION "${distFolderName}/eisvogel.beamer"


cp -r "$parent_dir/examples" "${archiveFolder}/examples"
cp -r "$parent_dir/template-multi-file" "${archiveFolder}/template-multi-file"
cp "${distFolderName}/eisvogel.latex" "${archiveFolder}/eisvogel.latex"
cp "${distFolderName}/eisvogel.beamer" "${archiveFolder}/eisvogel.beamer"
cp "$parent_dir/icon.png" "${archiveFolder}/icon.png"
cp "$parent_dir/LICENSE" "${archiveFolder}/LICENSE"
cp "$parent_dir/README.md" "${archiveFolder}/README.md"
cp "$parent_dir/CHANGELOG.md" "${archiveFolder}/CHANGELOG.md"

cd "${distFolderName}"

echo "Created local release in ${distFolderName}"
