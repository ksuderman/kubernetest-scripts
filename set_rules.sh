#!/usr/bin/env bash

if [[ $# != 2 ]] ; then
	echo "USAGE: $0 CLOUD RULES"
	echo "EXAMPE: $0 aws rules_4x16.yml"
	exit 1
fi

cloud=$1

if [[ ! -e ./$1.sh ]] ; then
	echo "Unrecognized cloud $cloud. Must be one of js, aws, gcp, or iu"
	exit
fi

source ./$1.sh
shift

if [[ ! -e $KUBECONFIG ]] ; then
	echo "ERROR: the kubeconfig file $KUBECONFIG not found."
	echo "Please check your setup and try again."
	exit 1
fi

rules = $1

if [[ ! -e $rules ]] ; then
	echo "Error: cannot find rules file: $rules" 
	exit 1
fi

helm upgrade --reuse-values -n $NAMESPACE galaxy cloudve/galaxy --set-file jobs.rules."container_mapper_rules\.yml"=$rules

