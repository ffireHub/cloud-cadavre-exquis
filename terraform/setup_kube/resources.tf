###
# Create the ssh key pair in both openstack & ovh api
###
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# registers private key in ssh-agent
resource null_resource "register_ssh_private_key" {
  triggers = {
    key = base64sha256(tls_private_key.private_key.private_key_pem)
  }
}

# Keypair which will be used on nodes and bastion
resource "openstack_compute_keypair_v2" "keypair" {
  name       = var.name
  public_key = tls_private_key.private_key.public_key_openssh
  provider   = openstack.ovh
  depends_on = [null_resource.register_ssh_private_key]
}


###
# Create the security group
###

resource "openstack_networking_secgroup_v2" "kube_secgroup_controller" {
  name        = "kube security group controller"
  description = "Security group for Kubernetes cluster"
}

resource "openstack_networking_secgroup_rule_v2" "Kubernetes_API_server" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = "0.0.0.0/0" # Adjust this as needed for your security requirements
  security_group_id = openstack_networking_secgroup_v2.kube_secgroup_controller.id
}

resource "openstack_networking_secgroup_rule_v2" "Etcd_server_client_API" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2379
  port_range_max    = 2380
  remote_ip_prefix  = "0.0.0.0/0" # Adjust this as needed for your security requirements
  security_group_id = openstack_networking_secgroup_v2.kube_secgroup_controller.id
}

resource "openstack_networking_secgroup_rule_v2" "Kubelet_API_controller" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10250
  port_range_max    = 10250
  remote_ip_prefix  = "0.0.0.0/0" # Adjust this as needed for your security requirements
  security_group_id = openstack_networking_secgroup_v2.kube_secgroup_controller.id
}

resource "openstack_networking_secgroup_rule_v2" "kube-scheduler" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10251
  port_range_max    = 10251
  remote_ip_prefix  = "0.0.0.0/0" # Adjust this as needed for your security requirements
  security_group_id = openstack_networking_secgroup_v2.kube_secgroup_controller.id
}

resource "openstack_networking_secgroup_rule_v2" "kube-controller-manager" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10252
  port_range_max    = 10252
  remote_ip_prefix  = "0.0.0.0/0" # Adjust this as needed for your security requirements
  security_group_id = openstack_networking_secgroup_v2.kube_secgroup_controller.id
}

resource "openstack_networking_secgroup_v2" "kube_secgroup_worker" {
  name        = "kube security group worker"
  description = "Security group for Kubernetes cluster"
}

resource "openstack_networking_secgroup_rule_v2" "Kubelet_API_worker" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10250
  port_range_max    = 10250
  remote_ip_prefix  = "0.0.0.0/0" # Adjust this as needed for your security requirements
  security_group_id = openstack_networking_secgroup_v2.kube_secgroup_worker.id
}

resource "openstack_networking_secgroup_rule_v2" "NodePort_Services" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 30000
  port_range_max    = 32767
  remote_ip_prefix  = "0.0.0.0/0" # Adjust this as needed for your security requirements
  security_group_id = openstack_networking_secgroup_v2.kube_secgroup_worker.id
}


###
# Create the VM
###

resource "openstack_compute_instance_v2" "OVH_in_Fire_controller" {
  name        = "controller"
  provider    = openstack.ovh
  image_id    = "13beb57f-325b-4542-811d-bdeff2a9dc29"
  flavor_name = "c3-4"
  key_pair    = openstack_compute_keypair_v2.keypair.name
  user_data = <<-EOF
    #!/bin/bash
    echo "${join("\n", var.ssh_public_keys)}" > /tmp/authorized_keys
    sudo mv /tmp/authorized_keys /home/debian/.ssh/authorized_keys
    sudo chown debian:debian /home/debian/.ssh/authorized_keys
    sudo chmod 600 /home/debian/.ssh/authorized_keys
    echo "###" > /tmp/authorized_keys
  EOF
  security_groups = ["default", openstack_networking_secgroup_v2.kube_secgroup_controller.name]
  network {
    uuid = "6011fbc9-4cbf-46a4-8452-6890a340b60b"
    name = "Ext-Net"
  }
  connection {
    type        = "ssh"
    user        = "debian"
    private_key = tls_private_key.private_key.private_key_pem
    host        = self.floating_ip
  }

  provisioner "local-exec" {
    command =  <<-EOF
      export CONTROLLER_IPS=${openstack_compute_instance_v2.OVH_in_Fire_controller.network.0.fixed_ip_v4}
      echo "[controller]" > /tmp/controller_ips
      echo $CONTROLLER_IPS >> /tmp/controller_ips
      EOF
  }
}

resource "openstack_compute_instance_v2" "OVH_in_Fire_worker" {
  name        = "worker1"
  provider    = openstack.ovh
  image_id    = "13beb57f-325b-4542-811d-bdeff2a9dc29"
  flavor_name = "r3-16"
  key_pair    = openstack_compute_keypair_v2.keypair.name
  user_data = <<-EOF
    #!/bin/bash
    echo "${join("\n", var.ssh_public_keys)}" > /tmp/authorized_keys
    sudo mv /tmp/authorized_keys /home/debian/.ssh/authorized_keys
    sudo chown debian:debian /home/debian/.ssh/authorized_keys
    sudo chmod 600 /home/debian/.ssh/authorized_keys
    echo "###" > /tmp/authorized_keys
  EOF
  security_groups = ["default", openstack_networking_secgroup_v2.kube_secgroup_worker.name]
  network {
    uuid = "6011fbc9-4cbf-46a4-8452-6890a340b60b"
    name = "Ext-Net"
  }

  connection {
    type        = "ssh"
    user        = "debian"
    private_key = tls_private_key.private_key.private_key_pem
    host        = self.floating_ip
  }
  provisioner "local-exec" {
    command =  <<-EOF
      export WORKER_IPS=${openstack_compute_instance_v2.OVH_in_Fire_worker.network.0.fixed_ip_v4}
      echo "[workers]" > /tmp/worker_ips
      echo $WORKER_IPS >> /tmp/worker_ips
      EOF
  }
}


# resource "null_resource" "ansible_provisioning" {
#  depends_on = [openstack_compute_instance_v2.OVH_in_Fire_controller, openstack_compute_instance_v2.OVH_in_Fire_worker]

#  triggers = {
#    controller_id = openstack_compute_instance_v2.OVH_in_Fire_controller.id
#    worker_id = openstack_compute_instance_v2.OVH_in_Fire_worker.id
#  }

#  provisioner "local-exec" {
#    command = "ansible-playbook -u debian -i /tmp/worker_ips -i /tmp/controller_ips ./playbook.yml"
#  }
# }
