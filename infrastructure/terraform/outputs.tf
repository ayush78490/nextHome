output "backend_public_ip" {
  description = "Public IP of the backend compute instance"
  value       = module.compute.public_ip
}

output "backend_private_ip" {
  description = "Private IP of the backend compute instance"
  value       = module.compute.private_ip
}

output "vcn_id" {
  description = "VCN OCID"
  value       = module.network.vcn_id
}

output "media_bucket_name" {
  description = "Object Storage bucket name for media"
  value       = oci_objectstorage_bucket.media.name
}

output "media_bucket_namespace" {
  description = "Object Storage namespace"
  value       = data.oci_objectstorage_namespace.ns.namespace
}

output "ssh_command" {
  description = "SSH command to connect to the backend instance"
  value       = "ssh -i ~/.ssh/nexthome_oci opc@${module.compute.public_ip}"
}

output "api_url" {
  description = "Backend API URL"
  value       = "http://${module.compute.public_ip}:3000/api/v1"
}
