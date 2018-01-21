#!@bats@/bin/bats --tap

PATH=@mqtt_client@/bin:$PATH

@test "mqtt_client is available" {
    mqtt_client --help
}
@test "Fail to send message anonymous" {
    skip "Not yet"
    run mqtt_client --wait 1 send "nixtest/goes_away" "you should never see this"
    [ $status -ne 0 ]
}
@test "Send message that goes away" {
    run mqtt_client --wait 1 send "nixtest/goes_away" "you should never see this"
    [ $status -eq 0 ]
}
@test "Send message that stays" {
    run mqtt_client --wait 1 send_persisting "nixtest/persisting" "Receive after this client finished"
    [ $status -eq 0 ]
}

@test "Receive message that stayed" {
    #skip "Does not work correctly yet"
    run mqtt_client --wait 5 recv "nixtest/persisting"
    [ $status -eq 0 ]
    echo $output |grep "Receive after this client finished"
}

@test "subscribe, then send" {
    # skip "Does not work correctly yet"
    rm -f /tmp/received_messages
    mqtt_client --wait 5 recv "nixtest/live_message" > /tmp/received_messages &
    sleep 1
    run mqtt_client --wait 1 send "nixtest/live_message" "message here"
    [ $status -eq 0 ]
    sleep 5
    grep "message here" /tmp/received_messages
}