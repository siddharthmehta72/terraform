variable "image" {default = "ubuntu-os-cloud/ubuntu-1604-lts"}
variable "name" {default = "instance-1"}
variable "machine_type" {
    type = map
    default = {
        dev = "f1-micro"   
        prod = "n1-standard-1" 
    }
}
variable "name_count" {default=["server1","server2","server3"]}
