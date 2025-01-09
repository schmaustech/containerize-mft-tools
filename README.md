# Containerization NVIDIA MFT Tooling

Containerization of the NVIDIA MFT Tooling

**Goal**: The goal of this document is to make the NVIDIA MFT Tooling containerized to allow for firmware settings and firmware updates.

**Future Goal**: Pass variables as a CR to set firmware versions, auto update, update and/or just report 

## NVIDIA MFT Tooling, Mlnx Tools and Mlxup

The MFT package is a set of firmware management tools used to:

* Generate a standard or customized NVIDIA firmware image querying for firmware information
* Burn a firmware image
* Make configuration changes to the firmware settings

The following is a list of the available tools in MFT, together with a brief description of what each tool performs. 

| **Component**   | **Description/Function**                                                                                                                             |
|-----------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
| mst             | Starts/stops the register access driver Lists the available mst devices                                                                              |
| mlxburn         | Generation of a standard or customized NVIDIA firmware image for burning (.bin or .mlx)to the Flash/EEPROM attached to a NVIDIA HCA or switch device |
| flint           | This tool burns/query a firmware binary image or an expansion ROM image to the Flash device of a NVIDIA network adapter/gateway/switch device        |
| debug utilities | A set of debug utilities (e.g., itrace, fwtrace, mlxtrace, mlxdump, mstdump, mlxmcg, wqdump, mcra, mlxi2c, i2c, mget_temp, and pckt_drop)            |
| mlxup           | The utility enables discovery of available NVIDIA adapters and indicates whether firmware update is required for each adapter                        |
| mlnx-tools      | Mellanox userland tools and scripts                                                                                                                  |

Sources:
[Mlnx-tools Repo](https://github.com/Mellanox/mlnx-tools)
[MFT Tools](https://network.nvidia.com/products/adapter-software/firmware-tools/)
[Mlxup](https://network.nvidia.com/support/firmware/mlxup-mft/)

## Workflow Sections

- [Prerequisites](#prerequisites)
- [Building The Container](#building-the-container)
- [Running The Container](#running-the-container)
- [Validate The Container](#validate-the-container)

## Prerequisites

Before we can build the container we need to setup the directory structure, gather a few packages and create the dockerfile and entrypoint script.  First let's create the directory structure.  I am using root in this example but it could be a regular user.

~~~bash
$ mkdir -p /root/mft/rpms
$ cd /root/mft
~~~
Next we need to download the following rpms from [Red Hat Package Downloads](https://access.redhat.com/downloads/content/package-browser) and place them into the rpms directory.  The first is the kernel-devel package for the kernel of the OpenShift node this container will run on.  To obtain the kernel version we can run the following `oc` command on our cluster.

~~~bash
$ oc debug node/nvd-srv-29.nvidia.eng.rdu2.dc.redhat.com
Starting pod/nvd-srv-29nvidiaengrdu2dcredhatcom-debug-rhlgs ...
To use host binaries, run `chroot /host`
Pod IP: 10.6.135.8
If you don't see a command prompt, try pressing enter.
sh-5.1# chroot /host
sh-5.1# uname -r
5.14.0-427.47.1.el9_4.x86_64
sh-5.1#
~~~

Now that we have our kernel version we can download the two packages into our `/root/mft/rpms` directory.

* kernel-devel-5.14.0-427.47.1.el9_4.x86_64.rpm
* usbutils-017-1.el9.x86_64.rpm

Next we need to create the dockerfile.mft which will build the container.

~~~bash
$ cat <<EOF > dockerfile.mft 
# Start from UBI9 image
FROM registry.access.redhat.com/ubi9/ubi:latest

# Set work directory
WORKDIR /root/mft

# Copy in packages not available in UBI repo
COPY ./rpms/*.rpm /root/rpms/
RUN dnf install /root/rpms/usbutils*.rpm -y

# DNF install packages either from repo or locally
RUN dnf install wget procps-ng pciutils yum jq iputils ethtool net-tools kmod systemd-udev rpm-build gcc make -y

# Cleanup 
WORKDIR /root
RUN dnf clean all

# Run container entrypoint
COPY entrypoint.sh /root/entrypoint.sh
ENTRYPOINT ["/bin/bash", "/root/entrypoint.sh"]
EOF
~~~

The docker container file references a entrypoint.sh script so we need to create that under `/root/mft/`.

~~~bash
$ cat <<EOF > entrypoint.sh 
#!/bin/bash
# Set working dir
cd /root

# Set tool versions 
MLNXTOOLVER=23.07-1.el9
MFTTOOLVER=4.30.0-139
MLXUPVER=4.30.0

# Set architecture
ARCH=`uname -m`

# Pull mlnx-tools from EPEL
wget https://dl.fedoraproject.org/pub/epel/9/Everything/$ARCH/Packages/m/mlnx-tools-$MLNXTOOLVER.noarch.rpm

# Arm architecture fixup for mft-tools
if [ "$ARCH" == "aarch64" ]; then export ARCH="arm64"; fi

# Pull mft-tools
wget https://www.mellanox.com/downloads/MFT/mft-$MFTTOOLVER-$ARCH-rpm.tgz

# Install mlnx-tools into container
dnf install mlnx-tools-$MLNXTOOLVER.noarch.rpm

# Install kernel-devel package supplied in container
rpm -ivh /root/rpms/kernel-devel-*.rpm --nodeps
mkdir /lib/modules/$(uname -r)/
ln -s /usr/src/kernels/$(uname -r) /lib/modules/$(uname -r)/build

# Install mft-tools into container
tar -xzf mft-$MFTTOOLVER-$ARCH-rpm.tgz 
cd /root/mft-$MFTTOOLVER-$ARCH-rpm
#./install.sh --without-kernel
./install.sh 

# Change back to root workdir
cd /root

# x86 fixup for mlxup binary
if [ "$ARCH" == "x86_64" ]; then export ARCH="x64"; fi

# Pull and place mlxup binary
wget https://www.mellanox.com/downloads/firmware/mlxup/$MLXUPVER/SFX/linux_$ARCH/mlxup
mv mlxup /usr/local/bin
chmod +x /usr/local/bin/mlxup

sleep infinity & wait
EOF
~~~

Now we should have all the prerequisites and we can move onto building the container.

## Building The Container

To build the container run the `podman build` command on a Red Hat Enterprise Linux 9.x system using the Dockerfile.mft provided in this repository.

~~~bash
$ podman build . -f dockerfile.mft -t quay.io/redhat_emp1/ecosys-nvidia/mfttools:1.0.0
STEP 1/9: FROM registry.access.redhat.com/ubi9/ubi:latest
STEP 2/9: WORKDIR /root/mft
--> 6e6c9f1636c7
STEP 3/9: COPY ./rpms/*.rpm /root/rpms/
--> 30a022291bd9
STEP 4/9: RUN dnf install /root/rpms/usbutils*.rpm -y
Updating Subscription Management repositories.
subscription-manager is operating in container mode.
Red Hat Enterprise Linux 9 for x86_64 - BaseOS  9.2 MB/s |  41 MB     00:04    
Red Hat Enterprise Linux 9 for x86_64 - AppStre 9.4 MB/s |  48 MB     00:05    
Red Hat Universal Base Image 9 (RPMs) - BaseOS  2.2 MB/s | 525 kB     00:00    
Red Hat Universal Base Image 9 (RPMs) - AppStre 5.2 MB/s | 2.3 MB     00:00    
Red Hat Universal Base Image 9 (RPMs) - CodeRea 1.7 MB/s | 281 kB     00:00    
Dependencies resolved.
================================================================================
 Package     Arch      Version           Repository                        Size
================================================================================
Installing:
 usbutils    x86_64    017-1.el9         @commandline                     120 k
Installing dependencies:
 hwdata      noarch    0.348-9.15.el9    rhel-9-for-x86_64-baseos-rpms    1.6 M
 libusbx     x86_64    1.0.26-1.el9      rhel-9-for-x86_64-baseos-rpms     78 k

Transaction Summary
================================================================================
Install  3 Packages

Total size: 1.8 M
Total download size: 1.7 M
Installed size: 9.8 M
Downloading Packages:
(1/2): libusbx-1.0.26-1.el9.x86_64.rpm          327 kB/s |  78 kB     00:00    
(2/2): hwdata-0.348-9.15.el9.noarch.rpm         3.3 MB/s | 1.6 MB     00:00    
--------------------------------------------------------------------------------
Total                                           3.4 MB/s | 1.7 MB     00:00     
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                        1/1 
  Installing       : hwdata-0.348-9.15.el9.noarch                           1/3 
  Installing       : libusbx-1.0.26-1.el9.x86_64                            2/3 
  Installing       : usbutils-017-1.el9.x86_64                              3/3 
  Running scriptlet: usbutils-017-1.el9.x86_64                              3/3 
  Verifying        : libusbx-1.0.26-1.el9.x86_64                            1/3 
  Verifying        : hwdata-0.348-9.15.el9.noarch                           2/3 
  Verifying        : usbutils-017-1.el9.x86_64                              3/3 
Installed products updated.

Installed:
  hwdata-0.348-9.15.el9.noarch            libusbx-1.0.26-1.el9.x86_64           
  usbutils-017-1.el9.x86_64              
Complete!
--> 7c16c8d84152
STEP 5/9: RUN dnf install wget procps-ng pciutils yum jq iputils ethtool net-tools kmod systemd-udev rpm-build gcc make -y
Updating Subscription Management repositories.
subscription-manager is operating in container mode.
Last metadata expiration check: 0:00:08 ago on Thu Jan  9 18:32:20 2025.
Package yum-4.14.0-17.el9.noarch is already installed.
Dependencies resolved.
======================================================================================================
 Package                      Arch    Version                  Repository                         Size
======================================================================================================
Installing:
 ethtool                      x86_64  2:6.2-1.el9              rhel-9-for-x86_64-baseos-rpms     234 k
 gcc                          x86_64  11.5.0-2.el9             rhel-9-for-x86_64-appstream-rpms   32 M
 iputils                      x86_64  20210202-10.el9_5        rhel-9-for-x86_64-baseos-rpms     179 k
 (...)                                 
  unzip-6.0-57.el9.x86_64                                                       
  wget-1.21.1-8.el9_4.x86_64                                                    
  xz-5.2.5-8.el9_0.x86_64                                                       
  zip-3.0-35.el9.x86_64                                                         
  zstd-1.5.1-2.el9.x86_64                                                       

Complete!
--> 862d0e2c9c6f
STEP 6/9: WORKDIR /root
--> 5b3ec62db585
STEP 7/9: RUN dnf clean all
Updating Subscription Management repositories.
subscription-manager is operating in container mode.
43 files removed
--> c14c44f59e9e
STEP 8/9: COPY entrypoint.sh /root/entrypoint.sh
--> d2d5192c3c57
STEP 9/9: ENTRYPOINT ["/bin/bash", "/root/entrypoint.sh"]
COMMIT quay.io/redhat_emp1/ecosys-nvidia/mfttools:1.0.0
--> 1873a4483236
Successfully tagged quay.io/redhat_emp1/ecosys-nvidia/mfttools:1.0.0
1873a448323610f369a8565182a2914675f16d735ffe07f92258df89cd439224
~~~

Once the image has been built push the image up to the registry that the Openshift cluster can access.

~~~bash
$ podman push quay.io/redhat_emp1/ecosys-nvidia/mfttools:1.0.0
Getting image source signatures
Copying blob e5df12622381 done   | 
Copying blob 97c1462e7c7b done   | 
Copying blob facf1e7dd3e0 skipped: already exists  
Copying blob 2dca7d5c2bb7 done   | 
Copying blob 6f64cedd7423 done   | 
Copying blob ec465ce79861 skipped: already exists  
Copying blob 121c270794cd done   | 
Copying config 1873a44832 done   | 
Writing manifest to image destination
~~~

## Running The Container

The container will need to run priviledged so we can access the hardware devices.  To do this we will create a `ServiceAccount` and `Namespace` for it to run in.

~~~bash
$ cat <<EOF > mfttool-project.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: mfttool
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: mfttool
  namespace: mfttool
EOF
~~~

Once the resource file is generated create it on the cluster.

~~~bash
$ oc create -f mfttool-project.yaml 
namespace/mfttool created
serviceaccount/mfttoolcreated
~~~

Now that the project has been created assign the appropriate privileges to the service account.

~~~bash
$ oc -n mfttool adm policy add-scc-to-user privileged -z mfttool
clusterrole.rbac.authorization.k8s.io/system:openshift:scc:privileged added: "mfttool"
~~~

Next we will create a pod yaml for each of our baremetal nodes that will run under the mfttool namespace and leverage the MFT tooling.

~~~bash
$ cat <<EOF > mfttool-pod-nvd-srv-29.yaml
apiVersion: v1
kind: Pod
metadata:
  name: mfttool-pod-nvd-srv-29
  namespace: mfttool
spec:
  nodeSelector: 
    kubernetes.io/hostname: nvd-srv-29.nvidia.eng.rdu2.dc.redhat.com
  hostNetwork: true
  serviceAccountName: mfttool
  containers:
  - image: quay.io/redhat_emp1/ecosys-nvidia/mfttools:1.0.0
    name: mfttool-pod-nvd-srv-29
    securityContext:
      privileged: true
EOF
~~~

Once the custom resource file has been generated, create the resource on the cluster.

~~~bash
oc create -f mfttool-pod-nvd-srv-29.yaml
pod/mfttool-pod-nvd-srv-29 created
~~~

Validate that the pod is up and running.

~~~bash
$ oc get pods -n mfttool
NAME                     READY   STATUS    RESTARTS   AGE
mfttool-pod-nvd-srv-29   1/1     Running   0          28s
~~~

Next we can rsh into the pod.

~~~bash
$ oc rsh -n mfttool mfttool-pod-nvd-srv-29 
sh-5.1#
~~~

Once inside the pod we can run an `mst start` and then an `mst status` to see the devices.

~~~bash
$ oc rsh -n mfttool mfttool-pod-nvd-srv-29 
sh-5.1# mst start 
Starting MST (Mellanox Software Tools) driver set
Loading MST PCI module - Success
[warn] mst_pciconf is already loaded, skipping
Create devices
Unloading MST PCI module (unused) - Success

sh-5.1# mst status
MST modules:
------------
    MST PCI module is not loaded
    MST PCI configuration module loaded

MST devices:
------------
/dev/mst/mt4129_pciconf0         - PCI configuration cycles access.
                                   domain:bus:dev.fn=0000:0d:00.0 addr.reg=88 data.reg=92 cr_bar.gw_offset=-1
                                   Chip revision is: 00
/dev/mst/mt4129_pciconf1         - PCI configuration cycles access.
                                   domain:bus:dev.fn=0000:37:00.0 addr.reg=88 data.reg=92 cr_bar.gw_offset=-1
                                   Chip revision is: 00

sh-5.1#
~~~
