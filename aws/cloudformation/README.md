
# Deploying Dremio to AWS

_Note:_ To try on AWS, you should have:
* Permission to create Security Groups
* An AWS key pair created
* (Optional) A VPC and subnet created if you want to install to a non-default VPC

Try it out [![AWS Cloudformation](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://us-east-2.console.aws.amazon.com/cloudformation/home?region=us-east-2#/stacks/new?templateURL=https://s3-us-west-2.amazonaws.com/aws-cloudformation.dremio.com/dremio_cf.yaml&stackName=myDremio)

This deploys a Dremio cluster on EC2 instances. The deployment creates a master coordinator node and number of executor nodes depending on the size of the cluster chosen. The table below provides the machine type and number of executor nodes for the different sizes of Dremio clusters.

| Cluster size | Coordinator VM Type | Executor VM Type | No. of Executors |
|--------------|---------------------|------------------|------------------|
| X-Small      | m5.2xlarge          | r5d.4xlarge      |        1         |
| Small        | m5.2xlarge          | r5d.4xlarge      |        5         |
| Medium       | m5.4xlarge          | r5d.4xlarge      |        10        |
| Large        | m5.4xlarge          | r5d.4xlarge      |        25        |
| X-Large      | m5.4xlarge          | r5d.4xlarge      |        50        |

Make sure you are in the AWS region you are planning to deploy your cluster in.

The inputs required during deployment are:

|Input Parameter|Description |
|---|---|
| Stack name |Name of the stack. |
| Cluster Size |Pick a size based on your needs.|
| Deploy to VPC |VPC to deploy the cluster into.|
| Deploy to Subnet |Subnet to deploy the cluster into. Must be in the selected VPC.|
| Dremio Binary | Publicly accessible URL to a Dremio installation RPM |
| AWS keypair | AWS key pair to use to SSH to the VMs. SSH username for the VMs are centos (has sudo privilege). SSH into machines for changing configuration, reviewing logs, etc. |

Once the deployment is successful, you will find the URL to Dremio UI in the output section of the deployment.
