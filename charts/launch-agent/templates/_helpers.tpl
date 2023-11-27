{{- define "launchAgent.nodeAffinityAndTolerations" -}}
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: topology.kubernetes.io/region
              operator: In
              values:
                - {{ .Values.region }}
{{- end -}}
