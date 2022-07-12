# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  #########################
  ## Networking Details
  #########################
  networking_details = {
    vcn = {
      vcn_name       = oci_core_vcn.coa_demo_vcn.display_name,
      vcn_id         = oci_core_vcn.coa_demo_vcn.id,
      vcn_cidr_block = oci_core_vcn.coa_demo_vcn.cidr_block
      vcn_dns_label  = oci_core_vcn.coa_demo_vcn.dns_label
    },
    route_tables = {
      ig_route_table = {
        route_table_name  = oci_core_route_table.coa_ig_route_table.display_name,
        route_table_id    = oci_core_route_table.coa_ig_route_table.id,
        route_table_rules = oci_core_route_table.coa_ig_route_table.route_rules
      },
      nat_gw_route_table = {
        route_table_name  = oci_core_route_table.coa_nat_gw_route_table.display_name,
        route_table_id    = oci_core_route_table.coa_nat_gw_route_table.id,
        route_table_rules = oci_core_route_table.coa_nat_gw_route_table.route_rules
      }
    }
    private-subnet = {
      subnet_name    = oci_core_subnet.coa_private_subnet.display_name,
      subnet_cidr    = oci_core_subnet.coa_private_subnet.cidr_block,
      route_table    = oci_core_route_table.coa_nat_gw_route_table.display_name,
      dns_label      = "${oci_core_vcn.coa_demo_vcn.dns_label}.${oci_core_subnet.coa_private_subnet.dns_label}",
      security_lists = [oci_core_security_list.coa_vcn_security_list.display_name, oci_core_security_list.coa_private_subnet_security_list.display_name]
    },
    private-db-subnet = {
      subnet_name    = oci_core_subnet.coa_db_private_subnet.display_name,
      subnet_cidr    = oci_core_subnet.coa_db_private_subnet.cidr_block,
      route_table    = oci_core_route_table.coa_nat_gw_route_table.display_name,
      dns_label      = "${oci_core_vcn.coa_demo_vcn.dns_label}.${oci_core_subnet.coa_db_private_subnet.dns_label}",
      security_lists = [oci_core_security_list.coa_vcn_security_list.display_name, oci_core_security_list.coa_private_db_subnet_security_list.display_name]
    },
    public-subnet = {
      subnet_name    = oci_core_subnet.coa_public_subnet.display_name,
      subnet_cidr    = oci_core_subnet.coa_public_subnet.cidr_block,
      route_table    = oci_core_route_table.coa_ig_route_table.display_name,
      dns_label      = "${oci_core_vcn.coa_demo_vcn.dns_label}.${oci_core_subnet.coa_public_subnet.dns_label}",
      security_lists = [oci_core_security_list.coa_vcn_security_list.display_name, oci_core_security_list.coa_public_subnet_security_list.display_name]
    },
    internet-gw = {
      ig_name = oci_core_internet_gateway.coa_internet_gateway.display_name
    },
    security_lists = {
      coa_vcn_level_sec_list = {
        name = oci_core_security_list.coa_vcn_security_list.display_name
      },
      coa_public_subnet_sec_list = {
        name = oci_core_security_list.coa_public_subnet_security_list.display_name
      },
      coa_private_subnet_sec_list = {
        name = oci_core_security_list.coa_private_subnet_security_list.display_name
      }
    }
  }
}

#########################
## COA DEMO Details
#########################

output "COA_Demo_Details" {
  value = {
    automation_run_by  = data.oci_identity_user.coa_demo_executer.name,
    networking_details = local.networking_details,
    #compute_details    = local.compute_details,
    #lbaas_details      = local.lbaas_details
  }
}
