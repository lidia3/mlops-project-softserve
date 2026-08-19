output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.mlops.id
}

output "public_ip" {
  description = "Public IP address of the MLOps VM"
  value       = aws_instance.mlops.public_ip
}

output "mlflow_url" {
  description = "MLflow URL"
  value       = "http://${aws_instance.mlops.public_ip}:5000"
}

output "airflow_url" {
  description = "Airflow URL"
  value       = "http://${aws_instance.mlops.public_ip}:9001"
}

output "api_url" {
  description = "Web/API URL"
  value       = "http://${aws_instance.mlops.public_ip}:8080"
}
