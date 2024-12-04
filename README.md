# Containerization NVIDIA MFT Tooling

Containerization of the NVIDIA MFT Tooling

**Goal**: The goal of this document is to make the NVIDIA MFT Tooling containerized to allow for firmware settings and firmware updates.

## NVIDIA MFT Tooling

The MFT package is a set of firmware management tools used to:

* Generate a standard or customized NVIDIA firmware image Querying for firmware information
* Burn a firmware image

The following is a list of the available tools in MFT, together with a brief description of what each tool performs. 

| **Component**   | **Description/Function                                                                                                                               |
|-----------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
| mst             | * Starts/stops the register access driver Lists the available mst devices                                                                            |
|                 | * Lists the available mst devices                                                                                                                    |
|-----------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
| mlxburn         | * Generation of a standard or customized NVIDIA firmware image for burning (.bin or .mlx),
mst
	This tool provides the following functions:
    * Starts/stops the register access driver
    * Lists the available mst devices
mlxburn
	This tool provides the following functions:
    * Generation of a standard or customized NVIDIA firmware image for burning (in binary or .mlx format)
    * Burning an image to the Flash/EEPROM attached to a NVIDIA HCA or switch device
    * Querying the firmware version loaded on an NVIDIA network adapter
    * Displaying the VPD (Vital Product Data) of an NVIDIA network adapter
flint
	This tool burns a firmware binary image or an expansion ROM image to the Flash device of a NVIDIA network adapter/gateway/switch device. It includes query functions to the burnt firmware image and to the binary image file.
Debug utilities
	A set of debug utilities (e.g., itrace, fwtrace, mlxtrace, mlxdump, mstdump, mlxmcg, wqdump, mcra, mlxi2c, i2c, mget_temp, and pckt_drop)


## Workflow Sections

- [Requirements](#requirements)
- [Building The Container](#building-the-container)
- [Running The Container](#running-the-container)
- [Validate The Container](#validate-the-container)

## Requirements

To build the NVIDIA MFT Tooling in a container we will obtain the following componets during container runtime on a UBI9 container.

| **Component**                                  | **Description**                                                                                                                                      |
|------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
| **mlnx-tools-23.07-1.el9.noarch.rpm**          | Mellanox userland tools and scripts [repo here](https://github.com/Mellanox/mlnx-tools)                                                              |
| **mft-4.29.0-131-x86_64-rpm.tgz**              | NVIDIA Firmware Tools (MFT) available [here](https://network.nvidia.com/products/adapter-software/firmware-tools/)                                   |

## Building The Container

To build the container run the `podman build` command on a Red Hat Enterprise Linux 9.x system using the Dockerfile.oci provided in this repository.

~~~bash
# podman build . -f Dockerfile.oci -t quay.io/redhat_emp1/ecosys-nvidia/oracle-oci:1.5.0
STEP 1/35: FROM registry.access.redhat.com/ubi9/ubi:9.5-1730489303
STEP 2/35: WORKDIR /root
--> Using cache 49bf31146abb4da08e705c0b93dc670e6fc8e36d60ffdbb1948dd6e1d7f79642
--> 49bf31146abb
STEP 3/35: COPY oracle-cloud-agent-1.45.0-2.el8.x86_64.rpm /root/oracle-cloud-agent-1.45.0-2.el8.x86_64.rpm
--> Using cache 42d212b9057cc832d29e54870a7d3b1b602ef025098c8e3ac512d15c6ef27221
--> 42d212b9057c
STEP 4/35: COPY mft-4.29.0-131-x86_64-rpm.tgz /root/mft-4.29.0-131-x86_64-rpm.tgz
--> Using cache 6f8515f840442146645fd39f6b567b2467f6450f795eb4333a0734f386da0703
--> 6f8515f84044
STEP 5/35: COPY mlnx-tools-23.07-1.el9.noarch.rpm /root/mlnx-tools-23.07-1.el9.noarch.rpm
--> Using cache 4f801a3fe52702aaaa0c7cf0d65988c6c9d1e8ff3d283d40f71cbb09772e2ff0
--> 4f801a3fe527
STEP 6/35: COPY wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.bak
--> Using cache cf7b8cb1fe003a285783fd4b5d2867f03df4ab072819a633e7ddbbe9b13d8487
--> cf7b8cb1fe00
STEP 7/35: COPY getkeys.sh /root/getkeys.sh
--> Using cache 3845ffd69e9a2810eaf8473937727476a1616ce8110c8b60070ff17771dc84ce
--> 3845ffd69e9a
STEP 8/35: COPY ibdev2netdev /usr/sbin/ibdev2netdev
--> Using cache 624d4ea555a707910b796ed65a750f1e027f698a1404dac2992f826bdd8d683e
--> 624d4ea555a7
STEP 9/35: COPY wpa-supplicant-fixer.sh /usr/bin/wpa-supplicant-fixer.sh
--> Using cache eab45745881df56f6979c7eb0e53d6c508e88b54a5eb087c4075f24ecb9b353b
--> eab45745881d
STEP 10/35: COPY wpa_supplicant_fixer.service /etc/systemd/system/wpa_supplicant_fixer.service
--> Using cache b301aad17211c7e50fc0e98065e041db6b98b9408c46b081b5b4c1852c07a361
--> b301aad17211
STEP 11/35: RUN chmod +x /usr/bin/wpa-supplicant-fixer.sh
--> Using cache c2e6f039ddc87b1ac5f64f5281aa9d3235fe1b63d84a6b76e4b9e7ff07dc5934
--> c2e6f039ddc8
STEP 12/35: RUN chmod +x /usr/sbin/ibdev2netdev
--> Using cache a5b4ec25349ac8d056594d85b5aaecf1f01dd201b98a78622ec80ae44cfb04fb
--> a5b4ec25349a
STEP 13/35: RUN dnf install systemd wpa_supplicant sudo procps-ng pciutils yum jq iputils ethtool net-tools -y
--> Using cache ded6837226a8f889c9a597190675b665d4db793f29ec4c12811ffb4bccb2856a
--> ded6837226a8
STEP 14/35: RUN dnf install /root/oracle-cloud-agent-1.45.0-2.el8.x86_64.rpm -y
--> Using cache 5de7b3b4e5da176fcfe257044adb9d0368f26261cba5595f74aad0a239c0ed05
--> 5de7b3b4e5da
STEP 15/35: RUN dnf install /root/mlnx-tools-23.07-1.el9.noarch.rpm -y
--> Using cache 6c52d05af7c72844a5a69e41e9cf90b396b8ba2b9a5f0369d737bd597190f695
--> 6c52d05af7c7
STEP 16/35: RUN systemctl enable wpa_supplicant_fixer.service
--> Using cache 94626d13922f38605f8b795b4c12062ee2ebd4efe614328ef82fa5a5170e2840
--> 94626d13922f
STEP 17/35: RUN systemctl enable wpa_supplicant.service
--> Using cache 8153ee3d4aae30f75eb166aaa2763df43b2cb11c72f648358d34ac14997f060e
--> 8153ee3d4aae
STEP 18/35: RUN systemctl enable oracle-cloud-agent.service 
--> Using cache 25e1ea5dc4f5ac47e91f69ff7d5cd267ff5ad14e563d122d338d2be92aee5c8b
--> 25e1ea5dc4f5
STEP 19/35: RUN mkdir -p  /etc/oracle-cloud-agent/plugins/oci-hpc/oci-hpc-configure/
--> Using cache f8eafce3660fe50b6da6a5b62bef2a956b58dc1a9868f9f765d70e3e4bf9d239
--> f8eafce3660f
STEP 20/35: COPY rdma_network.json /etc/oracle-cloud-agent/plugins/oci-hpc/oci-hpc-configure/rdma_network.json
--> Using cache 7c42328c2a8ae57c7d10edb36e594d1e162fd279e44a80d62028db82533bbc96
--> 7c42328c2a8a
STEP 21/35: RUN sed -i '/name: oci-hpc-rdma-configure/,/name: oci-hpc-gpu-configure/ s/enabled: true/enabled: false/' /etc/oracle-cloud-agent/plugins/oci-hpc/oci-hpc-configure/config.yml
--> Using cache d043d664233e9f7837da9e46eeeac5851421b8ad74f566bacea6a91d528bfd71
--> d043d664233e
STEP 22/35: RUN tar -xzvf mft-4.29.0-131-x86_64-rpm.tgz
mft-4.29.0-131-x86_64-rpm/LICENSE.txt
mft-4.29.0-131-x86_64-rpm/RPMS/
mft-4.29.0-131-x86_64-rpm/RPMS/mft-4.29.0-131.x86_64.rpm
mft-4.29.0-131-x86_64-rpm/RPMS/mft-oem-4.29.0-131.x86_64.rpm
mft-4.29.0-131-x86_64-rpm/RPMS/mft-autocomplete-4.29.0-131.x86_64.rpm
mft-4.29.0-131-x86_64-rpm/RPMS/mft-pcap-4.29.0-131.x86_64.rpm
mft-4.29.0-131-x86_64-rpm/SDEBS/
mft-4.29.0-131-x86_64-rpm/SDEBS/kernel-mft-dkms_4.29.0-131_all.deb
mft-4.29.0-131-x86_64-rpm/SRPMS/
mft-4.29.0-131-x86_64-rpm/SRPMS/kernel-mft-4.29.0-131.src.rpm
mft-4.29.0-131-x86_64-rpm/install.sh
mft-4.29.0-131-x86_64-rpm/old-mft-uninstall.sh
mft-4.29.0-131-x86_64-rpm/uninstall.sh
--> 3bc9a84ee581
STEP 23/35: WORKDIR /root/mft-4.29.0-131-x86_64-rpm
--> 0c930fa5e2fb
STEP 24/35: RUN ./install.sh --without-kernel
-I- Removing any old MFT file if exists...
Verifying...                          ########################################
Preparing...                          ########################################
Updating / installing...
mft-4.29.0-131                        ########################################
Verifying...                          ########################################
Preparing...                          ########################################
Updating / installing...
mft-autocomplete-4.29.0-131           ########################################
-I- In order to start mst, please run "mst start".
--> 5240fb587fb1
STEP 25/35: RUN ln -s /usr/bin/flint /usr/bin/msflint
--> 16c5b535876e
STEP 26/35: RUN ln -s /usr/bin/mlxreg /usr/bin/mstreg
--> a2e22c4a3cc6
STEP 27/35: RUN ln -s /usr/bin/mlxfwreset /usr/bin/mstfwreset
--> f40fad3e085b
STEP 28/35: RUN ln -s /usr/sbin/ethtool /usr/bin/ethtool
--> 64369526e1a8
STEP 29/35: WORKDIR /root
--> 7b7e538b289e
STEP 30/35: RUN dnf clean all
Updating Subscription Management repositories.
subscription-manager is operating in container mode.
43 files removed
--> 3832d82717f6
STEP 31/35: RUN rm -r -f /root/oracle-cloud-agent-1.45.0-2.el8.x86_64.rpm
--> a0385b23b6ec
STEP 32/35: RUN rm -r -f /root/mft-4.29.0-131-x86_64-rpm.tgz
--> 6b5586008689
STEP 33/35: RUN rm -r -f /root/mlnx-tools-23.07-1.el9.noarch.rpm
--> 7835e4e2a140
STEP 34/35: RUN rm -r -f /root/mft-4.29.0-131-x86_64-rpm
--> ef0c71a9fffe
STEP 35/35: CMD [ "/usr/sbin/init" ]
COMMIT quay.io/redhat_emp1/ecosys-nvidia/oracle-oci:1.5.0
--> 1b19455a6955
Successfully tagged quay.io/redhat_emp1/ecosys-nvidia/oracle-oci:1.5.0
1b19455a69550c7216656ee60e1d5ff2050b2a41e0166642b13f637e6f5670df
~~~

Once the image has been built push the image up to the registry that the Openshift cluster can access.

~~~bash
# podman push quay.io/redhat_emp1/ecosys-nvidia/oracle-oci:1.5.0
Getting image source signatures
Copying blob 45f3b16e76ca skipped: already exists  
Copying blob a0edb06f3d95 skipped: already exists  
Copying blob 0a5f0e7aa998 skipped: already exists  
Copying blob 1185184a19a8 skipped: already exists  
Copying blob 530400eb1afc skipped: already exists  
Copying blob ed1fce3fb3d4 skipped: already exists  
Copying blob b232fad78b90 skipped: already exists  
Copying blob 399f20e727e6 skipped: already exists  
Copying blob 27ac1bfe7a83 skipped: already exists  
Copying blob 888694853151 skipped: already exists  
Copying blob 6cf357b69be4 skipped: already exists  
Copying blob 1dbf8ec5a2fe skipped: already exists  
Copying blob 5e46c3599fe3 skipped: already exists  
Copying blob 1309dc2f5f72 skipped: already exists  
Copying blob 402acf4d2107 skipped: already exists  
Copying blob 4117a584cf02 done   | 
Copying blob 2c70fa59fdc0 done   | 
Copying blob 06d3df41d5cc skipped: already exists  
Copying blob bcb9a3ed0220 done   | 
Copying blob c3bb9a2ae8cd done   | 
Copying blob 702355118cd0 skipped: already exists  
Copying blob ba734637264d done   | 
Copying blob bda820d0e050 done   | 
Copying blob ebb6418dcecd skipped: already exists  
Copying blob b92799f7db07 done   | 
Copying blob 6d716739c0e5 skipped: already exists  
Copying blob 3c7cbf11eefa done   | 
Copying blob e77ba3d644c9 done   | 
Copying blob 26b8f3df440c done   | 
Copying blob 67b3bcb9081d done   | 
Copying blob 7d0f31f42747 done   | 
Copying blob 22bcb118b334 done   | 
Copying config 1b19455a69 done   | 
Writing manifest to image destination
~~~

## Running The Container

Before launching the container make sure that `NodeNetworkConfigurationPolicy` custom resources have been applied to the baremetal nodes in the Oracle environment.  These policies need to manually assign static ipaddresses for the RDMA interfaces which enable the Oracle agent to properly authenticate them.

To run the Oracle Agent we first need to make a project and serviceaccount.  Here I am calling them ociagent respectively in the resource file.

~~~bash
$ cat <<EOF > oci-agent-project.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ociagent
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ociagent
  namespace: ociagent
EOF
~~~

Once the resource file is generated create it on the cluster.

~~~bash
$ oc create -f oci-agent-project.yaml 
namespace/ociagent created
serviceaccount/ociagent created
~~~

Now that the project has been created assign the appropriate privileges to the service account.

~~~bash
$ oc -n ociagent adm policy add-scc-to-user privileged -z ociagent
clusterrole.rbac.authorization.k8s.io/system:openshift:scc:privileged added: "ociagent"
~~~

Next we will create a pod yaml for each of our baremetal nodes that will run under the ociagent namespace and leverage the Oracle image we built.

~~~bash
$ cat <<EOF > oci-agent-pod-a100-01.yaml
apiVersion: v1
kind: Pod
metadata:
  name: oci-agent-pod-a100-01
  namespace: ociagent
spec:
  nodeSelector: 
    kubernetes.io/hostname: gpu-cluster-a100-01.private.openshiftvcn.oraclevcn.com
  hostNetwork: true
  serviceAccountName: ociagent
  containers:
  - image: quay.io/redhat_emp1/ecosys-nvidia/oracle-oci:1.1.2
    name: oci-agent-pod-a100-01
    securityContext:
      privileged: true
EOF
~~~

Once the customer resource file has been generated, create the resource on the cluster.

~~~bash
$ oc create -f oci-agent-pod-a100-01.yaml 
pod/oci-agent-pod-a100-01 created
~~~

Validate that the pod is up and running.

~~~bash
$ oc get pods -n ociagent
NAME                    READY   STATUS    RESTARTS   AGE
oci-agent-pod-a100-01   1/1     Running   0          49s
~~~
