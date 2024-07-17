#!/bin/bash

num_client=4
data_name=cola
lora_r=8
num_rounds=20
client_epochs=10
model=distilbert-base-uncased
mode=ffalora

tid=22222

nohup python -u server.py \
    --num_client $num_client --data_name $data_name --rank 0 \
    --num_rounds $num_rounds --client_epochs $client_epochs --client_ckpt $model \
    --mode $mode --lora_r $lora_r \
    > outputs/${tid}.out 2>&1 &

for client in 1 2 3 4
do
    device=$((client + 3))
    local_r=$((client * 2))
    nohup python -u lora-client.py \
        --num_client $num_client --data_name $data_name --rank $client \
        --num_rounds $num_rounds --client_epochs $client_epochs --client_ckpt $model \
        --mode $mode --lora_r $lora_r --local_r $local_r \
        --device $device \
        > outputs/client/${tid}_${client}.out 2>&1 &
done
