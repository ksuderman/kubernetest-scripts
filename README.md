# Kubernetes Scripts

This repository contains several scripts for interacting with pods in the various Kubernetes clusters.

## Prerequisites

1. [Kubectl](https://kubernetes.io/docs/tasks/tools/) is a command line program for interacting with and controlling Kubernetes clusters.  If you have previously installed any tools for GCP (Google Cloud Platform) or AWS (Amazon Web Services) you may already have a version of kubectl installed.
2. The kubeconfig file for each of the clusters.  These will be provided via a separate channel (.e.g. Slack).

**NOTE** it is important to keep the kubeconfig files private as the kubeconfig files are equivalent to having the *root* password to the server.  Do **not** share the kubeconfig files (unless instructed to do so) and do **not** check the files into source control.  

## Setup

Once `kubectl` and `helm` (see below) have been installed we need individual setup and configuration for each of the clusters we will be working with.  This setup is done with several simple Bash shell scripts, one per cluster, that defines things like the [namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/), name of the Postgresql pod, and the location of the kubeconfig file for that cluster.  You will not run these `.sh` files, rather they are *sourced* from other scripts that want to interact with the cluster. 

A sample configuration looks like:

```
export NAMESPACE=galaxy
export POD=galaxy-galaxy-galaxy-postgres-0
export KUBECONFIG=~/.kube/configs/aws
```

The only field that might need to be changed is the location of the kubeconfig file.  By default `kubectl` and `helm` expect this file to be `~/.kube/config`. However, since we are working with multiple clusters it is easier to have multiple kubeconfig files, one per cluster.  It is recommended, but not required, to create a directory named `~/.kube/configs` (note the trailing letter 's') and place the kubeconfig files there.  If you put the kubeconfig files in a different location you will need to edit the `aws.sh`, `gcp.sh`, `js.sh`, and `iu.sh` files to point to the correct locations.

If you copy the kubeconfig files to the default location then none of these files need changing. 

**NOTE** the `iu` cluster is a Galaxy instance running on Jetstream that can be used for testing.  Do not run any  benchmarks on this cluster if you want to keep the data as the cluster may disappear at any time without notice. It is useful if you want to play with `kubectl` and `helm` without fear of accidentally borking the cluster, or if you are debugging new workflows and don't want the results in the Galaxy database. 

The URL is http://149.165.157.18/galaxy/ and it is available in Rancher as `ks-iu-bm-dev`.

## SQL Queries

#### query.sh

To extract data and statistics from a Galaxy instance we need to be able to run SQL queries in the Postgresql pod in the cluster.  The `query.sh` script can be used to execute arbitrary SQL queries on the Postgresql pod.

```
./query.sh [aws|gcp|js|iu] query_file_name_without_sql_extension
# For example
./query.sh aws all_history_runtimes
```

The results of the query will be saved as a CSV in the `results` directory.  The `results` directory will be created if it does not already exist.  The name of the results file will follow the convention

```
<cloud>-<query_name>.csv
```

So the above command will create a results file named `results/aws-all_history_runtimes.sql`

#### query-all.sh

The `query-all.sh` script is similar to the `query.sh` script except that it runs one or more SQL queries on all of the clusters.  Pass the names of the queries to be executed without the `.sql` extension.  The script expects to find the SQL query file in the `sql` directory.

```
./query-all.sh numjob total_cpu_time total_memory all_history_runtimes
```

The results will be written to the `results` directory as CSV files using the same naming convention as the `query.sh` script.

# Helm Scripts

[Helm](https://helm.sh/docs/intro/install/) is a command line program used to install and manage applications on a Kubernetes cluster. We can use Helm to change the values in the  `container_mapper_rules.yml` file from the command line without having to login to the Rancher server and edit the YAML in a web browser.

### Prerequisites

1. Install [Helm](https://helm.sh/docs/intro/install/).

2. Add the [CloudVE](https://github.com/cloudve/) Helm repository and update.

   ```
   helm repo add https://raw.githubusercontent.com/CloudVE/helm-charts/master/
   helm repo update
   ```

### Usage

```
./set_rules.sh <cloud> <rules_file.yml>

# E.G.
./set_rules.sh aws rules_4x16.yml
```

The `set_rules.sh` script uses the same `.sh` files to set the $KUBECONFIG variable and should be in the same directory as the cloud `.sh` files and the `query.sh` script above.

After updating the cluster with Helm you will have to wait a few minutes for the pods to be restarted by Kubernetes.  You can check the status of the redeloyment with:

```
# For checking the AWS cluster
source aws.sh
kubectl get pods -n $NAMESPACE
```

You can create as many *rules* files as you wish with whatever resource requirements you want to benchmark.

