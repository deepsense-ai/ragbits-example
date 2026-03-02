resource "aws_secretsmanager_secret" "api_key" {
  name                    = "openai-api-key-${var.app_name}"
  recovery_window_in_days = 0 # forces immediate deletion on destroy
}

resource "aws_ecr_repository" "repo" {
  name         = "${var.app_name}-repo"
  force_delete = true
}

resource "aws_iam_role" "apprunner_access_role" {
  name = "${var.app_name}-access-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "build.apprunner.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "apprunner_ecr" {
  role       = aws_iam_role.apprunner_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

resource "aws_apprunner_service" "app" {
  service_name = var.app_name

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_access_role.arn
    }
    image_repository {
      image_identifier      = "${aws_ecr_repository.repo.repository_url}:latest"
      image_repository_type = "ECR"
      image_configuration {
        port = "8080"
        runtime_environment_secrets = {
          OPENAI_API_KEY = aws_secretsmanager_secret.api_key.arn
        }
      }
    }
  }

  instance_configuration {
    instance_role_arn = aws_iam_role.apprunner_instance_role.arn
  }

  depends_on = [
    aws_iam_role_policy_attachment.apprunner_secrets_attachment
  ]
}

resource "aws_iam_role" "apprunner_instance_role" {
  name = "${var.app_name}-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "tasks.apprunner.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "apprunner_secrets_policy" {
  name        = "${var.app_name}-secrets-policy"
  description = "Allow App Runner to read the OpenAI API key secret"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "secretsmanager:GetSecretValue",
      Resource = aws_secretsmanager_secret.api_key.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "apprunner_secrets_attachment" {
  role       = aws_iam_role.apprunner_instance_role.name
  policy_arn = aws_iam_policy.apprunner_secrets_policy.arn
}

# setting up WAF to allow only deployer's IP to access the App Runner service
resource "aws_wafv2_ip_set" "my_ip" {
  name               = "${var.app_name}-ip-allowlist"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = [var.my_ip] 
}

resource "aws_wafv2_web_acl" "apprunner_acl" {
  name        = "${var.app_name}-firewall"
  description = "Block all traffic except my IP"
  scope       = "REGIONAL"

  default_action {
    block {}
  }

  rule {
    name     = "AllowMyIP"
    priority = 1
    action {
      allow {}
    }
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.my_ip.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "AllowMyIP"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "AppRunnerFirewall"
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_web_acl_association" "app_waf" {
  resource_arn = aws_apprunner_service.app.arn
  web_acl_arn  = aws_wafv2_web_acl.apprunner_acl.arn
}