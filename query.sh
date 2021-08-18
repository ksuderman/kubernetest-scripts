#!/usr/bin/env bash

if [[ $# = 0 ]] ; then
	echo "USAGE: $0 CLOUD QUERY [QUERY...]"
	exit 1
fi

cloud=$1

if [[ ! -e ./$1.sh ]] ; then
	echo "Unrecognized cloud $cloud. Must be one of js, aws, gcp"
	exit
fi

source ./$1.sh
shift

if [[ ! -e $KUBECONFIG ]] ; then
	echo "The kubeconfig $KUBECONFIG is not found!"
	echo "Please check your configuration and try again."
	exit 1
fi

if [[ ! -e results ]] ; then
	mkdir results
fi

for query in $@ ; do
	kubectl exec -in $NAMESPACE $POD -- sudo -u postgres psql -d galaxy --csv < sql/$query.sql > results/$cloud-$query.csv
done
