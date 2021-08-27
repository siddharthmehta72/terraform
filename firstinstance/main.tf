resource "google_compute_instance" "default" {

name = "list-${count.index+1}"

machine_type = "${var.machine_type["dev"]}"

count = "${length(var.name_count)}"

zone = "asia-south1-a"

boot_disk {
    initialize_params {
        image = "${var.image}"
    }
}

network_interface {
    network = "default"
}

service_account {
    scopes = ["userinfo-email","compute-ro","storage-ro"]
}
}
