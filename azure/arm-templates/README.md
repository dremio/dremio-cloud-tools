
# Deploying Dremio to Azure

You can try it out: [![Azure ARM Template](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/microsoft.template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdremio%2Fdremio-cloud-tools%2Fmaster%2Fazure%2Farm-templates%2Fazuredeploy.json)

This deploys a Dremio cluster on Azure VMs. The deployment creates a master coordinator node and number of executor nodes depending on the size of the cluster chosen. The table below provides the machine type and number of executor nodes for the different sizes of Dremio clusters.

| Cluster size | Coordinator VM Type | Executor VM Type | No. of Executors |
|--------------|---------------------|------------------|------------------|
| X-Small      | Standard_D4_v3      | Standard_E16s_v3 |        1         |
| Small        | Standard_D4_v3      | Standard_E16s_v3 |        5         |
| Medium       | Standard_D8_v3      | Standard_E16s_v3 |        10        |
| Large        | Standard_D8_v3      | Standard_E16s_v3 |        25        |
| X-Large      | Standard_D8_v3      | Standard_E16s_v3 |        50        |

The inputs required during deployment are:

|Input Parameter|Description |
|---|---|
| Subscription |Azure subscription where the cluster should be deployed. |
| Resource Group |The Azure Resource group where the cluster should be deployed. You can create a new one too. It is recommended to create a new one as all resources are created in that group and deleting the group will delete all resources created. |
| Location |The Azure location where the cluster resources will be deployed. |
| Cluster Name |A name for your cluster.|
| Cluster Size |Pick a size based on your needs.|
| SSH Username |The username that can be used to login to your nodes.|
| Authentication Type |Password or Key based authentication for ssh.|
| Password or SSH Public Key |The password or ssh public key |
| Use Existing Subnet | (Optional) id of an existing subnet. The subnet must be in the same region as the Dremio cluster resource group. It is of the form /subscriptions/xxxx/resourceGroups/xxxx/providers/Microsoft.Network/virtualNetworks/xxxx/subnets/xxxx|
| Use Private IP | Select true if you are using existing subnet and you want to use an internal ip from the subnet to access Dremio. |
| Dremio Binary | Publicly accessible URL to a Dremio installation rpm |

Once the deployment is successful, you will find the URL to Dremio UI in the output section of the deployment.

The deployment resources are:
```
┌───────────────────────────┐
│       WebUI on 9047       │
│ JDBC/ODBC client on 31010 │
└─────────────┬─────────────┘
              │
┌────────────────────────────┼─────────────────────────────────────┐
│ VirtualNetwork             │                                     │
│ ┌──────────────────────────▼───────────────────────────────────┐ │
│ │ Subnet     ┌──────────────────────────┐   ┌────────────────┐ │ │
│ │            │       LoadBalancer       │   │ Security Group │ │ │
│ │            └──────────────────┬───────┘   │Allow access to │ │ │
│ │                               │           │22, 9047, 31010 │ │ │
│ │           ┌───────────────────┘           └────────────────┘ │ │
│ │           │                                                  │ │
│ │           │                                                  │ │
│ │           ▼                                                  │ │
│ │ ┌───────────────────┐            ┌───────────────────┐       │ │
│ │ │Master Coordinator │            │     Executor      ├┐      │ │
│ │ │    (Azure VM)     │───────────▶│(Azure VM Scaleset)│├─┐    │ │
│ │ └───────────────────┘            └┬──────────────────┘│ │    │ │
│ │ ┌───────────────────┐             └─┬─────────────────┘ │    │ │
│ │ │  Dremio Metadata  │               └───────────────────┘    │ │
│ │ │   (Azure Disk)    │                                        │ │
│ │ └───────────────────┘                                        │ │
│ └──────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
```
