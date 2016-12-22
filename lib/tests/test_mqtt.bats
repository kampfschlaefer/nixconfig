#!@bats@/bin/bats --tap

PATH=@mqtt_client@/bin:$PATH

@test "mqtt_client is available" {
    mqtt_client --help
}
@test "Send message that goes away" {
    run mqtt_client send "nixtest/goes_away" "you should never see this"
    [ $status -eq 0 ]
}
@test "Send message that stays" {
    run mqtt_client send_persisting "nixtest/persisting" "Receive after this client finished"
    [ $status -eq 0 ]
}

@test "Receive message that stayed" {
    skip "Does not work correctly yet"
    run mqtt_client recv "nixtest/persisting"
    [ $status -eq 0 ]
    echo $output |grep "Receive after this client finished"
}

@test "subscribe, then send" {
    skip "Does not work correctly yet"
    mqtt_client recv "nixtest/live_message" &
    mqtt_client send "nixtest/live_message" "message here"
}