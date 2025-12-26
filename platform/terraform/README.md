# Azure Infrastructure with Terraform

## Purpose

This Terraform configuration creates a single Ubuntu VM on Azure that will be configured by Ansible playbooks to become your complete DevOps platform. The machine will be set up with:

- **Docker** - Container runtime
- **Kubernetes** - Container orchestration (single-node cluster)
- **Jenkins** - CI/CD pipeline automation
- **Helm** - Kubernetes package manager
- **ArgoCD** - GitOps continuous deployment
- **UFW Firewall** - Network security with configured ports

Think of Terraform as building the infrastructure, and Ansible as configuring what runs on it.

## What Terraform Creates

- **Ubuntu 22.04 LTS VM**: Ready for Ansible to configure
- **Virtual Network**: 10.0.0.0/16 with subnet 10.0.1.0/24
- **Security Rules**: SSH, Jenkins (8080), Nginx (8888), ArgoCD (30080), GitHub webhooks
- **Monitoring**: CPU alerts when usage > 80%
- **Public IP**: Static IP to access your machine

## Quick Start

### Step 1: Configure Azure Credentials

Edit `secrets.tfvars` with your Azure account details:

```
subscription_id = "your-subscription-id"
tenant_id       = "your-tenant-id"
client_id       = "your-client-id"
client_secret   = "your-client-secret"
location        = "UK South"
infra_cidr      = "10.0.1.0/24"
```

### Step 2: Initialize Terraform

```bash
cd platform/terraform
terraform init
```

This downloads Terraform providers and sets up the working directory.

### Step 3: Review Changes

```bash
terraform plan -var-file=secrets.tfvars
```

This shows exactly what will be created before you apply it.

### Step 4: Create Infrastructure

```bash
terraform apply -var-file=secrets.tfvars -auto-approve
```

This creates all Azure resources. Takes about 5-10 minutes.

### Step 5: Configure with Ansible (Next Step)

Once complete, go to `platform/ansible` folder and follow the Ansible README to configure the VM with Docker, Kubernetes, Jenkins, and ArgoCD.

## Useful Terraform Commands

```bash
# See what will be created
terraform plan -var-file=secrets.tfvars

# Apply changes
terraform apply -var-file=secrets.tfvars -auto-approve

# Destroy everything (careful!)
terraform destroy -var-file=secrets.tfvars -auto-approve

# Show current resources
terraform show

# Get output values (like VM IP address)
terraform output
```

## After Deployment

When Terraform finishes, you'll have:

1. **VM Public IP** - Get it with: `terraform output`
2. **Admin Username** - `sameed` (change in variables.tf if needed)
3. **SSH Access** - Use your private key to connect via SSH

Then proceed to the Ansible folder to automatically install and configure all DevOps tools on this machine.

## Troubleshooting

**"Resource already exists"?** 
Resources from a previous run still exist in Azure. Either delete them manually or import them into Terraform state.

**Need to change location?**
Edit `location` in `secrets.tfvars` or `variables.tf` (default: UK South)

**Want to see what will change?**
Run `terraform plan -var-file=secrets.tfvars` before applying anything.

  # module.monitoring.azurerm_application_insights.app_insights will be created
  + resource "azurerm_application_insights" "app_insights" {
      + app_id                              = (known after apply)
      + application_type                    = "infra"
      + connection_string                   = (sensitive value)
      + daily_data_cap_in_gb                = 100
      + disable_ip_masking                  = false
      + force_customer_storage_for_profiler = false
      + id                                  = (known after apply)
      + instrumentation_key                 = (sensitive value)
      + internet_ingestion_enabled          = true
      + internet_query_enabled              = true
      + local_authentication_disabled       = false
      + location                            = "uksouth"
      + name                                = "infra-insights"
      + resource_group_name                 = "Infrastructure-rg"
      + retention_in_days                   = 90
      + sampling_percentage                 = 100
      + workspace_id                        = (known after apply)
    }

  # module.monitoring.azurerm_log_analytics_workspace.log will be created
  + resource "azurerm_log_analytics_workspace" "log" {
      + allow_resource_only_permissions = true
      + daily_quota_gb                  = -1
      + id                              = (known after apply)
      + internet_ingestion_enabled      = true
      + internet_query_enabled          = true
      + local_authentication_disabled   = (known after apply)
      + local_authentication_enabled    = (known after apply)
      + location                        = "uksouth"
      + name                            = "infra-log-analytics"
      + primary_shared_key              = (sensitive value)
      + resource_group_name             = "Infrastructure-rg"
      + retention_in_days               = 30
      + secondary_shared_key            = (sensitive value)
      + sku                             = "PerGB2018"
      + workspace_id                    = (known after apply)
    }

  # module.monitoring.azurerm_monitor_action_group.alerts will be created
  + resource "azurerm_monitor_action_group" "alerts" {
      + enabled             = true
      + id                  = (known after apply)
      + location            = "global"
      + name                = "infra-action-group"
      + resource_group_name = "Infrastructure-rg"
      + short_name          = "alertgrp"

      + email_receiver {
          + email_address = "sameed@gmail.com"
          + name          = "DevOpsTeam"
        }
    }

  # module.monitoring.azurerm_monitor_diagnostic_setting.vm_diagnostic will be created
  + resource "azurerm_monitor_diagnostic_setting" "vm_diagnostic" {
      + id                             = (known after apply)
      + log_analytics_destination_type = (known after apply)
      + log_analytics_workspace_id     = (known after apply)
      + name                           = "infra-vm-diagnostic"
      + target_resource_id             = (known after apply)

      + enabled_metric {
          + category = "AllMetrics"
        }
    }

  # module.monitoring.azurerm_monitor_metric_alert.high_cpu will be created
  + resource "azurerm_monitor_metric_alert" "high_cpu" {
      + auto_mitigate            = true
      + description              = "Alert when CPU usage > 80%"
      + enabled                  = true
      + frequency                = "PT1M"
      + id                       = (known after apply)
      + name                     = "infra-cpu-alert"
      + resource_group_name      = "Infrastructure-rg"
      + scopes                   = (known after apply)
      + severity                 = 2
      + target_resource_location = (known after apply)
      + target_resource_type     = (known after apply)
      + window_size              = "PT5M"

      + action {
          + action_group_id = (known after apply)
        }

      + criteria {
          + aggregation            = "Average"
          + metric_name            = "Percentage CPU"
          + metric_namespace       = "Microsoft.Compute/virtualMachines"
          + operator               = "GreaterThan"
          + skip_metric_validation = false
          + threshold              = 80
        }
    }

  # module.network.azurerm_subnet.infra_subnet will be created
  + resource "azurerm_subnet" "infra_subnet" {
      + address_prefixes                              = [
          + "10.0.1.0/24",
        ]
      + default_outbound_access_enabled               = true
      + id                                            = (known after apply)
      + name                                          = "Infra-Subnet"
      + private_endpoint_network_policies             = "Disabled"
      + private_link_service_network_policies_enabled = true
      + resource_group_name                           = "Infrastructure-rg"
      + virtual_network_name                          = "devops-vnet-prod"
    }

  # module.network.azurerm_virtual_network.vnet will be created
  + resource "azurerm_virtual_network" "vnet" {
      + address_space                  = [
          + "10.0.0.0/16",
        ]
      + dns_servers                    = (known after apply)
      + guid                           = (known after apply)
      + id                             = (known after apply)
      + location                       = "uksouth"
      + name                           = "devops-vnet-prod"
      + private_endpoint_vnet_policies = "Disabled"
      + resource_group_name            = "Infrastructure-rg"
      + subnet                         = (known after apply)
    }

  # module.resource_group.azurerm_resource_group.resource_group will be created
  + resource "azurerm_resource_group" "resource_group" {
      + id       = (known after apply)
      + location = "uksouth"
      + name     = "Infrastructure-rg"
    }

  # module.vm.azurerm_linux_virtual_machine.vm will be created
  + resource "azurerm_linux_virtual_machine" "vm" {
      + admin_password                                         = (sensitive value)
      + admin_username                                         = "sameed"
      + allow_extension_operations                             = (known after apply)
      + bypass_platform_safety_checks_on_user_schedule_enabled = false
      + computer_name                                          = (known after apply)
      + disable_password_authentication                        = false
      + disk_controller_type                                   = (known after apply)
      + extensions_time_budget                                 = "PT1H30M"
      + id                                                     = (known after apply)
      + location                                               = "uksouth"
      + max_bid_price                                          = -1
      + name                                                   = "Infrastructure-vm"
      + network_interface_ids                                  = (known after apply)
      + os_managed_disk_id                                     = (known after apply)
      + patch_assessment_mode                                  = (known after apply)
      + patch_mode                                             = (known after apply)
      + platform_fault_domain                                  = -1
      + priority                                               = "Regular"
      + private_ip_address                                     = (known after apply)
      + private_ip_addresses                                   = (known after apply)
      + provision_vm_agent                                     = (known after apply)
      + public_ip_address                                      = (known after apply)
      + public_ip_addresses                                    = (known after apply)
      + resource_group_name                                    = "Infrastructure-rg"
      + size                                                   = "Standard_B1s"
      + virtual_machine_id                                     = (known after apply)
      + vm_agent_platform_updates_enabled                      = (known after apply)

      + os_disk {
          + caching                   = "ReadWrite"
          + disk_size_gb              = (known after apply)
          + id                        = (known after apply)
          + name                      = (known after apply)
          + storage_account_type      = "Standard_LRS"
          + write_accelerator_enabled = false
        }

      + source_image_reference {
          + offer     = "0001-com-ubuntu-server-jammy"
          + publisher = "Canonical"
          + sku       = "22_04-lts-gen2"
          + version   = "latest"
        }
    }

  # module.vm.azurerm_network_interface.vm_nic will be created
  + resource "azurerm_network_interface" "vm_nic" {
      + accelerated_networking_enabled = false
      + applied_dns_servers            = (known after apply)
      + id                             = (known after apply)
      + internal_domain_name_suffix    = (known after apply)
      + ip_forwarding_enabled          = false
      + location                       = "uksouth"
      + mac_address                    = (known after apply)
      + name                           = "web-vm-nic"
      + private_ip_address             = (known after apply)
      + private_ip_addresses           = (known after apply)
      + resource_group_name            = "Infrastructure-rg"
      + virtual_machine_id             = (known after apply)

      + ip_configuration {
          + gateway_load_balancer_frontend_ip_configuration_id = (known after apply)
          + name                                               = "web-ipconfig"
          + primary                                            = (known after apply)
          + private_ip_address                                 = (known after apply)
          + private_ip_address_allocation                      = "Dynamic"
          + private_ip_address_version                         = "IPv4"
          + public_ip_address_id                               = (known after apply)
          + subnet_id                                          = (known after apply)
        }
    }

  # module.vm.azurerm_network_interface_security_group_association.nsg_assoc will be created
  + resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
      + id                        = (known after apply)
      + network_interface_id      = (known after apply)
      + network_security_group_id = (known after apply)
    }

  # module.vm.azurerm_network_security_group.nsg will be created
  + resource "azurerm_network_security_group" "nsg" {
      + id                  = (known after apply)
      + location            = "uksouth"
      + name                = "Infrastructure-vm-nsg"
      + resource_group_name = "Infrastructure-rg"
      + security_rule       = [
          + {
              + access                                     = "Allow"
              + description                                = "ArgoCD access"
              + destination_address_prefix                 = "*"
              + destination_address_prefixes               = []
              + destination_application_security_group_ids = []
              + destination_port_range                     = "30080"
              + destination_port_ranges                    = []
              + direction                                  = "Inbound"
              + name                                       = "Argo"
              + priority                                   = 330
              + protocol                                   = "Tcp"
              + source_address_prefix                      = "89.0.49.165/32"
              + source_address_prefixes                    = []
              + source_application_security_group_ids      = []
              + source_port_range                          = "*"
              + source_port_ranges                         = []
            },
          + {
              + access                                     = "Allow"
              + description                                = "GitHub webhooks"
              + destination_address_prefix                 = "*"
              + destination_address_prefixes               = []
              + destination_application_security_group_ids = []
              + destination_port_range                     = "8080"
              + destination_port_ranges                    = []
              + direction                                  = "Inbound"
              + name                                       = "Github"
              + priority                                   = 340
              + protocol                                   = "Tcp"
              + source_address_prefix                      = ""
              + source_address_prefixes                    = [
                  + "140.82.112.0/20",
                  + "143.55.64.0/20",
                  + "185.199.108.0/22",
                  + "192.30.252.0/22",
                ]
              + source_application_security_group_ids      = []
              + source_port_range                          = "*"
              + source_port_ranges                         = []
            },
          + {
              + access                                     = "Allow"
              + description                                = "Jenkins access"
              + destination_address_prefix                 = "*"
              + destination_address_prefixes               = []
              + destination_application_security_group_ids = []
              + destination_port_range                     = "8080"
              + destination_port_ranges                    = []
              + direction                                  = "Inbound"
              + name                                       = "Jenkins"
              + priority                                   = 310
              + protocol                                   = "Tcp"
              + source_address_prefix                      = "89.0.49.165/32"
              + source_address_prefixes                    = []
              + source_application_security_group_ids      = []
              + source_port_range                          = "*"
              + source_port_ranges                         = []
            },
          + {
              + access                                     = "Allow"
              + description                                = "Nginx access"
              + destination_address_prefix                 = "*"
              + destination_address_prefixes               = []
              + destination_application_security_group_ids = []
              + destination_port_range                     = "8888"
              + destination_port_ranges                    = []
              + direction                                  = "Inbound"
              + name                                       = "Nginx"
              + priority                                   = 320
              + protocol                                   = "Tcp"
              + source_address_prefix                      = "89.0.49.165/32"
              + source_address_prefixes                    = []
              + source_application_security_group_ids      = []
              + source_port_range                          = "*"
              + source_port_ranges                         = []
            },
          + {
              + access                                     = "Allow"
              + description                                = "SSH access"
              + destination_address_prefix                 = "*"
              + destination_address_prefixes               = []
              + destination_application_security_group_ids = []
              + destination_port_range                     = "22"
              + destination_port_ranges                    = []
              + direction                                  = "Inbound"
              + name                                       = "SSH"
              + priority                                   = 300
              + protocol                                   = "Tcp"
              + source_address_prefix                      = "89.0.49.165/32"
              + source_address_prefixes                    = []
              + source_application_security_group_ids      = []
              + source_port_range                          = "*"
              + source_port_ranges                         = []
            },
        ]
    }

  # module.vm.azurerm_public_ip.vm_pip will be created
  + resource "azurerm_public_ip" "vm_pip" {
      + allocation_method       = "Static"
      + ddos_protection_mode    = "VirtualNetworkInherited"
      + fqdn                    = (known after apply)
      + id                      = (known after apply)
      + idle_timeout_in_minutes = 4
      + ip_address              = (known after apply)
      + ip_version              = "IPv4"
      + location                = "uksouth"
      + name                    = "web-vm-pip"
      + resource_group_name     = "Infrastructure-rg"
      + sku                     = "Standard"
      + sku_tier                = "Regional"
    }

Plan: 13 to add, 0 to change, 0 to destroy.