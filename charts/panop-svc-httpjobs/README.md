# svc-httpjobs

Panop HTTP consumer service to dispatch scanning jobs into the Panop platform.

## TL;DR

```console
helm repo add panop-charts https://panop-io.github.io/panop-charts
helm install svc-httpjobs panop-charts/svc-httpjobs
```

## Introduction

`svc-httpjobs` is a lightweight HTTP consumer that receives scan job requests and dispatches them into the Panop
platform. It is optimized to run in Kubernetes environments with built-in support for autoscaling, concurrency control,
and integration with Panop scanners.

This service is typically deployed behind an ingress or API gateway and is designed to handle high-throughput job
submissions reliably.

---

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- Access to Panop container registry
- (Optional) Access to secrets manager (e.g., Vault)

---

## Installing the Chart

To install the chart with default settings:

```console
helm install svc-httpjobs panop-charts/svc-httpjobs
```

> **Tip**: To view all Helm releases, use `helm list`.

You can customize the deployment by overriding configuration values using `--set` or a custom `values.yaml`.

Example with custom values:

```console
helm install svc-httpjobs \
  --set domain=prod \
  --set engine=kubernetes \
  panop-charts/svc-httpjobs
```

Or using a YAML file:

```console
helm install svc-httpjobs -f my-values.yaml panop-charts/svc-httpjobs
```

---

## Uninstalling the Chart

To uninstall and delete the `svc-httpjobs` release:

```console
helm uninstall svc-httpjobs
```

This will remove all associated Kubernetes resources.

---

## Parameters

### Global Configuration

| Name     | Description                             | Default      |
|----------|-----------------------------------------|--------------|
| `domain` | Deployment domain (e.g., `dev`, `prod`) | `dev`        |
| `engine` | Deployment engine (e.g., `kubernetes`)  | `kubernetes` |

### Image Settings

| Name               | Description                       | Default                                  |
|--------------------|-----------------------------------|------------------------------------------|
| `image.repository` | Docker repository for the service | `exo.container-registry.com/panop/panop` |
| `image.pullPolicy` | Image pull policy                 | `IfNotPresent`                           |

### Deployment Settings

| Name                    | Description                                | Default                  |
|-------------------------|--------------------------------------------|--------------------------|
| `replicas`              | Number of replicas to deploy               | `1`                      |
| `concurrency`           | Max concurrent HTTP jobs per pod           | `5`                      |
| `nodeSelector`          | Node selector for scheduling               | `{ nodeType: standard }` |

### Scanner Configuration

| Name                   | Description                              | Default                                              |
|------------------------|------------------------------------------|------------------------------------------------------|
| `scanner.id`           | Scanner id                               | no default                                           |
| `scanner.token`        | Scanner token to communicate with tower  | no default                                           |
| `scanner.namespace`    | Namespace where jobs are run             | default                                              |
| `scanner.ratelimit`    | API rate limit for scanner               | `20`                                                 |
| `scanner.appversion`   | App version to scan with                 | `latest`                                             |
| `scanner.registry`     | Container registry for the scanner       | `exo.container-registry.com/panop/panop-svc-scanner` |
| `scanner.image`        | Scanner image name                       | `panop-scanner-offensive`                            |
| `scanner.loglevel`     | Log level for scanner logs               | `info`                                               |
| `scanner.limit_memory` | Memory limit for scanner containers      | `1800Mi`                                             |
| `scanner.pullsecret`   | Kubernetes pull secret for scanner image | `panop-exocr`                                        |

### Resource Requests & Limits

| Name                        | Description    | Default |
|-----------------------------|----------------|---------|
| `resources.requests.cpu`    | CPU request    | `200m`  |
| `resources.requests.memory` | Memory request | `300Mi` |
| `resources.limits.cpu`      | CPU limit      | `500m`  |
| `resources.limits.memory`   | Memory limit   | `400Mi` |

### Logging

| Name       | Description         | Default |
|------------|---------------------|---------|
| `loglevel` | Log verbosity level | `info`  |

---

## Example Values

```yaml
domain: dev
engine: kubernetes

image:
  repository: exo.container-registry.com/panop/panop
  pullPolicy: IfNotPresent
replicas: 1

## imagecredentials are used for consumer and jobs
imageCredentials:
  - registry: exo.container-registry.com
    username: ""
    accessToken: ""

existingImageCredentials: "-"

concurrency: 5 ## number jobs launch concurrently

secret: "-"   # create or use existing secret

resources:
  limits:
    cpu: 500m
    memory: 400Mi
  requests:
    cpu: 200m
    memory: 200Mi

loglevel: info

## if you want node selector
kubernetes:
  tolerations:
    - key: "dedicated"
      operator: "Equal"
      value: "foo"
      effect: "NoSchedule"
    - key: "env"
      operator: "Equal"
      value: "bar"
      effect: "NoSchedule"
  nodeType: "-"


scanner:
  id: <scanner id>
  token: <tower token>
  namespace: default
  ratelimit: 20
  appversion: latest
  registry: exo.container-registry.com/panop/panop-svc-scanner
  image: panop-scanner-standard
  loglevel: info
  limit_memory: 1800Mi
```

---

## License

```text
Copyright © 2023 Panop

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at:

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.
```
