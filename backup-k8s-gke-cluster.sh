#!/usr/bin/env bash
#
# Writes cluster state to file.
# Assumes you already have Gcloud credentials loaded"

CLUSTER_NAME1="my-first-cluster"
CLUSTER_NAME2="my-second-cluster"
CLUSTER_NAME3="my-third-cluster"

PROJECT_NAME1="prod"
PROJECT_NAME2="qa"
PROJECT_NAME3="dev"

ZONE_NAME1="us-west1-a"
ZONE_NAME2="us-west1-b"
ZONE_NAME3="us-west1-b"

command -v yq >/dev/null 2>&1 || { echo >&2 "I require yq but it's not installed. Aborting."; exit 1; }

_save_cluster() {
    local -r filename=$1

    rm -f "$filename"

    for ns in $(kubectl get ns --no-headers | cut -d " " -f1); do
      if { [ "$ns" != "kube-system" ]; }; then
      kubectl --namespace="${ns}" get --export -o=yaml svc,rc,rs,deployments,cm,secrets,ds,statefulsets,ing | \
    yq -Y '.items[] |
        select(.type!="kubernetes.io/service-account-token") |
        del(
            .spec.clusterIP,
            .metadata.uid,
            .metadata.selfLink,
            .metadata.resourceVersion,
            .metadata.creationTimestamp,
            .metadata.generation,
            .status,
            .spec.template.spec.securityContext,
            .spec.template.spec.dnsPolicy,
            .spec.template.spec.terminationGracePeriodSeconds,
            .spec.template.spec.restartPolicy
        )' >> "$filename"
      fi
    done
}

readonly PREV_KUBE_CONTEXT=$(kubectl config current-context)
_cleanup() {
    kubectl config use-context "$PREV_KUBE_CONTEXT"
}
trap _cleanup EXIT

gcloud container clusters get-credentials $CLUSTER_NAME1 \
    --zone $ZONE_NAME1 --project $PROJECT_NAME1
_save_cluster k8s_backup/$CLUSTER_NAME1.yaml

gcloud container clusters get-credentials $CLUSTER_NAME2 \
    --zone $ZONE_NAME2 --project $PROJECT_NAME2
_save_cluster k8s_backup/$CLUSTER_NAME2.yaml

gcloud container clusters get-credentials $CLUSTER_NAME3 \
    --zone $ZONE_NAME3 --project $PROJECT_NAME3
_save_cluster k8s_backup/$CLUSTER_NAME3.yaml

