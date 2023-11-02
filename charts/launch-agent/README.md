# W&B Launch Agent

This chart deploys the W&B Launch Agent to your Kubernetes cluster.

The launch agent is a Kubernetes Deployment that runs a container that connects to the W&B API and watches for new runs in one or more launch queues. When the agent pops a run off the queue(s), it will launch a Kubernetes Job to execute the run on the W&B user's behalf.

To deploy an agent, you will need to specify the following values in [`values.yaml`](values.yaml):

- `agent.apiKey`: Your W&B API key
- `launchConfig`: The agent launch config

## Example Launch Config

------------------------------
W&B entity (i.e. user or team) name
entity: <W_B_ENTITY>

Max number of concurrent runs to perform. -1 = no limit
max_jobs: -1

List of queues to poll.
queues:
  - <QUEUE_NAME>

builder:
  type: noop
------------------------------

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
| `namespace`                    | string          | No                   | `wandb`                         | The namespace to deploy the agent into.                                                                                                          |
| `additionalTargetNamespaces`   | list(string)    | No                   | [`wandb`,`default`]             | A list of namespaces the agent can run jobs in.                                                                                                  |
| `baseUrl`                      | string          | No                   | `https://api.wandb.ai`          | URL of your W&B server api.                                                                                                                      |
| `launchConfig`                 | mutiline string | **Yes**              | `null`                          | his should be set to the literal contents of your launch agent config.                                                                           |
| `volcano`                      | bool            | No                   | `true`                          | Controls whether the volcano scheduler should be installed in your cluster along with the agent. Set to `false` to disable volcano installation. |
| `gitCreds`                     | mutiline string | No                   | `null`                          | Contents of a git credentials file.                                                                                                              |
| `serviceAccount.annotations`   | object          | No                   | `null`                          | Annotations for the wandb service account.                                                                                                       |
| `azureStorageAccessKey`        | string          | No                   | ""                              | Azure storage access key required for kaniko to acces build contexts in azure blob storage.                                                      |
