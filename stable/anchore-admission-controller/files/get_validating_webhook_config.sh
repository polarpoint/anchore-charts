#!/bin/bash

name=${1}
kubeConfig=${2}

KUBE_CA=$(cat ${kubeConfig} |  grep client-certificate-data | cut -f2 -d : | tr -d ' ')
cat > validating-webhook.yaml <<EOF
apiVersion: admissionregistration.k8s.io/v1beta1
kind: ValidatingWebhookConfiguration
metadata:
  name: ${name}-anchore-admission-controller.admission.anchore.io
webhooks:
- name: ${name}-anchore-admission-controller.admission.anchore.io
  clientConfig:
    service:
      namespace: default
      name: kubernetes
      path: /apis/admission.anchore.io/v1beta1/imagechecks
    caBundle: $KUBE_CA
  rules:
  - operations:
    - CREATE
    apiGroups:
    - ""
    apiVersions:
    - "*"
    resources:
    - pods
  failurePolicy: Fail
# Uncomment this and customize to exclude specific namespaces from the validation requirement
#  namespaceSelector:
#    matchExpressions:
#      - key: exclude.admission.anchore.io
#        operator: NotIn
#        values: ["true"]
EOF
