# Containerization NVIDIA MFT Tooling

Containerization of the NVIDIA MFT Tooling

**Goal**: The goal of this document is to make the NVIDIA MFT Tooling containerized to allow for firmware settings and firmware updates.
**Future Goal**: Pass variables as a CR to set firmware versions, auto update, update and/or just report 

## NVIDIA MFT Tooling, Mlnx Tools and Mlxup

The MFT package is a set of firmware management tools used to:

* Generate a standard or customized NVIDIA firmware image Querying for firmware information
* Burn a firmware image

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

- [Building The Container](#building-the-container)
- [Running The Container](#running-the-container)
- [Validate The Container](#validate-the-container)

## Building The Container

To build the container run the `podman build` command on a Red Hat Enterprise Linux 9.x system using the Dockerfile.mft provided in this repository.

~~~bash
podman build . -f Dockerfile.mft -t quay.io/redhat_emp1/ecosys-nvidia/mfttools:0.0.1
STEP 1/7: FROM registry.access.redhat.com/ubi9/ubi:9.5-1730489303
STEP 2/7: WORKDIR /root
--> Using cache 49bf31146abb4da08e705c0b93dc670e6fc8e36d60ffdbb1948dd6e1d7f79642
--> 49bf31146abb
STEP 3/7: RUN dnf install wget procps-ng pciutils yum jq iputils ethtool net-tools -y
Updating Subscription Management repositories.
subscription-manager is operating in container mode.
Red Hat Enterprise Linux 9 for x86_64 - BaseOS  8.8 MB/s |  38 MB     00:04    
Red Hat Enterprise Linux 9 for x86_64 - AppStre 9.7 MB/s |  46 MB     00:04    
Red Hat Universal Base Image 9 (RPMs) - BaseOS  1.0 MB/s | 525 kB     00:00    
Red Hat Universal Base Image 9 (RPMs) - AppStre 5.5 MB/s | 2.3 MB     00:00    
Red Hat Universal Base Image 9 (RPMs) - CodeRea 1.7 MB/s | 281 kB     00:00    
Package yum-4.14.0-17.el9.noarch is already installed.
Dependencies resolved.
===================================================================================================
 Package                   Arch    Version                  Repository                         Size
===================================================================================================
Installing:
 ethtool                   x86_64  2:6.2-1.el9              rhel-9-for-x86_64-baseos-rpms     234 k
 iputils                   x86_64  20210202-9.el9           rhel-9-for-x86_64-baseos-rpms     178 k
 jq                        x86_64  1.6-17.el9               rhel-9-for-x86_64-baseos-rpms     190 k
 net-tools                 x86_64  2.0-0.64.20160912git.el9 rhel-9-for-x86_64-baseos-rpms     312 k
 pciutils                  x86_64  3.7.0-5.el9              rhel-9-for-x86_64-baseos-rpms      96 k
 procps-ng                 x86_64  3.3.17-14.el9            rhel-9-for-x86_64-baseos-rpms     353 k
 wget                      x86_64  1.21.1-8.el9_4           rhel-9-for-x86_64-appstream-rpms  789 k
Installing dependencies:
 hwdata                    noarch  0.348-9.15.el9           rhel-9-for-x86_64-baseos-rpms     1.6 M
 libpsl                    x86_64  0.21.1-5.el9             rhel-9-for-x86_64-baseos-rpms      66 k
 oniguruma                 x86_64  6.9.6-1.el9.6            rhel-9-for-x86_64-baseos-rpms     221 k
 pciutils-libs             x86_64  3.7.0-5.el9              rhel-9-for-x86_64-baseos-rpms      43 k
 publicsuffix-list-dafsa   noarch  20210518-3.el9           rhel-9-for-x86_64-baseos-rpms      59 k

Transaction Summary
===================================================================================================
Install  12 Packages

Total download size: 4.1 M
Installed size: 17 M
Downloading Packages:
(1/12): pciutils-libs-3.7.0-5.el9.x86_64.rpm    180 kB/s |  43 kB     00:00    
(2/12): libpsl-0.21.1-5.el9.x86_64.rpm          266 kB/s |  66 kB     00:00    
(3/12): pciutils-3.7.0-5.el9.x86_64.rpm         309 kB/s |  96 kB     00:00    
(4/12): ethtool-6.2-1.el9.x86_64.rpm            1.8 MB/s | 234 kB     00:00    
(5/12): publicsuffix-list-dafsa-20210518-3.el9. 388 kB/s |  59 kB     00:00    
(6/12): iputils-20210202-9.el9.x86_64.rpm       1.6 MB/s | 178 kB     00:00    
(7/12): procps-ng-3.3.17-14.el9.x86_64.rpm      3.6 MB/s | 353 kB     00:00    
(8/12): jq-1.6-17.el9.x86_64.rpm                2.3 MB/s | 190 kB     00:00    
(9/12): oniguruma-6.9.6-1.el9.6.x86_64.rpm      2.1 MB/s | 221 kB     00:00    
(10/12): net-tools-2.0-0.64.20160912git.el9.x86 1.9 MB/s | 312 kB     00:00    
(11/12): hwdata-0.348-9.15.el9.noarch.rpm       4.9 MB/s | 1.6 MB     00:00    
(12/12): wget-1.21.1-8.el9_4.x86_64.rpm         3.9 MB/s | 789 kB     00:00    
--------------------------------------------------------------------------------
Total                                           5.1 MB/s | 4.1 MB     00:00     
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                        1/1 
  Installing       : oniguruma-6.9.6-1.el9.6.x86_64                        1/12 
  Installing       : hwdata-0.348-9.15.el9.noarch                          2/12 
  Installing       : publicsuffix-list-dafsa-20210518-3.el9.noarch         3/12 
  Installing       : libpsl-0.21.1-5.el9.x86_64                            4/12 
  Installing       : pciutils-libs-3.7.0-5.el9.x86_64                      5/12 
  Installing       : pciutils-3.7.0-5.el9.x86_64                           6/12 
  Installing       : wget-1.21.1-8.el9_4.x86_64                            7/12 
  Installing       : jq-1.6-17.el9.x86_64                                  8/12 
  Installing       : net-tools-2.0-0.64.20160912git.el9.x86_64             9/12 
  Running scriptlet: net-tools-2.0-0.64.20160912git.el9.x86_64             9/12 
  Installing       : procps-ng-3.3.17-14.el9.x86_64                       10/12 
  Installing       : iputils-20210202-9.el9.x86_64                        11/12 
  Running scriptlet: iputils-20210202-9.el9.x86_64                        11/12 
  Installing       : ethtool-2:6.2-1.el9.x86_64                           12/12 
  Running scriptlet: ethtool-2:6.2-1.el9.x86_64                           12/12 
  Verifying        : libpsl-0.21.1-5.el9.x86_64                            1/12 
  Verifying        : pciutils-3.7.0-5.el9.x86_64                           2/12 
  Verifying        : pciutils-libs-3.7.0-5.el9.x86_64                      3/12 
  Verifying        : publicsuffix-list-dafsa-20210518-3.el9.noarch         4/12 
  Verifying        : ethtool-2:6.2-1.el9.x86_64                            5/12 
  Verifying        : iputils-20210202-9.el9.x86_64                         6/12 
  Verifying        : procps-ng-3.3.17-14.el9.x86_64                        7/12 
  Verifying        : hwdata-0.348-9.15.el9.noarch                          8/12 
  Verifying        : jq-1.6-17.el9.x86_64                                  9/12 
  Verifying        : net-tools-2.0-0.64.20160912git.el9.x86_64            10/12 
  Verifying        : oniguruma-6.9.6-1.el9.6.x86_64                       11/12 
  Verifying        : wget-1.21.1-8.el9_4.x86_64                           12/12 
Installed products updated.

Installed:
  ethtool-2:6.2-1.el9.x86_64                                                    
  hwdata-0.348-9.15.el9.noarch                                                  
  iputils-20210202-9.el9.x86_64                                                 
  jq-1.6-17.el9.x86_64                                                          
  libpsl-0.21.1-5.el9.x86_64                                                    
  net-tools-2.0-0.64.20160912git.el9.x86_64                                     
  oniguruma-6.9.6-1.el9.6.x86_64                                                
  pciutils-3.7.0-5.el9.x86_64                                                   
  pciutils-libs-3.7.0-5.el9.x86_64                                              
  procps-ng-3.3.17-14.el9.x86_64                                                
  publicsuffix-list-dafsa-20210518-3.el9.noarch                                 
  wget-1.21.1-8.el9_4.x86_64                                                    

Complete!
--> 108b7547a2ae
STEP 4/7: WORKDIR /root
--> 7e959df27b7d
STEP 5/7: RUN dnf clean all
Updating Subscription Management repositories.
subscription-manager is operating in container mode.
43 files removed
--> 5cc0bd064f99
STEP 6/7: COPY entrypoint.sh /root/entrypoint.sh
--> fa3771b64203
STEP 7/7: ENTRYPOINT ["/bin/bash", "/root/entrypoint.sh"]
COMMIT quay.io/redhat_emp1/ecosys-nvidia/mfttools:0.0.1
--> 60f8507c11c7
Successfully tagged quay.io/redhat_emp1/ecosys-nvidia/mfttools:0.0.1
60f8507c11c71d004cfba5f4c463a87bb133237a520902153806527a707ecf16
~~~

Once the image has been built push the image up to the registry that the Openshift cluster can access.

~~~bash
# podman push quay.io/redhat_emp1/ecosys-nvidia/oracle-oci:1.5.0

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
$ cat <<EOF > mfttool-pod-nvd-srv-32.yaml
apiVersion: v1
kind: Pod
metadata:
  name: mfttool-pod-nvd-srv-32
  namespace: mfttool
spec:
  nodeSelector: 
    kubernetes.io/hostname: nvd-srv-32.nvidia.eng.rdu2.dc.redhat.com
  hostNetwork: true
  serviceAccountName: mfttool
  containers:
  - image: quay.io/redhat_emp1/ecosys-nvidia/mfttools:0.0.1
    name: mfttool-pod-nvd-srv-32
    securityContext:
      privileged: true
EOF
~~~

Once the customer resource file has been generated, create the resource on the cluster.mfttool-pod-nvd-srv-32

~~~bash
oc create -f mfttool-pod-nvd-srv-32.yaml
pod/mfttool-pod-nvd-srv-32 created
~~~

Validate that the pod is up and running.

~~~bash
$ oc get pods -n mfttool
NAME                     READY   STATUS    RESTARTS   AGE
mfttool-pod-nvd-srv-32   1/1     Running   0          28s
~~~
