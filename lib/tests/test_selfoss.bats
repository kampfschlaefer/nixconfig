#!@bats@/bin/bats --tap

PATH=@jq@/bin:@curl@/bin:$PATH

@test "add source" {
    run curl -s -f -X POST --data 'title=Outside+Web&tags=&filter=&spout=spouts_rss_feed&url=http%3A%2F%2Foutsideweb%2Ffeed.atom' http://selfoss/source
    [ $status -eq 0 ]
}
@test "check added source" {
    run curl -s -f http://selfoss/sources/list
    [ $status -eq 0 ]
    echo $output |grep "Outside"
    title=$(echo $output |jq -r .[0].title)
    echo "title found: $title"
    [ $title = 'Outside Web' ]
}
@test "first post not yet present" {
    run curl -s -f http://selfoss/items?type=unread
    [ $status -eq 0 ]
    echo "found posts $output"
    echo $output |jq -e '.[0] | length == 0'
}
@test "trigger source fetch" {
    run curl -s http://selfoss/update
    [ $status -eq 0 ]
    [ $output = "finished" ]
}
@test "source has no errors" {
    run curl -s http://selfoss/sources/list
    [ $status -eq 0 ]
    echo $output |grep "Outside"
    error=$(echo $output |jq -r .[0].error)
    echo "errors found: $error"
    [ -z $error ]
}
@test "first post present" {
    run curl -s -f http://selfoss/items?type=unread
    [ $status -eq 0 ]
    echo "found posts $output"
    echo $output |jq -e '.[0] | length > 0'
    firsttitle=$(echo $output |jq -r .[0].title)
    [ $firsttitle = 'First Post' ]
}
