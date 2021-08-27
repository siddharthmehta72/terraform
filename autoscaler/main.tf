#Instance Template <- Describe Instance 

resource "google_compute_instance_template" "instance_template" {
    name = "udemy-server-1"
    description = "This is our autoscaling template"
    #tags = [] # network

    labels = {
        environment = "production"
        name = "udemy-server-1"
    }

    instance_description = "This is an instance that has been auto scaled"
    machine_type = "n1-standard-1"
    can_ip_forward = "false"

    scheduling {
        automatic_restart = true
        on_host_maintenance = "MIGRATE"
    }

    disk {
        source_image = "ubuntu-os-cloud/ubuntu-1604-lts"
        auto_delete = true
        boot = true
    }

    disk {
        auto_delete = false
        disk_size_gb = 20
        mode = "READ_WRITE"
        type = "PERSISTENT"
    }

    network_interface {
        network = "default"
    }

    metadata = {
        foo = "bar"
    }

    service_account {
        scopes = ["userinfo-email", "compute-ro", "storage-ro"]
    }
}

# Health Check <-- Auto Scaling Policy (when to scale )
resource "google_compute_health_check" "health" {
    name  = "udemy"
    check_interval_sec = 5
    timeout_sec = 5
    healthy_threshold = 2
    unhealthy_threshold = 10

    http_health_check {
        request_path = "/alive.jsp"
        port =  "8080"
    }
}

# Group Manager < -- Manages the nodes 
resource "google_compute_region_instance_group_manager" "instancegroupmanager" {
  name = "instancegroupmanager"
  version{
      instance_template = "${google_compute_instance_template.instance_template.self_link}"
  }
  base_instance_name = "instance-group-manager-1"
  region = "europe-west2"
  auto_healing_policies {
    health_check = "${google_compute_health_check.health.self_link}"
    initial_delay_sec = "300"
  }
}

# Auto Scale Policy < -- How many instances 
resource "google_compute_region_autoscaler" "autoscaler" {
    count = 1 
    name = "autoscaler"
    project = "terraform-gcppoc"
    region = "europe-west2"
    target = "${google_compute_region_instance_group_manager.instancegroupmanager.self_link}"

    autoscaling_policy  {
        max_replicas = 4
        min_replicas = 2
        cooldown_period = 60
        cpu_utilization {
            target = "0.8"
        }
    } 
}

