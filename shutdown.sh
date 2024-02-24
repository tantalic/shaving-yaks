#! /bin/sh

workers=("192.168.5.2" "192.168.5.3" "192.168.5.4")
controllers=("192.168.5.1")

# Shutdown workers nodes first
for w in ${workers[@]}
do
    echo "Sending shutdown signal to worker: $w"
    ssh ubuntu@$w sudo shutdown -h now
done

# After brief delay, shutdown controllers
echo "Waiting 5 minutes to allow for full shutdown of workers"
sleep 300
for c in ${controllers[@]}
do
    echo "Sending shutdown signal to controllers: $w"
    ssh ubuntu@$c sudo shutdown -h now
done

echo "Shutdown signals sent, allow time for clean shutdown to complete"
