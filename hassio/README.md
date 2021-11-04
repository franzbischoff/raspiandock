# Raspberry containter to run in parallel with Hassio OS

This container attempts to run a parallel environment using the same raspberry that an already running Hassio OS is running.

My objective is to run the Arduino Connector on it, so I can simulate I have a dedicated raspberry.

# The problems

1. Current Arduino Connector: I tested on Raspian OS, everything seems to work fine, but the webpage [Manager for Linux](https://create.arduino.cc/devices/) can't access the Network information.

   1. Opening the Dev Console (with F12 on chrome), we see several messages with `Retrieving network stats: dbus: connection closed by user`, and some times `Json marsahl result: json: error calling MarshalJSON for type gonetworkmanager.Device: dbus: wire format error: variant signature is empty`. This seems to be a problem with the MQTT payload (that by curiosity, arduino relies on Amazon services for that), and for what I've [read](https://github.com/Wifx/gonetworkmanager/issues/3), the dbus closes if the payload has something unexpected on it, and seems that the go module is failing to retrieve the `variant` at least in this environment. So this in something to work out yet.

   2. The Arduino Connector warns that `ONLY DEBIAN AND DERIVATIVES ARE FULLY SUPPORTED AS OS` distribution is the most compatible. Debian uses `systemd` as system management, what can be tricky on a docker.

2. I still didn't make to enable `systemd` alongside with Hassio OS, **unless** I start the container with `--privileged` mode, what is not a viable option for a release. Another curiosity: it is possible to enable `systemd` on WSL, check [this link](https://github.com/DamionGans/ubuntu-wsl2-systemd-script).

Here I'll register what I have tried to make it work, but still failed, alongside with some thoughts:

- `systemd` need to be the first process to be loaded by kernel: PID 1
- It is required to add the Linux Capability `CAP_SYS_ADMIN` to the container (check docker documentation for --cap-add)
- Still, it is said that `systemd` needs to look at the cgroup file system [this link](https://medium.com/swlh/docker-and-systemd-381dfd7e4628). But adding `–v /sys/fs/cgroup:/sys/fs/cgroup:ro` to the container don't do the trick for some reason. Maybe the reason is 'If your host system doesn’t has cgroup properly configured then you might face issue.'. Hassio OS seems to be based on Buildroot, so I'm not sure about 'properly configured'.
- I've checked the SSH official addon for Hassio, that allows some Host access, and saw these configurations:

  - Capabilities: "NET_ADMIN", "SYS_ADMIN", "SYS_RAWIO", "SYS_TIME", "SYS_NICE"
  - Binds (not all are listed):
    - "/dev:/dev:ro"
    - "/sys/class/gpio:/sys/class/gpio:rw"
    - "/sys/devices/platform/soc:/sys/devices/platform/soc:rw"
    - "/run/dbus:/run/dbus:ro"
    - "/var/log/journal:/var/log/journal:ro"
    - "/run/log/journal:/run/log/journal:ro"
  - Devices: "/dev/mem"
  - DeviceCgroupRules:
    - "c 188:\* rwm"
    - "c 166:\* rwm"
    - "c 189:\* rwm"
    - "c 204:\* rwm"
    - "c 180:\* rwm"
    - "c 254:\* rwm"
    - "c 243:\* rwm"
    - "c 1:1 rwm"

- Misc: `/proc/device-tree` is not populated (actually is links to `/sys/firmware/devicetree/base`). This may be a thing for later. Host has the proper files, maybe we can bind it.

Currently `systemd` starts as PID 1, but for some reason it is not "started". And `systemctl` for example, complains that the system wasn't boot with `systemd`.

Here is my last attempt (the entrypoint can be also `/sbin/init`):

```sh
docker create \
 -v /sys/fs/cgroup:/sys/fs/cgroup:rw -v /dev:/dev:rw -v /sys/class/gpio:/sys/class/gpio:rw \
 -v /sys/devices/platform/soc:/sys/devices/platform/soc:rw -v /run/dbus:/run/dbus:rw \
 -v /var/log/journal:/var/log/journal:rw -v /run/log/journal:/run/log/journal:rw \
 --cap-add ALL \
 --entrypoint /usr/bin/systemd \
 --device=/dev/mem:/dev/mem \
 --device-cgroup-rule="c 188:* rmw" \
 --device-cgroup-rule="c 166:* rmw" \
 --device-cgroup-rule="c 189:* rmw" \
 --device-cgroup-rule="c 204:* rmw" \
 --device-cgroup-rule="c 180:* rmw" \
 --device-cgroup-rule="c 254:* rmw" \
 --device-cgroup-rule="c 243:* rmw" \
 --device-cgroup-rule="c 1:1 rmw" \
 --interactive --network host \
 --name raspian franzbischoff/raspiandock:test
```

Then:

```sh
docker start -i raspian
```

In another terminal:

```sh
docker exec -it raspian bash
```

To enable external SSH access, if not yet, run:

```sh
dpkg-reconfigure openssh-server
system ssh start
```

# About the Arduino Connector

Compared to the WSL install (x86_x64), the following packages weren't installed: `network-manager-pptp` and `pptp-linux`.

On the actual rapberry, `systemctl status ArduinoConnector.service` still have the message: `arduino-connector[639]: dbus: wire format error: variant signature is empty`
