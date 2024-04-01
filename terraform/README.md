# Cloud deployment introduction

## The tools we used and why

### Terraform

Terraform is an open-source infrastructure as code software tool that allows us to define and provision a datacenter infrastructure using a high-level configuration language. We chose Terraform for its ability to manage complex infrastructure with simple, declarative configurations and its support for multiple providers such as OpenStack and OVH.

#### ssh key pair in both openstack & ovh api

We use Terraform to manage SSH key pairs across both OpenStack and OVH APIs. This approach allows us to provision the VMs with the resources we want, by connecting with ssh thanks to this keypair.

#### security group

Security groups are used to control access to resources within our cloud environments. Terraform helps us define and manage these groups to ensure that only authorized traffic can access our resources, enhancing the security of our deployments.

#### openstack_compute_instance_v2 "Fedora 38"

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

#### gotk-components.yal & gotk-sync.yaml & kustomization

gotk-components.yaml: This file contains the definitions for all the GitOps Toolkit (FluxCD) components required for the setup.

gotk-sync.yaml: Defines the GitRepository and Kustomization resources, telling FluxCD where to find the Kubernetes manifests in the Git repository and how to apply them.

kustomization: Used to customize the configuration before applying it, allowing us to modify configurations per environment or specific needs without changing the base manifests.