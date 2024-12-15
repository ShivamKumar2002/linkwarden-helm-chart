# Linkwarden Helm Chart (Unofficial) 🔗

This Helm chart deploys [Linkwarden](https://linkwarden.app/), a self-hosted, open-source collaborative bookmark manager to collect, organize and preserve webpages, on a Kubernetes cluster.


## Table of Contents 📚

- [Linkwarden Helm Chart (Unofficial) 🔗](#linkwarden-helm-chart-unofficial-)
  - [Table of Contents 📚](#table-of-contents-)
  - [Overview 🎯](#overview-)
  - [Features ✨](#features-)
  - [Security Considerations 🔒](#security-considerations-)
  - [Dependencies 📦](#dependencies-)
  - [Quick Start 🚀](#quick-start-)
  - [Configuration ⚙️](#configuration-️)
    - [`values.yaml` Deep Dive 🧐](#valuesyaml-deep-dive-)
    - [CNPG PostgreSQL Database 🐘](#cnpg-postgresql-database-)
      - [CNPG Operator Installation ⚙️](#cnpg-operator-installation-️)
    - [Storage Options 🗄️](#storage-options-️)
    - [Ingress Configuration 🌐](#ingress-configuration-)
    - [External Database Configuration 💽](#external-database-configuration-)
    - [SSO (Single Sign-On) Configuration 🔑](#sso-single-sign-on-configuration-)
  - [Setup Instructions 🛠️](#setup-instructions-️)
  - [Upgrading ⬆️](#upgrading-️)
  - [Troubleshooting 🐞](#troubleshooting-)
  - [Contributing 🤝](#contributing-)
  - [License 📜](#license-)
  - [Credits 🙏](#credits-)


## Overview 🎯

[Linkwarden](https://linkwarden.app/) is a self-hosted, open-source collaborative bookmark manager to collect, organize and archive webpages.

The objective is to organize useful webpages and articles you find across the web in one place, and since useful webpages can go away (see the inevitability of Link Rot), Linkwarden also saves a copy of each webpage as a Screenshot and PDF, ensuring accessibility even if the original content is no longer available.

Additionally, Linkwarden is designed with collaboration in mind, sharing links with the public and/or allowing multiple users to work together seamlessly. Linkwarden allows you to save, tag, and organize links, as well as automatically archive the content for future access.

This Helm chart simplifies the deployment of Linkwarden within a Kubernetes environment, providing flexibility in terms of storage, database, and network configuration.

If you find this chart helpful, please consider giving it a star on GitHub! ⭐ Your support is greatly appreciated!


## Features ✨

- **Simplified Deployment:** Easily deploy Linkwarden on Kubernetes using Helm.
- **Flexible Configuration:** Customize the deployment with a wide range of options via the `values.yaml` file.
- **Built-in PostgreSQL Database:** Optionally deploy Linkwarden with an integrated PostgreSQL database using the CNPG operator.
- **External Database Support:** Connect to an external PostgreSQL database.
- **Filesystem or S3 Storage:** Choose between local filesystem storage using a Persistent Volume Claim or S3-compatible object storage for data persistence.
- **Ingress Support:** Expose Linkwarden to the internet using Ingress rules.
- **SSO Integration:** Supports multiple SSO providers for user authentication.
- **Resource Management:** Configure CPU/memory resource requests and limits.
- **Autoscaling:** Automatically scale the number of Linkwarden replicas based on demand.
- **Security Contexts:** Configure pod and container security contexts for enhanced security.
- **Customizable Probes:** Configure liveness and readiness probes for health monitoring.
- **Easy Upgrades:** Easily upgrade the chart to newer versions with Helm.


## Security Considerations 🔒

- **Secrets Management:** Ensure that sensitive values (like `nextAuthSecret`, database passwords for external databases, and API keys) are properly handled, ideally using Kubernetes secrets and not directly in `values.yaml`.
- **Ingress Security:** When using ingress, configure TLS/SSL to ensure secure connections.
- **Resource Limits:** Set appropriate resource limits to prevent denial-of-service situations and ensure stability.
- **Pod Security Context:** Use the `podSecurityContext` and `containerSecurityContext` to apply principle of least privilege.
- **Network Policies:** (Optional) Consider implementing network policies to restrict network access between pods and services, especially for the database if you are not using the internal one.


## Dependencies 📦

- Kubernetes 1.25+
- Helm 3+
- (Optional) For Ingress: An Ingress Controller (e.g., Nginx, Traefik)
- (Optional) CloudNativePG (CNPG) Operator if using the built-in PostgreSQL database.


## Quick Start 🚀

1.  **Add the Helm repository (if necessary):**
    
    ```bash
    helm repo add shivam-charts https://shivamkumar2002.github.io/helm-charts
    helm repo update
    ```

2.  **Install the chart:**

    ```bash
    helm install linkwarden shivam-charts/linkwarden -f <values.yaml>
    ```
    
    *Replace `<values.yaml>` with the path to your values.yaml file or create one. See the [Configuration](#configuration) section for details.*

3.  **Access Linkwarden:**
    - If you have an ingress configured, access it through the URL specified in your ingress configuration.
    - If not, you may need to set up port forwarding. Please refer to your Kubernetes setup.


## Configuration ⚙️

This section details the configurable values in the `values.yaml` file and how they influence the deployment.

### `values.yaml` Deep Dive 🧐

Here's a breakdown of each section in your `values.yaml`:

| Key | Description | Default Value |
| --- | ----------- | ------------- |
| `nameOverride` | Overrides the chart's name. | `""` |
| `fullnameOverride` | Overrides the chart's full name for resource naming. | `""` |
| `replicaCount` | The number of Linkwarden application replicas. | `1` |
| `image.repository` | The container image repository. | `ghcr.io/linkwarden/linkwarden` |
| `image.pullPolicy` | The policy for pulling images (`IfNotPresent`, `Always`, `Never`). | `IfNotPresent` |
| `image.tag` | Overrides the image tag. Defaults to chart app version if left empty. | `""` |
| `imagePullSecrets` | Array of secrets used to pull images from private repositories. | `[]` |
| `serviceAccount.create` | Whether to create a service account. | `true` |
| `serviceAccount.automount` | Automatically mount the service account's API credentials. | `true` |
| `serviceAccount.annotations` | Annotations for the service account. | `{}` |
| `serviceAccount.name` | The name of the service account. If not set, one will be generated. | `""` |
| `service.type` | The service type (`ClusterIP`, `NodePort`, `LoadBalancer`). | `ClusterIP` |
| `service.port` | The service port exposed by the Linkwarden application. | `3000` |
| `livenessProbe.path` | The path to check for liveness. | `/` |
| `livenessProbe.port` | The port to check for liveness. | `http` |
| `livenessProbe.initialDelaySeconds` | Delay before the first liveness probe. | `30` |
| `livenessProbe.periodSeconds` | Frequency of the liveness probe. | `30` |
| `readinessProbe.path` | The path to check for readiness. | `/` |
| `readinessProbe.port` | The port to check for readiness. | `http` |
| `readinessProbe.initialDelaySeconds` | Delay before the first readiness probe. | `30` |
| `readinessProbe.periodSeconds` | Frequency of the readiness probe. | `30` |
| `linkwarden.existingSecret` | If set, all other Linkwarden environment secrets will be ignored and taken from this secret. | `""` |
| `linkwarden.nextAuthUrl` | The URL of the NextAuth API. | `http://localhost:3000/api/v1/auth` |
| `linkwarden.nextAuthSecret` | A secret used for NextAuth. You can generate with `openssl rand -base64 32`. | `""` |
| `linkwarden.disableRegistration` | Disable user registration. | `false` |
| `linkwarden.credentialsEnabled` | Enable login with username and password. | `true` |
| `linkwarden.disableNewSSOUsers` | Disable new user login with SSO. | `false` |
| `linkwarden.paginationTakeCount` | Number of Links to fetch on the webpage. | `50` |
| `linkwarden.maxWorkers` | Max number of playwright workers. | `5` |
| `linkwarden.reArchiveLimit` | How often a user can trigger a new archive for each link (in minutes). | `5` |
| `linkwarden.autoScrollTimeout` | The amount of time to wait for the website to be archived (in seconds). | `30` |
| `linkwarden.browserTimeout` | Browser timeout for archiving in miliseconds. | `30000` |
| `linkwarden.ignoreUnauthorizedCA` | Ignore certificate verification. | `false` |
| `linkwarden.ignoreHttpsErrors` | Ignore HTTPS errors. | `false` |
| `linkwarden.disablePreservation` | Disable archiving links. | `false` |
| `linkwarden.emailProvider` | Enable email. Must set `emailFrom` and `emailServer`. | `""` |
| `linkwarden.emailFrom` | Email from address. Ignored if `existingSecret` is set. | `""` |
| `linkwarden.emailServer` | Email server configuration. | `""` |
| `linkwarden.emailBaseUrl` | Base URL for links in emails. | `""` |
| `linkwarden.environment` | Additional environment variables for Linkwarden. | `{}` |
| `linkwarden.storage.type` | Storage type: `s3` or `filesystem`. | `filesystem` |
| `linkwarden.storage.storageFolder` | Storage folder if using `filesystem`. | `/data/data` |
| `linkwarden.storage.pvc.enabled` | Whether to create a Persistent Volume Claim for filesystem storage. | `true` |
| `linkwarden.storage.pvc.existingClaim` | If you are providing an existing PVC, add its name here. | `""` |
| `linkwarden.storage.pvc.storageClass` | Storage class for the Persistent Volume Claim. | `""` |
| `linkwarden.storage.pvc.accessModes` | Access modes for the Persistent Volume Claim. | `["ReadWriteOnce"]` |
| `linkwarden.storage.pvc.size` | Size of the persistent volume. | `5Gi` |
| `linkwarden.storage.s3.accessKey` | AWS S3 access key. | `""` |
| `linkwarden.storage.s3.secretKey` | AWS S3 secret key. | `""` |
| `linkwarden.storage.s3.endpoint` | AWS S3 endpoint. | `""` |
| `linkwarden.storage.s3.bucketName` | AWS S3 bucket name. | `""` |
| `linkwarden.storage.s3.region` | AWS S3 region. | `""` |
| `linkwarden.storage.s3.forcePathStyle` | AWS S3 force path style (for Minio). | `false` |
| `linkwarden.externalDatabaseUrl` | URL to an external PostgreSQL database (Optional). | `""` |
| `linkwarden.sso.existingSecret` | Name of the secret holding SSO environment variables. | `""` |
| `linkwarden.sso.providers` | A map of SSO providers and their configurations. | `{}` |
| `postgresql.enabled` | Enables the integrated CNPG PostgreSQL database. | `true` |
| `postgresql.cluster.instances` | Number of PostgreSQL instances. | `1` |
| `postgresql.cluster.storage.size` | Size of the persistent volume for PostgreSQL. | `2Gi` |
| `postgresql.cluster.storage.storageClass` | Storage class for the persistent volume. | `""` |
| `ingress.enabled` | Enables or disables ingress. | `false` |
| `ingress.className` | Ingress class name. | `""` |
| `ingress.annotations` | Annotations for ingress. | `{}` |
| `ingress.hosts` | List of host rules. | `[]` |
| `ingress.tls` | List of TLS configurations. | `[]` |
| `resources` | Resource limits and requests for the Linkwarden container. | `{}` |
| `podAnnotations` | Annotations to add to the Linkwarden pod. | `{}` |
| `podLabels` | Labels to add to the Linkwarden pod. | `{}` |
| `autoscaling.enabled` | Enables horizontal pod autoscaling. | `false` |
| `autoscaling.minReplicas` | Minimum number of replicas. | `1` |
| `autoscaling.maxReplicas` | Maximum number of replicas. | `100` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization for autoscaling. | `80` |
| `podSecurityContext` | Pod Security Context settings. | `{}` |
| `containerSecurityContext` | Container Security Context settings. | `{}` |
| `nodeSelector` | Node labels to select for scheduling pods. | `{}` |
| `tolerations` | Tolerations for scheduling pods. | `[]` |
| `affinity` | Affinity rules for scheduling pods. | `{}` |


### CNPG PostgreSQL Database 🐘

This chart includes an *optional* inbuilt PostgreSQL database using the CloudNativePG (CNPG) Operator. This is enabled by default.

- If `postgresql.enabled` is `true`, a PostgreSQL cluster will be deployed within your Kubernetes cluster.
- You can configure the number of instances, storage, and storage class in the `postgresql` section.
- If you use the internal PostgreSQL database, you do not need to set the `linkwarden.externalDatabaseUrl`.
- **Important**: If you enable the internal PostgreSQL database, you **MUST** have the [CloudNativePG Operator](https://cloudnative-pg.io) installed in your cluster.

#### CNPG Operator Installation ⚙️

1.  Add the CloudNativePG Helm repository:
    ```bash
    helm repo add cnpg https://cloudnative-pg.github.io/charts
    helm repo update
    ```

2.  Install the CNPG Operator:
    ```bash
    helm install cnpg cnpg/cloudnative-pg -n cnpg-system --create-namespace
    ```
    *You can choose a different namespace than `cnpg-system` if you want.*

3. Wait for the operator to be ready.
    ```bash
    kubectl -n cnpg-system get pods -l app.kubernetes.io/name=cloudnative-pg
    ```
    *Make sure the pod is in Running state.*


### Storage Options 🗄️

The chart supports two main storage options for Linkwarden data:

1.  **Filesystem Storage:**
    - Uses a Persistent Volume Claim (PVC) to store data in the specified folder: `/data/data`.
    - Enable by setting `linkwarden.storage.type` to `filesystem`.
    - Configure PVC settings under `linkwarden.storage.pvc`.
2. **S3 Storage:**
    - Uses s3 compatible storage to store data.
    - Enable by setting `linkwarden.storage.type` to `s3`.
    - Configure S3 settings under `linkwarden.storage.s3`.


### Ingress Configuration 🌐

- To expose Linkwarden outside the cluster, you can enable the ingress by setting `ingress.enabled` to `true`.
- You will need an Ingress controller (like Nginx or Traefik) installed in your cluster.
- Configure hostnames, paths, and TLS settings in the `ingress` section.


### External Database Configuration 💽

- To use an external PostgreSQL database, set `postgresql.enabled` to `false`, and provide the database URL through the `linkwarden.externalDatabaseUrl` value.
- **Note:** Ensure that the Linkwarden application can reach the database from within the Kubernetes cluster.


### SSO (Single Sign-On) Configuration 🔑

- The `sso` section allows you to configure various SSO providers.
- Refer to the NextAuth.js documentation for the specific settings per provider.
- If `linkwarden.sso.existingSecret` is set all environment variables required for SSO will be taken from that secret.
- Add your provider config to `linkwarden.sso.providers` to enable that provider.


## Setup Instructions 🛠️

1.  **Install Kubernetes:** Make sure you have a working Kubernetes cluster.
2.  **Install Helm:** Follow the official Helm installation guide.
3.  **Create a `values.yaml`:** Customize your `values.yaml` file. Start with the default file and customize based on the details in the [Configuration](#configuration) section of this file.
    - ⚠️ You **MUST** set a `nextAuthSecret`. Generate with `openssl rand -base64 32`
    - You might want to change `linkwarden.nextAuthUrl` if you are not accessing the service at `http://localhost:3000`.
    - If you enable the internal PostgreSQL database you do not need to change any database related settings.
    - If you use an external PostgreSQL database set `postgresql.enabled` to `false`, and provide the database URL through the `linkwarden.externalDatabaseUrl` value.
    - If you enable email you **MUST** specify `emailProvider`, `emailFrom`, and `emailServer`.
    - If you are using an s3 compatible object storage provider, ensure you have all the correct `linkwarden.storage.s3` settings.
4.  **Install the chart:** Use the Helm command in the [Quick Start](#quick-start) section.


## Upgrading ⬆️

To upgrade the chart to a newer version:

1.  Update your Helm repository:
    ```bash
    helm repo update
    ```
2.  Upgrade the release:
    ```bash
    helm upgrade linkwarden shivam-charts/linkwarden -f <values.yaml>
    ```


## Troubleshooting 🐞

- Check the logs of the Linkwarden pod for errors using `kubectl logs <pod-name>`.
- Verify that all necessary Kubernetes objects were created successfully.
- Ensure the database is reachable and properly configured.
- If you have any issues, please open an issue on [GitHub Issues](https://github.com/shivamkumar2002/linkwarden-helm-chart/issues).


## Contributing 🤝

Contributions are welcome! Please follow these steps:

1.  Fork the repository: [https://github.com/shivamkumar2002/linkwarden-helm-chart](https://github.com/shivamkumar2002/linkwarden-helm-chart)
2.  Create a new branch.
3.  Implement your changes.
4.  Submit a pull request.


## License 📜

This chart is licensed under the MIT License.


## Credits 🙏

- [Linkwarden](https://github.com/linkwarden/linkwarden)
- [CloudNativePG Operator](https://cloudnative-pg.io/)
- [Helm](https://helm.sh/)