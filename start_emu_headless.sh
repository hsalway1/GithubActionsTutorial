#!/bin/bash

BL='\033[0;34m'
G='\033[0;32m'
RED='\033[0;31m'
YE='\033[1;33m'
NC='\033[0m' # No Color

emulator_name=${EMULATOR_NAME}

function check_hardware_acceleration() {
    if [[ "$HW_ACCEL_OVERRIDE" != "" ]]; then
        hw_accel_flag="$HW_ACCEL_OVERRIDE"
    else
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS-specific hardware acceleration check
            HW_ACCEL_SUPPORT=$(sysctl -a | grep -E -c '(vmx|svm)')
        else
            # generic Linux hardware acceleration check
            HW_ACCEL_SUPPORT=$(grep -E -c '(vmx|svm)' /proc/cpuinfo)
        fi

        if [[ $HW_ACCEL_SUPPORT == 0 ]]; then
            hw_accel_flag="-accel off"
        else
            hw_accel_flag="-accel on"
        fi
    fi

    echo "$hw_accel_flag"
}

hw_accel_flag=$(check_hardware_acceleration)

function launch_emulator () {
  adb devices | grep emulator | cut -f1 | xargs -I {} adb -s "{}" emu kill
  options="@${emulator_name} -no-window -no-snapshot -screen no-touch -noaudio -memory 2048 -no-boot-anim ${hw_accel_flag} -camera-back none"
  if [[ "$OSTYPE" == *linux* ]]; then
    echo "${OSTYPE}: emulator ${options} -gpu off"
    nohup emulator $options -gpu off &
  fi
  if [[ "$OSTYPE" == *darwin* ]] || [[ "$OSTYPE" == *macos* ]]; then
    echo "im here"
    echo "${OSTYPE}: emulator ${options} -gpu swiftshader_indirect"
    nohup emulator $options -gpu swiftshader_indirect &
  fi

  if [ $? -ne 0 ]; then
    echo "Error launching emulator"
    return 1
  fi
}

function check_emulator_status () {
  runtime=0
  while [[ -z "$(adb devices | grep emulator)" ]]; do
    echo "waiting for emulator to boot up"
    sleep 5
    (( runtime+=5 ))

    if (( $runtime > 240 )); then
        echo "Timeout"
        exit 1
    fi
    done

    echo "Emulator started"
    exit 0
};

function disable_animation() {
  adb shell "settings put global window_animation_scale 0.0"
  adb shell "settings put global transition_animation_scale 0.0"
  adb shell "settings put global animator_duration_scale 0.0"
};

function hidden_policy() {
  adb shell "settings put global hidden_api_policy_pre_p_apps 1;settings put global hidden_api_policy_p_apps 1;settings put global hidden_api_policy 1"
};

launch_emulator
sleep 2
check_emulator_status
sleep 1
disable_animation
sleep 1
hidden_policy
sleep 1
