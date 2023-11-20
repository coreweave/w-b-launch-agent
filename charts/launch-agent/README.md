# W&B Launch Agent

This chart deploys the W&B Launch Agent to your Kubernetes cluster.

The launch agent is a Kubernetes Deployment that runs a container that connects to the W&B API and watches for new runs in one or more launch queues. When the agent pops a run off the queue(s), it will launch a Kubernetes Job to execute the run on the W&B user's behalf.

To deploy an agent, you will need to specify the following values in [`values.yaml`](values.yaml):

- `agent.apiKey`: Your W&B API key
- `launchConfig`: The agent launch config

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
### 1 A40 GPU, Region - LAS, 8 vCPUs, 128Gi Memory

```
metadata:
  namespace: '<CW_NAMESPACE>'
spec:
  template:
    spec:
      containers:
      - image: '<DOCKER_IMAGE>'
        name: finetuner-llm
        env:
        - name: WANDB_API_KEY
          value: '<W_B_API_KEY>'
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
            medium: Memory
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