#!@bats@/bin/bats --tap

PATH=@jq@/bin:@curl@/bin:$PATH

@test "add source" {
    run curl --insecure -f -X POST --data 'title=Outside+Web&tags=&filter=&spout=spouts_rss_feed&url=http%3A%2F%2Foutsideweb%2Ffeed.atom' https://selfoss.arnoldarts.de/source
    [ $status -eq 0 ]
}
@test "check added source" {
    run curl --insecure -s -f https://selfoss.arnoldarts.de/sources/list
    [ $status -eq 0 ]
    echo $output |grep "Outside"
    title=$(echo $output |jq -r .[0].title)
    echo "title found: $title"
    [ $title = 'Outside Web' ]
}
@test "first post not yet present" {
    run curl --insecure -s -f https://selfoss/items?type=unread
    [ $status -eq 0 ]
    echo "found posts $output"
    echo $output |jq -e '.[0] | length == 0'
}
@test "trigger source fetch" {
    run curl --insecure -s https://selfoss/update
    [ $status -eq 0 ]
    [ $output = "finished" ]
}
@test "source has no errors" {
    run curl --insecure -s https://selfoss/sources/list
    [ $status -eq 0 ]
    echo $output |grep "Outside"
    error=$(echo $output |jq -r .[0].error)
    echo "errors found: $error"
    [ -z $error ]
}
@test "first post present" {
    run curl --insecure -s -f https://selfoss/items?type=unread
    [ $status -eq 0 ]
    echo "found posts $output"
    echo $output |jq -e '.[0] | length > 0'
    firsttitle=$(echo $output |jq -r .[0].title)
    [ $firsttitle = 'First Post' ]
}
@test "can download favicons" {
    # Relies on a stable hash function in selfoss for the names of the favicon files.
    run curl --insecure -s -f https://selfoss/favicons/de284a31d18355923a459f030e2aa9cb.png
    [ $status -eq 0 ]
}
