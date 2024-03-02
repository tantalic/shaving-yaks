#! /bin/sh

workers=("192.168.5.1" "192.168.5.2" "192.168.5.3")
controllers=("192.168.5.51")

# Shutdown workers nodes first
for w in ${workers[@]}
do
    echo "Stopping k0s and shutting down $w"
    ssh ubuntu@$w sudo k0s stop && 
        ssh ubuntu@$w sudo shutdown --poweroff now
done

# After brief delay, shutdown controllers
echo "Waiting 5 minutes to allow for full shutdown of workers"
sleep 300
for c in ${controllers[@]}
do
    echo "Sending shutdown signal to controllers: $w"
    ssh ubuntu@$w sudo k0s stop && 
        ssh ubuntu@$w sudo shutdown --poweroff now
done

echo "Shutdown commands sent, allow time for clean shutdown to complete"
