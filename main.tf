# Tenant - https://registry.terraform.io/providers/CiscoDevNet/aci/latest/docs/resources/tenant
resource "aci_tenant" "terraform_tenant" {
    name        = "App_VitaIT_TF"
    description = "This tenant is created by Vita using terraform"
}

# VRF - https://registry.terraform.io/providers/CiscoDevNet/aci/latest/docs/resources/vrf
resource "aci_vrf" "vrf_principal" {
  tenant_dn              = aci_tenant.terraform_tenant.id
  name                   = "Vita_demo_vrf"
  # Daqui pra baixo, opcional
  description            = "from terraform"
  annotation             = "tag_vrf"
  bd_enforced_enable     = "no"
  ip_data_plane_learning = "enabled"
  knw_mcast_act          = "permit"
  name_alias             = "alias_vrf"
  pc_enf_dir             = "egress"
  pc_enf_pref            = "unenforced"
}

# Bridge Domain - https://registry.terraform.io/providers/CiscoDevNet/aci/latest/docs/resources/bridge_domain
resource "aci_bridge_domain" "bd_principal" {
    tenant_dn                   = aci_tenant.terraform_tenant.id
    description                 = "from terraform"
    name                        = "Vita_demo_bd"
    # Daqui pra baixo, opcional
    optimize_wan_bandwidth      = "no"
    annotation                  = "tag_bd"
    arp_flood                   = "no"
    ep_clear                    = "no"
    ep_move_detect_mode         = "garp"
    host_based_routing          = "no"
    intersite_bum_traffic_allow = "yes"
    intersite_l2_stretch        = "yes"
    ip_learning                 = "yes"
    ipv6_mcast_allow            = "no"
    limit_ip_learn_to_subnets   = "yes"
    # ll_addr                     = "::"
    # mac                         = "00:22:BD:F8:19:FF"
    mcast_allow                 = "yes"
    multi_dst_pkt_act           = "bd-flood"
    name_alias                  = "alias_bd"
    bridge_domain_type          = "regular"
    unicast_route               = "no"
    unk_mac_ucast_act           = "flood"
    unk_mcast_act               = "flood"
    v6unk_mcast_act             = "flood"
    vmac                        = "not-applicable"
}

# Subnet - https://registry.terraform.io/providers/CiscoDevNet/aci/latest/docs/resources/subnet
resource "aci_subnet" "subnet_principal" {
    parent_dn        = aci_bridge_domain.bd_principal.id
    description      = "vita_subnet"
    ip               = "10.10.3.1/24"
    # Daqui pra baixo, opcional
    annotation       = "tag_subnet"
    ctrl             = ["querier", "nd"]
    name_alias       = "alias_subnet"
    preferred        = "no"
    scope            = ["private", "shared"]
    virtual          = "yes"
}

# Application Profile - https://registry.terraform.io/providers/CiscoDevNet/aci/latest/docs/resources/application_profile
resource "aci_application_profile" "internal_app" {
  tenant_dn  = aci_tenant.terraform_tenant.id
  name       = "Vita_demo_ap"
  # Daqui pra baixo, opcional
  annotation = "tag"
  description = "from terraform"
  name_alias = "test_ap"
  prio       = "level1"
}

# Application EPG - https://registry.terraform.io/providers/CiscoDevNet/aci/latest/docs/resources/application_epg
resource "aci_application_epg" "db_epg" {
    application_profile_dn  = aci_application_profile.internal_app.id
    name                              = "DB_epg"
    # Daqui pra baixo, opcional
    description                   = "from terraform"
    annotation                    = "tag_epg"
    exception_tag                 = "0"
    flood_on_encap            = "disabled"
    fwd_ctrl                      = "none"
    has_mcast_source             = "no"
    is_attr_based_epg         = "no"
    match_t                          = "AtleastOne"
    name_alias                  = "alias_epg"
    pc_enf_pref                  = "unenforced"
    pref_gr_memb                  = "exclude"
    prio                              = "unspecified"
    shutdown                      = "no"
    relation_fv_rs_bd      = aci_bridge_domain.bd_principal.id 
	  relation_fv_rs_cons    = [ aci_contract.vitaapp_contract.id ]
    depends_on = [
      aci_contract.vitaapp_contract
    ]
}

resource "aci_application_epg" "app_epg" {
    application_profile_dn  = aci_application_profile.internal_app.id
    name                              = "APP_epg"
    # Daqui pra baixo, opcional
    description                   = "from terraform"
    annotation                    = "tag_epg"
    exception_tag                 = "0"
    flood_on_encap            = "disabled"
    fwd_ctrl                      = "none"
    has_mcast_source             = "no"
    is_attr_based_epg         = "no"
    match_t                          = "AtleastOne"
    name_alias                  = "alias_epg"
    pc_enf_pref                  = "unenforced"
    pref_gr_memb                  = "exclude"
    prio                              = "unspecified"
    shutdown                      = "no"
    relation_fv_rs_bd      = aci_bridge_domain.bd_principal.id 
	  relation_fv_rs_cons    = [ aci_contract.vitaapp_contract.id ]
    depends_on = [
      aci_contract.vitaapp_contract
    ]
}


# L3OUT - https://registry.terraform.io/providers/CiscoDevNet/aci/latest/docs/resources/l3_outside
resource "aci_l3_outside" "l3ou_outside" {
        tenant_dn      = aci_tenant.terraform_tenant.id
        description    = "from terraform"
        name           = "demo_l3out"
        annotation     = "tag_l3out"
        enforce_rtctrl = ["export", "import"]
        name_alias     = "alias_out"
        target_dscp    = "unspecified"
    }

# ACI Contract - https://registry.terraform.io/providers/CiscoDevNet/aci/latest/docs/resources/contract
resource "aci_contract" "vitaapp_contract" {
        tenant_dn   =  aci_tenant.terraform_tenant.id
        description = "From Terraform"
        name        = "VitaIT_demo_contract"
        annotation  = "tag_contract"
        name_alias  = "alias_contract"
        prio        = "level1"
        scope       = "tenant"
        target_dscp = "unspecified"
    }

resource "aci_contract" "L3out_vitaapp_contract" {
        tenant_dn   =  aci_tenant.terraform_tenant.id
        description = "From Terraform"
        name        = "VitaITL3out_demo_contract"
        annotation  = "tag_contract"
        name_alias  = "alias_contract"
        prio        = "level1"
        scope       = "tenant"
        target_dscp = "unspecified"
    }

# ACI EPG to Contract - https://registry.terraform.io/providers/CiscoDevNet/aci/latest/docs/resources/epg_to_contract
resource "aci_epg_to_contract" "contract_app" {
  application_epg_dn = aci_application_epg.app_epg.id
  contract_dn        = aci_contract.vitaapp_contract.id
  contract_type      = "provider"
  annotation         = "terraform"
  match_t            = "AtleastOne"
  prio               = "unspecified"
}

resource "aci_epg_to_contract" "contract_db" {
  application_epg_dn = aci_application_epg.db_epg.id
  contract_dn        = aci_contract.vitaapp_contract.id
  contract_type      = "provider"
  annotation         = "terraform"
  match_t            = "AtleastOne"
  prio               = "unspecified"
}

resource "aci_epg_to_contract" "contract_l3out" {
  application_epg_dn = aci_application_epg.app_epg.id
  contract_dn        = aci_contract.L3out_vitaapp_contract.id
  contract_type      = "provider"
  annotation         = "terraform"
  match_t            = "AtleastOne"
  prio               = "unspecified"
}

# Filter -
resource "aci_filter" "allow_https" {
	tenant_dn = aci_tenant.terraform_tenant.id
	name      = "allow_https"
}
resource "aci_filter" "allow_icmp" {
	tenant_dn = aci_tenant.terraform_tenant.id
	name      = "allow_icmp"
}

resource "aci_filter_entry" "https" {
	name        = "https"
	filter_dn   = aci_filter.allow_https.id
	ether_t     = "ip"
	prot        = "tcp"
	d_from_port = "https"
	d_to_port   = "https"
	stateful    = "yes"
}

	resource "aci_filter_entry" "icmp" {
	name        = "icmp"
	filter_dn   = aci_filter.allow_icmp.id
	ether_t     = "ip"
	prot        = "icmp"
	stateful    = "yes"
}

resource "aci_contract_subject" "Web_subject1" {
	contract_dn                  = aci_contract.vitaapp_contract.id
	name                         = "Subject"
	relation_vz_rs_subj_filt_att = [aci_filter.allow_https.id, aci_filter.allow_icmp.id]
}
