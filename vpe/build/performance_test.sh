#!/bin/sh

# 1. Before use this script, please set test file by export "INPUT_FILE_H264" and  "INPUT_FILE_RAW_420P"
# 2. ./performance_test <task numbers> <test type>
#    <task numbers> can be 0 -32
#    <test type>:
#         decoder: decoder test
#         encoder: encoder test
#         transcoder: 264->264 transcoding test
#
# Example:
# #> export INPUT_FILE_H264="test_1090p.h264"
# #> ./performance_test 16 transcoder
#

decoder="ffmpeg -y -filter_threads 1 -filter_complex_threads 1 -threads 1 -init_hw_device \
    vpe=dev0:/dev/transcoder0,priority=vod,vpeloglevel=0 -c:v h264_vpe -i ${INPUT_FILE_H264} -filter_complex "hwdownload,format=nv12" -f null /dev/null"

encoder="ffmpeg -y -filter_threads 1 -filter_complex_threads 1 -threads 1 --init_hw_device \
    vpe=dev0:/dev/transcoder0,priority=vod,vpeloglevel=0 -s 1920x1080 -pix_fmt yuv420p \
    -i ${INPUT_FILE_RAW_420P} -filter_complex 'vpe_pp' -c:v h264enc_vpe -preset superfast -b:v 10000000 out0.h264  -f null /dev/null"

transcoder="ffmpeg -y -filter_threads 1 -filter_complex_threads 1 -threads 1 -init_hw_device \
    vpe=dev0:/dev/transcoder0,priority=vod,vpeloglevel=5 -c:v h264_vpe -transcode 1 \
    -i ${INPUT_FILE_H264} -c:v h264enc_vpe -preset superfast -b:v 10000000 out0.h264 -f null /dev/null"

echo "will start $1 encoder"

while(true)
do
    joblist=($(jobs -p))
    while (( ${#joblist[*]} >= $1 ))
    do
        sleep 1
        joblist=($(jobs -p))
    done
    echo "start job ${#joblist[*]}+1"

    if [ "$2" == "decoder" ]; then
        ffmpeg -y -filter_threads 1 -filter_complex_threads 1 -threads 1 -init_hw_device \
        vpe=dev0:/dev/transcoder0,priority=vod,vpeloglevel=0 -re -c:v h264_vpe -i ${INPUT_FILE_H264} -filter_complex "hwdownload,format=nv12" -f null /dev/null &
    fi

    if [ "$2" == "encoder" ]; then
        ffmpeg -y -filter_threads 1 -filter_complex_threads 1 -threads 1 -init_hw_device \
        vpe=dev0:/dev/transcoder0,priority=vod,vpeloglevel=0  -s 1280x720 -pix_fmt nv12 \
        -i ${INPUT_FILE_RAW_NV12_720p} -filter_complex 'vpe_pp' -c:v h264enc_vpe -preset superfast -r 30 -b:v 10000000 -f null /dev/null &
    fi

    # if [ "$2" == "encoder" ]; then
    #     ffmpeg_csd -y -init_hw_device hantro=dev0:/dev/transcoder0,priority=vod,fbloglevel=4 \
    #     -s 1280x720 -r 30 -re -pix_fmt nv12 -i ${INPUT_FILE_RAW_NV12_720p} -filter_hw_device "dev0" -filter_complex 'hantro_pp' \
    #     -c:v hevcenc_hantro -preset superfast -b:v 10000000 -f null /dev/null
    # fi

    if [ "$2" == "transcoder" ]; then
        ffmpeg -y -filter_threads 1 -filter_complex_threads 1 -threads 1 -init_hw_device \
        vpe=dev0:/dev/transcoder0,priority=vod,vpeloglevel=0 -re -c:v h264_vpe -transcode 1 \
        -i ${INPUT_FILE_H264} -c:v h264enc_vpe -preset superfast -b:v 10000000 -f null /dev/null &
    fi
done
