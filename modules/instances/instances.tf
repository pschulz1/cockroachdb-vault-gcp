resource "google_compute_instance" "node" {
  name         = "crdb-node-${var.node_id}"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["patrick", "schulz", "crdb"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork

    access_config {
      // Ephemeral public IP
    }
  }

  metadata_startup_script = data.template_file.crdb.rendered
  metadata = {
    ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = var.service_account
    scopes = ["cloud-platform", "userinfo-email", "compute-ro", "storage-ro"]
  }
}

resource "google_compute_disk" "crdb" {
  name                      = "crdb-data-disk"
  type                      = "pd-ssd"
  zone                      = var.zone
  size                      = 100
  physical_block_size_bytes = 4096
}

resource "google_compute_attached_disk" "default" {
  disk     = google_compute_disk.crdb.id
  instance = google_compute_instance.node.id
}

data "template_file" "crdb" {
  template = file("${path.module}/template/setup.tpl")

  vars = {
    crdb_version    = var.crdb_version
    region          = var.region
    zone            = var.zone
    vault_version   = var.vault_version
    vault_addr      = var.vault_addr
    service_account = var.service_account
    project_id      = var.project_id
  }
}

