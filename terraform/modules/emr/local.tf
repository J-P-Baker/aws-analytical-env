locals {
  fqdn                            = format("%s.%s.%s.", "emr", var.emr_cluster_name, var.root_dns_name)
  master_instance_type            = "m5.2xlarge"
  core_instance_type              = "m5.2xlarge"
  core_instance_count             = 1
  task_instance_type              = "m5.2xlarge"
  ebs_root_volume_size            = 100
  ebs_config_size                 = 250
  ebs_config_type                 = "gp2"
  ebs_config_volumes_per_instance = 1
  autoscaling_min_capacity        = 1
  autoscaling_max_capacity        = 5
  dks_port                        = 8443
  full_proxy                      = "http://${var.internet_proxy_dns_name}:3128"

  configurations_mysql_json = templatefile(format("%s/templates/emr/configuration.mysql.json", path.module), {
    logs_bucket_path             = format("s3://%s/logs", var.log_bucket)
    data_bucket_path             = format("s3://%s/data", aws_s3_bucket.emr.id)
    notebook_bucket_path         = format("%s/data", aws_s3_bucket.emr.id)
    proxy_host                   = var.internet_proxy_dns_name
    full_no_proxy                = join("|", local.no_proxy_hosts)
    r_version                    = local.r_version
    hive_metastore_endpoint      = var.hive_metastore_endpoint
    hive_metastore_database_name = var.hive_metastore_database_name
    hive_metastore_username      = var.hive_metastore_username
    hive_metastore_pwd           = var.hive_metastore_password
  })

  configurations_glue_json = templatefile(format("%s/templates/emr/configuration.glue.json", path.module), {
    logs_bucket_path     = format("s3://%s/logs", var.log_bucket)
    data_bucket_path     = format("s3://%s/data", aws_s3_bucket.emr.id)
    notebook_bucket_path = format("%s/data", aws_s3_bucket.emr.id)
    proxy_host           = var.internet_proxy_dns_name
    full_no_proxy        = join("|", local.no_proxy_hosts)
    r_version            = local.r_version
  })

  no_proxy_hosts = [
    local.fqdn,
    "jupyterhub",
    "127.0.0.1",
    "localhost",
    "169.254.169.254",
    "*.s3.${data.aws_region.current.name}.amazonaws.com",
    "s3.${data.aws_region.current.name}.amazonaws.com",
    "sns.${data.aws_region.current.name}.amazonaws.com",
    "sqs.${data.aws_region.current.name}.amazonaws.com",
    "${data.aws_region.current.name}.queue.amazonaws.com",
    "glue.${data.aws_region.current.name}.amazonaws.com",
    "sts.${data.aws_region.current.name}.amazonaws.com",
    "*.${data.aws_region.current.name}.compute.internal",
    "dynamodb.${data.aws_region.current.name}.amazonaws.com",
    "*.dkr.ecr.${data.aws_region.current.name}.amazonaws.com",
    "api.ecr.${data.aws_region.current.name}.amazonaws.com",
  ]
  r_version = "3.6.3"
  r_dependencies = [
    "devtools",
    "bestglm",
    "glmnet",
    "stringr",
    "tidyr",
    "V8",
  ]
  r_packages = [
    "bizdays",
    "boot",
    "cluster",
    "colorspace",
    "data.table",
    "deseasonalize",
    "DiagrammeR",
    "DiagrammeRsvg",
    "dplyr",
    "DT",
    "dyn",
    "feather",
    "flexdashboard",
    "forcats",
    "forecast",
    "ggplot2",
    "googleVis",
    "Hmisc",
    "htmltools",
    "htmlwidgets",
    "intervals",
    "kableExtra",
    "knitr",
    "lazyeval",
    "leaflet",
    "lubridate",
    "magrittr",
    "manipulate",
    "maps",
    "networkD3",
    "plotly",
    "plyr",
    "RColorBrewer",
    "readr",
    "reshape",
    "reshape2",
    "reticulate",
    "rjson",
    "RJSONIO",
    "rmarkdown",
    "rmongodb",
    "RODBC",
    "scales",
    "shiny",
    "sparklyr",
    "sqldf",
    "stringr",
    "tidyr",
    "timeDate",
    "webshot",
    "xtable",
    "YaleToolkit",
    "zoo"
  ]

  cw_agent_namespace                   = "/app/analytical_batch"
  cw_agent_log_group_name              = "/app/analytical_batch/get_scripts"
  cw_agent_metrics_collection_interval = 60
  aws_defaut_region                    = "eu-west-2"
  cw_agent_step_log_group_name         = "/app/analytical_batch/step_logs"

}

#S3 Required in no proxy list as it is a gateway endpoint
