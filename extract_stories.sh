#!/bin/sh

TIMEZONE="Asia/Bangkok"
prettydate="$(TZ=$TIMEZONE date "+%A, %d %b %Y")"
exactdatetime="$(TZ=$TIMEZONE date "+%Y-%m-%d %H:%M:%S")"

FILE_NAME="Slashdot-$(date "+%Y%m%d%H%M%S")"
JSON_FILE="${FILE_NAME}.json"
HTML_FILE="${FILE_NAME}.html"

curl -s https://www.latestnigeriannews.com/latest/slashdot/0/latest-slashdot-news-headlines | pup '#slashdot a json{}' > "$JSON_FILE"

cat <<JSON | mustache slashdot.diygest.mustache.html > "$HTML_FILE"
{
"prettydate": "${prettydate}",
"exactdatetime": "${exactdatetime}",
"stories":
$(
jq '[ range(0; length) as $i | .[$i] |
           { "number": ($i + 1),
             "link": .href,
             "title": .text, 
             "story": 
                 (.onmouseover | 
                    sub("ddrivetip\\(&#39;";"") |
                    sub("&#39;\\)";"")) }]' < "$JSON_FILE" \
    | \
  perl -Mopen=locale -MHTML::Entities -pe '
    $_ =~ s/&#34;/\\"/gm;
    $_ = decode_entities($_);'
)
}
JSON
