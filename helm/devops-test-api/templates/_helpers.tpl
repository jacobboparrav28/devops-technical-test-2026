{{- define "devops-test-api.name" -}}
{{ .Chart.Name }}
{{- end }}
{{- define "devops-test-api.fullname" -}}
{{ include "devops-test-api.name" . }}-{{ .Release.Name }}
{{- end }}