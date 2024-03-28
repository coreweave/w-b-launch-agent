# W&B Launch Agent

This chart deploys the W&B Launch Agent to your Kubernetes cluster.

The launch agent is a Kubernetes Deployment that runs a container that connects to the W&B API and watches for new runs in one or more launch queues. When the agent pops a run off the queue(s), it will launch a Kubernetes Job to execute the run on the W&B user's behalf.

To deploy an agent, you will need to specify the following values in [`values.yaml`](values.yaml):

- `agent.apiKey`: Your W&B API key
  - Note: `agent.useExternalWandbSecret` can be set to `true` if you would like to provide your api key external to this helm chart.
- `launchConfig`: The literal contents of a launch agent config file that will be used to configure the agent. See the [launch agent docs](https://docs.wandb.ai/guides/launch/run-agent) for more information.

Please refer to the W&B Launch Docs: https://docs.wandb.ai/guides/launch for additional details for setup of the queue and configuration.

## Example Launch Config

```
  #W&B entity (i.e. user or team) name
  entity: '<W_B_ENTITY>'

  #Max number of concurrent runs to perform. -1 = no limit
  max_jobs: -1

  #List of queues to poll.
  queues:
    - '<W_B_QUEUE>'

  builder:
    type: noop
```


## Example Queue Config for CoreWeave 

```
spec:
  template:
    spec:
      containers:
      - image: '<DOCKER_IMAGE>'
        name: finetuner-llm
        resources:
          requests:
            memory: 128Gi
            cpu: 8
            nvidia.com/gpu: 1
          limits:
            memory: 128Gi
            cpu: 8
            nvidia.com/gpu: 1
        volumeMounts:
          - name: dshm
            mountPath: /dev/shm

      volumes:
        - emptyDir:
            sizeLimit: 64Gi
          name: dshm

      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: gpu.nvidia.com/class
                    operator: In
                    values:
                      - "A40"
                  - key: topology.kubernetes.io/region
                    operator: In
                    values:
                      - LAS1
      restartPolicy: Never
  backoffLimit: 1
```

## Chart variables

The table below describes all the available variables in the chart:

| Variable                       | Type            | Required             | Default                         | Description                                                                                                                                      |
| ------------------------------ | --------------- | -------------------- | ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `agent.labels`                 | object          | No                   | {}                              | Labels that will be added to the agent deployment.                                                                                               |
| `agent.apiKey`                 | string          | **Yes**<sup>\*</sup> | ""                              | W&B API key to be used by the agent.                                                                                                             |
| `agent.useExternalWandbSecret` | bool            | **false**            | ""                              | Used to indicate you want to provide the api key secret external to this chart.                                                                  |
| `agent.image`                  | string          | No                   | `wandb/launch-agent-dev:latest` | Container image for the agent.                                                                                                                   |
| `agent.imagePullPolicy`        | string          | No                   | `Always`                        | Pull policy for the agent container image.                                                                                                       |
| `agent.resources`              | object          | No                   | Limit to 1 CPU, 1Gi RAM         | Pod spec resources block for the agent.                                                                                                          |
| `agent.nodeSelector`           | object          | No                   | `{}`                            | Node selector for the agent pod.                                                                                                                 |
| `agent.resources`              | object          | No                   | Limit to 1 CPU, 1Gi RAM         | Pod spec resources block for the agent. true                                                                                                     |
| `agent.startTimeout`           | int             | No                   | `1800`                          | Timeout in seconds that the agent will wait for a job to start before timing out.                                                                |
| `agent.minAvailable`           | int             | No                   | `1`                             | Keep at 1 to prevent voluntary disruptions of the agent pod. Set to 0 to enable voluntary disruptions.                                           |
| `agent.tolerations`            | list(object)    | No                   | `[]`                            | Tolerations for the agent pod.                                                                                                                   |
| `namespace`                    | string          | No                   | `wandb`                         | The namespace to deploy the agent into.                                                                                                          |
| `additionalTargetNamespaces`   | list(string)    | No                   | [`wandb`,`default`]             | A list of namespaces the agent can run jobs in.                                                                                                  |
| `baseUrl`                      | string          | No                   | `https://api.wandb.ai`          | URL of your W&B server api.                                                                                                                      |
| `launchConfig`                 | mutiline string | **Yes**              | `null`                          | his should be set to the literal contents of your launch agent config.                                                                           |
| `volcano`                      | bool            | No                   | `true`                          | Controls whether the volcano scheduler should be installed in your cluster along with the agent. Set to `false` to disable volcano installation. |
| `gitCreds`                     | mutiline string | No                   | `null`                          | Contents of a git credentials file.                                                                                                              |
| `serviceAccount.annotations`   | object          | No                   | `null`                          | Annotations for the wandb service account.                                                                                                       |
| `azureStorageAccessKey`        | string          | No                   | ""                              | Azure storage access key required for kaniko to acces build contexts in azure blob storage.                                                      |
| `additionalEnvVars`            | map(string)     | No                   | {}                              | Map with environment variables to be set in the Launch Agent pod.                                                                                |
| `additionalSecretEnvVars`      | map(string)     | No                   | {}                              | Map with environment variables to be stored in the `launch-agent-secret-env-vars` secret and set in the Launch Agent Pod                         |
| `customCABundle`               | object          | No                   | {}                              | ConfigMap name and key with the CA Bundle content                                                                                                |
| `kanikoPvcName`                | string          | No                   | ""                              | Name of a PVC to pass build contexts from the agent to kaniko build containers.                                                                  |
| `kanikoDockerConfigSecret`     | string          | No                   | ""                              | Name of a kubernetes.io/dockerconfigjson secret that will be mounted in kaniko containers to grant access to private registries.                 |

- Note: `agent.useExternalWandbSecret` can be set to `true` if you would like to provide your api key external to this helm chart.
- `launchConfig`: The literal contents of a launch agent config file that will be used to configure the agent. See the [launch agent docs](https://docs.wandb.ai/guides/launch/run-agent) for more information.

