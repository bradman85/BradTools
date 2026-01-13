
#!/bin/bash
echo "=== Step 1: Removing Chinese/non-ASCII characters from all .stl filenames (recursive) ==="

find . -type f -name "*.stl" -o -name "*.STL" | while read -r file; do
    dir=$(dirname "$file")
    base=$(basename "$file")
    # Replace everything that is not a-z A-Z 0-9 . _ - with _
    cleaned_base=$(echo "$base" | sed -E 's/[^a-zA-Z0-9._-]/_/g')
    
    if [[ "$base" != "$cleaned_base" ]]; then
        newpath="$dir/$cleaned_base"
        if [[ -f "$newpath" ]]; then
            echo "SKIP (already exists): $file → $cleaned_base"
        else
            echo "RENAMING: $file → $dir/$cleaned_base"
            mv -v "$file" "$newpath"
        fi
    fi
done

echo "Filename cleaning finished!"