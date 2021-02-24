
------------------------------------------

Instructions:

1. Download the configuration from the GitHub repository:
LINK - > https://github.com/pmutavdzija/home-test

2. Run the following commands:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

Terraform creates three clusters (eks-dev, eks-staging and eks-production), each with two nodes.

The running time is approximately 20 minutes.

What set of tools would you use with the cluster to make it production environment
ready? Why would you use them and what would be the benefit from using these
specific tools?

- AWS Account, with access (Access Key ID and Secret Access Key is necessary).
- Terraform CLI.
Why? Because it is an open-source tool. It is an automated way of building infrastructure (Infrastructure as a Code tool), more secure, scalable, and easy to maintain. A plan is built, of what we want to execute, and then Terraform creates the resources for us.
- A terminal to run Terraform CLI


• What monitoring and cluster services would you use and why?

I would use Datadog. Datadog is monitoring EKS environments in real-time. It provides metrics and logs from AWS. Also, it is enhancing the visibility of the monitoring stack.
