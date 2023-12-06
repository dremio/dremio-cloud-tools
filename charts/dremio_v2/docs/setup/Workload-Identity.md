# Workload Identity Setup

When using a GCS bucket on GKE, we recommend setting up a GCP Bucket with access restricted
to a single GCP Service Account. This GCP Service Account can be used for authentication within 
the Kubernetes cluster with Workload Identity.

### GKE Cluster and IAM Setup

For more in depth information about cluster setup, 
please refer to the [official documentation](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity#gcloud)

#### Create a New Cluster Using Workload Identity

To enable Workload Identity on a new cluster, run the following command:
```
gcloud container clusters create CLUSTER_NAME \
    --region=COMPUTE_REGION \
    --workload-pool=PROJECT_ID.svc.id.goog
```
Replace the following:

* CLUSTER_NAME: the name of your new cluster.
* COMPUTE_REGION: the Compute Engine region of your cluster. For zonal clusters, use --zone=COMPUTE_ZONE.
* PROJECT_ID: your Google Cloud project ID.

#### Upgrade an Existing Cluster to Use Workload Identity

To enable Workload Identity on an existing cluster, run the following command:
```
gcloud container clusters update CLUSTER_NAME \
    --region=COMPUTE_REGION \
    --workload-pool=PROJECT_ID.svc.id.goog
```
* CLUSTER_NAME: the name of your existing cluster.
* COMPUTE_REGION: the Compute Engine region of your cluster. For zonal clusters, use --zone=COMPUTE_ZONE.
* PROJECT_ID: your Google Cloud project ID.

#### Create a GCP Service Account
Create an IAM service account for your application or use an existing IAM service account instead.
You can use any IAM service account in any project in your organization.
To create a new IAM service account using the gcloud CLI, run the following command. Replace `PROJECT_ID`
with your Google Cloud project ID.

```
gcloud iam service-accounts create dremio-deployment-sa \
    --project=PROJECT_ID
```

### Grant the GCP Service Account Access to the Bucket
The GCP Service Account must have access to the bucket. To grant access using the gcloud CLI, 
run the following command.

```
gcloud storage buckets add-iam-policy-binding gs://BUCKET_NAME \
    --member=serviceAccount:dremio-deployment-sa@PROJECT_ID.iam.gserviceaccount.com \
    --role=roles/storage.objectAdmin
```
* BUCKET_NAME: the name of the bucket you are granting the principal access to
* PROJECT_ID: your Google Cloud project ID.

#### Create Binding between Kubernetes Service Account and GCP IAM Service Account
Allow the Kubernetes service account to impersonate the IAM service account by adding an IAM policy binding between the 
two service accounts. This binding allows the Kubernetes service account to act as the IAM service account.

```
gcloud iam service-accounts add-iam-policy-binding dremio-deployment-sa@PROJECT_ID.iam.gserviceaccount.com \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:PROJECT_ID.svc.id.goog[NAMESPACE/dremio-coordinator-sa]"
```

### Update values.yaml
Configure `distStorage.gcp.credentials.clientEmail` with the email for the GCP service account
that has access to Google Cloud Storage bucket.


gcloud iam service-accounts add-iam-policy-binding dremio-deployment-sa@dremio-1093.iam.gserviceaccount.com \
--role roles/iam.workloadIdentityUser \
--member "serviceAccount:dremio-1093.svc.id.goog[bngo-1703102893/dremio-coordinator-sa]"
