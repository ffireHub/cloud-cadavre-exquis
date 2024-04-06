# Cadavre exquis deployment

## Set up

### Required tools

- Git
- Terraform v1.7.4
- Ansible [core 2.14.9]

Additionnally, run this command to install kubernetes community : 
```bash
ansible-galaxy collection install community.kubernetes
```

And this command to clone the repository : 
```bash
git clone https://github.com/ffireHub/cloud-cadavre-exquis.git
```

### Configuration

You have to put you ssh public key in the file terraform/setup_cube/varaibles.tf where it is written "your-ssh-public-key-here"
You will also need to export all those variables in your environment : 
```bash
export OS_AUTH_URL=https://auth.cloud.ovh.net/v3
export OS_IDENTITY_API_VERSION=3
export OS_USER_DOMAIN_NAME=${OS_USER_DOMAIN_NAME:-"Default"}
export OS_PROJECT_DOMAIN_NAME=${OS_PROJECT_DOMAIN_NAME:-"Default"}
export OS_TENANT_ID=your-ovh-tenant-id
export OS_TENANT_NAME="your-ovh-tenant-name"
export OS_USERNAME="your-ovh-username"
export OS_PASSWORD="your-ovh-password"
export OS_REGION_NAME="your-ovh-region"
export TF_VAR_OS_APPLICATION_KEY="your-ovh-application-key"
export TF_VAR_OS_APPLICATION_SECRET="your-ovh-application-secret"
export TF_VAR_OS_CONSUMER_KEY="your-ovh-consumer-key"
export TF_VAR_GITHUB_TOKEN="necessary for flux but not used yet"
```

### Launching the deployment

Move into the terraform folder inside the downloaded project. 

Launch this command to initialize the Terraform working directory by creating initial files, loading remote state, download modules.
```bash
terraform init
```

Launch the following command to deploy the project on OVH
```bash
terraform apply
```

To stop the running instance of the application and destroy every resources
```bash
terraform destroy
```

To view the deployed application, you can access the URL in terraform/kube.conf by setlecting the ip in the server field
You would want to select the part between brackets below and past it to your browser to access the application.
```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ...
    server: https://{57.128.162.218}:6443
  name: kubernetes
contexts:
- context:
...
```
On the webpage you will have the following url http://57.128.162.218 which will work to access the application.

If an error occurs when you click the start button , you will want to restart the verb, adjective and subjects deployment running the following commands : 
```bash
kubectl rollout restart deployment cadavre-exquis-release-adjective --kubeconfig terraform/kube.conf -n cloud
kubectl rollout restart deployment cadavre-exquis-release-subject --kubeconfig terraform/kube.conf -n cloud
kubectl rollout restart deployment cadavre-exquis-release-verb --kubeconfig terraform/kube.conf -n cloud
```

## The tools we used and why

### Terraform

Terraform is an open-source infrastructure as code software tool that allows us to define and provision a datacenter infrastructure using a high-level configuration language. We chose Terraform for its ability to manage complex infrastructure with simple, declarative configurations and its support for multiple providers such as OpenStack and OVH.

#### ssh key pair in both openstack & ovh api

We use Terraform to manage SSH key pairs across both OpenStack and OVH APIs. This approach allows us to provision the VMs with the resources we want, by connecting with ssh thanks to this keypair.

#### security group

Security groups are used to control access to resources within our cloud environments. Terraform helps us define and manage these groups to ensure that only authorized traffic can access our resources, enhancing the security of our deployments.

#### openstack_compute_instance_v2 "Debian 12"

We utilize Terraform to provision OpenStack compute instances. For our deployments, we have chosen Fedora 38 for its cutting-edge features and robust community support. Terraform allows us to automate the deployment of these instances, ensuring consistency and reliability across our infrastructure.

### Ansible

Ansible is an open-source tool for software provisioning, configuration management, and application deployment. We use Ansible in conjunction with Terraform to configure and manage our cloud resources after they are provisioned. This combination allows us to automate our entire deployment pipeline, from infrastructure provisioning to application deployment.

### Kubernetes

Kubernetes is an open-source system for automating deployment, scaling, and management of containerized applications. We chose Kubernetes for its powerful orchestration capabilities, which allow us to manage our applications at scale efficiently.

#### Architecture

Our Kubernetes architecture consists of a controller and worker nodes, ensuring high availability and scalability of our applications.

##### A Controller

The controller node acts as the brain of the Kubernetes cluster, managing its state and configuration. It includes components like the API server.

##### A Worker

Worker nodes are responsible for running the containerized applications and are managed by the controller node. Each worker node runs kubelet, which communicates with the Kubernetes API to manage containers and pods.

#### Kubeadm

Kubeadm is a tool that helps you bootstrap a minimum viable Kubernetes cluster that conforms to best practices. We use kubeadm to simplify the process of setting up and configuring our Kubernetes cluster.

#### Kubectl

Kubectl is a command-line tool that allows us to run commands against Kubernetes clusters. We use it to deploy applications, inspect and manage cluster resources, and view logs.

#### Kubelet

Kubelet is an agent that runs on each node in the cluster. It ensures that containers are running in a Pod.

### Fluxcd

FluxCD is a set of continuous and progressive delivery solutions for Kubernetes that are open and extensible. It allows us to automate the deployment of applications to our Kubernetes cluster based on configurations stored in Git repositories.

We have started implementing FluxCD to leverage its capabilities for automating application deployments to our Kubernetes cluster, guided by the configurations in our Git repository. This approach aligns with modern DevOps practices, promising a streamlined deployment pipeline that can react swiftly to changes in source code or configuration. However, due to time constraints, we've not been able to finalize the integration of FluxCD fully. Additionally, the immediate benefits of this automation might seem limited since our primary goal was merely to deploy the applications, not necessarily to establish a continuous deployment pipeline. The decision was pragmatic, focusing on achieving deployment with the potential for future automation enhancements.