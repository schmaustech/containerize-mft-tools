# Containerization NVIDIA MFT Tooling

Containerization of the NVIDIA MFT Tooling

**Goal**: The goal of this document is to make the NVIDIA MFT Tooling containerized to allow for firmware settings and firmware updates.

## NVIDIA MFT Tooling

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

## Workflow Sections

- [Requirements](#requirements)
- [Building The Container](#building-the-container)
- [Running The Container](#running-the-container)
- [Validate The Container](#validate-the-container)

## Requirements

To build the NVIDIA MFT Tooling in a container we will obtain the following componets during container runtime on a UBI9 container as we do not want to ship these in our container.

| **Component**                                  | **Description**                                                                                                                                      |
|------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
| **mlnx-tools-23.07-1.el9.noarch.rpm**          | Mellanox userland tools and scripts [repo here](https://github.com/Mellanox/mlnx-tools)                                                              |
| **mft-4.29.0-131-x86_64-rpm.tgz**              | NVIDIA Firmware Tools (MFT) available [here](https://network.nvidia.com/products/adapter-software/firmware-tools/)                                   |

## Building The Container

To build the container run the `podman build` command on a Red Hat Enterprise Linux 9.x system using the Dockerfile.oci provided in this repository.

~~~bash

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
$ oc -n ociagent adm policy add-scc-to-user privileged -z mfttool
clusterrole.rbac.authorization.k8s.io/system:openshift:scc:privileged added: "mfttool"
~~~

Next we will create a pod yaml for each of our baremetal nodes that will run under the mfttool namespace and leverage the MFT tooling.

~~~bash
$ cat <<EOF > mfttool-pod-a100-01.yaml
apiVersion: v1
kind: Pod
metadata:
  name: mfttool-pod-a100-01
  namespace: ociagent
spec:
  nodeSelector: 
    kubernetes.io/hostname: gpu-cluster-a100-01.private.openshiftvcn.oraclevcn.com
  hostNetwork: true
  serviceAccountName: mfttool
  containers:
  - image: quay.io/redhat_emp1/ecosys-nvidia/mfttool:1.1.2
    name: mfttool-pod-a100-01
    securityContext:
      privileged: true
EOF
~~~

Once the customer resource file has been generated, create the resource on the cluster.

~~~bash
$ oc create -f mfttool-pod-a100-01.yaml 
pod/mfttool-pod-a100-01 created
~~~

Validate that the pod is up and running.

~~~bash
$ oc get pods -n mfttool
NAME                    READY   STATUS    RESTARTS   AGE
mfttool-pod-a100-01   1/1     Running   0          49s
~~~
