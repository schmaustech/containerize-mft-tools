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

- [Building The Container](#building-the-container)
- [Running The Container](#running-the-container)
- [Validate The Container](#validate-the-container)

## Building The Container

To build the container run the `podman build` command on a Red Hat Enterprise Linux 9.x system using the Dockerfile.mft provided in this repository.

~~~bash
$ podman build . -f dockerfile.mft -t quay.io/redhat_emp1/ecosys-nvidia/mfttools:0.0.5
STEP 1/7: FROM registry.access.redhat.com/ubi9/ubi:9.5-1730489303
STEP 2/7: WORKDIR /root
--> Using cache 49bf31146abb4da08e705c0b93dc670e6fc8e36d60ffdbb1948dd6e1d7f79642
--> 49bf31146abb
STEP 3/7: RUN dnf install wget procps-ng pciutils yum jq iputils ethtool net-tools -y
--> Using cache 108b7547a2ae1b421293e9fc4ed560f6c72f0cc9fa9af18330746db3e0bae249
--> 108b7547a2ae
STEP 4/7: WORKDIR /root
--> Using cache 7e959df27b7d83fb538fa30692f65be71f4d9aba1f047a9ffc9e1a494c9494f6
--> 7e959df27b7d
STEP 5/7: RUN dnf clean all
--> Using cache 5cc0bd064f9962b137bc8760e05b4fd8b37b8351977bcba81bd8c8ae96f6cc47
--> 5cc0bd064f99
STEP 6/7: COPY entrypoint.sh /root/entrypoint.sh
--> 654d0d4366d4
STEP 7/7: ENTRYPOINT ["/bin/bash", "/root/entrypoint.sh"]
COMMIT quay.io/redhat_emp1/ecosys-nvidia/mfttools:0.0.5
--> 2e4ea2bd5249
Successfully tagged quay.io/redhat_emp1/ecosys-nvidia/mfttools:0.0.5
2e4ea2bd524964fdb958f79d3bfb37b203a3a9a24490ecf01969caf4c43aa61d
~~~

Once the image has been built push the image up to the registry that the Openshift cluster can access.

~~~bash
$ podman push quay.io/redhat_emp1/ecosys-nvidia/oracle-oci:1.5.0

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
  - image: quay.io/redhat_emp1/ecosys-nvidia/mfttools:0.0.5
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

~~~bash
$ oc rsh -n mfttool mfttool-pod-nvd-srv-29 
sh-5.1#
~~~

~~~bash

~~~
