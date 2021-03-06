/*
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

/*
Schema population script for $(AMBARIDBNAME)

Use this script in sqlcmd mode, setting the environment variables like this:
set AMBARIDBNAME=ambari

sqlcmd -S localhost\SQLEXPRESS -i C:\app\ambari-server-1.3.0-SNAPSHOT\resources\Ambari-DDL-SQLServer-CREATE.sql
*/

use [$(AMBARIDBNAME)]
GO

------create the database------

------create tables and grant privileges to db user---------
CREATE TABLE clusters (cluster_id BIGINT NOT NULL, resource_id BIGINT NOT NULL, cluster_info VARCHAR(255) NOT NULL, cluster_name VARCHAR(100) NOT NULL UNIQUE, provisioning_state VARCHAR(255) NOT NULL DEFAULT 'INIT', security_type VARCHAR(32) NOT NULL DEFAULT 'NONE', desired_cluster_state VARCHAR(255) NOT NULL, desired_stack_version VARCHAR(255) NOT NULL, PRIMARY KEY CLUSTERED (cluster_id));
CREATE TABLE clusterconfig (config_id BIGINT NOT NULL, version_tag VARCHAR(255) NOT NULL, version BIGINT NOT NULL, type_name VARCHAR(255) NOT NULL, cluster_id BIGINT NOT NULL, config_data VARCHAR(MAX) NOT NULL, config_attributes VARCHAR(MAX), create_timestamp BIGINT NOT NULL, PRIMARY KEY CLUSTERED (config_id));
CREATE TABLE serviceconfig (service_config_id BIGINT NOT NULL, cluster_id BIGINT NOT NULL, service_name VARCHAR(255) NOT NULL, version BIGINT NOT NULL, create_timestamp BIGINT NOT NULL, user_name VARCHAR(255) NOT NULL DEFAULT '_db', group_id BIGINT, note VARCHAR(MAX), PRIMARY KEY CLUSTERED (service_config_id));
CREATE TABLE serviceconfighosts (service_config_id BIGINT NOT NULL, hostname VARCHAR(255) NOT NULL, PRIMARY KEY CLUSTERED (service_config_id, hostname));
CREATE TABLE serviceconfigmapping (service_config_id BIGINT NOT NULL, config_id BIGINT NOT NULL, PRIMARY KEY CLUSTERED (service_config_id, config_id));
CREATE TABLE clusterconfigmapping (cluster_id BIGINT NOT NULL, type_name VARCHAR(255) NOT NULL, version_tag VARCHAR(255) NOT NULL, create_timestamp BIGINT NOT NULL, selected INTEGER NOT NULL DEFAULT 0, user_name VARCHAR(255) NOT NULL DEFAULT '_db', PRIMARY KEY CLUSTERED (cluster_id, type_name, create_timestamp));
CREATE TABLE clusterservices (service_name VARCHAR(255) NOT NULL, cluster_id BIGINT NOT NULL, service_enabled INTEGER NOT NULL, PRIMARY KEY CLUSTERED (service_name, cluster_id));
CREATE TABLE clusterstate (cluster_id BIGINT NOT NULL, current_cluster_state VARCHAR(255) NOT NULL, current_stack_version VARCHAR(255) NOT NULL, PRIMARY KEY CLUSTERED (cluster_id));
CREATE TABLE cluster_version (id BIGINT NOT NULL, cluster_id BIGINT NOT NULL, repo_version_id BIGINT NOT NULL, state VARCHAR(255) NOT NULL, start_time BIGINT NOT NULL, end_time BIGINT, user_name VARCHAR(255), PRIMARY KEY (id));

CREATE TABLE hostcomponentdesiredstate (
  cluster_id BIGINT NOT NULL,
  component_name VARCHAR(255) NOT NULL,
  desired_stack_version VARCHAR(255) NOT NULL,
  desired_state VARCHAR(255) NOT NULL,
  host_id BIGINT NOT NULL,
  service_name VARCHAR(255) NOT NULL,
  admin_state VARCHAR(32),
  maintenance_state VARCHAR(32) NOT NULL,
  security_state VARCHAR(32) NOT NULL DEFAULT 'UNSECURED',
  restart_required BIT NOT NULL DEFAULT 0,
  PRIMARY KEY CLUSTERED (cluster_id, component_name, host_id, service_name));

CREATE TABLE hostcomponentstate (
  cluster_id BIGINT NOT NULL,
  component_name VARCHAR(255) NOT NULL,
  version VARCHAR(32) NOT NULL DEFAULT 'UNKNOWN',
  current_stack_version VARCHAR(255) NOT NULL,
  current_state VARCHAR(255) NOT NULL,
  host_id BIGINT NOT NULL,
  service_name VARCHAR(255) NOT NULL,
  upgrade_state VARCHAR(32) NOT NULL DEFAULT 'NONE',
  security_state VARCHAR(32) NOT NULL DEFAULT 'UNSECURED',
  PRIMARY KEY CLUSTERED (cluster_id, component_name, host_id, service_name));

CREATE TABLE hosts (
  host_id BIGINT NOT NULL,
  host_name VARCHAR(255) NOT NULL,
  cpu_count INTEGER NOT NULL,
  ph_cpu_count INTEGER,
  cpu_info VARCHAR(255) NOT NULL,
  discovery_status VARCHAR(2000) NOT NULL,
  host_attributes VARCHAR(MAX) NOT NULL,
  ipv4 VARCHAR(255),
  ipv6 VARCHAR(255),
  public_host_name VARCHAR(255),
  last_registration_time BIGINT NOT NULL,
  os_arch VARCHAR(255) NOT NULL,
  os_info VARCHAR(1000) NOT NULL,
  os_type VARCHAR(255) NOT NULL,
  rack_info VARCHAR(255) NOT NULL,
  total_mem BIGINT NOT NULL,
  PRIMARY KEY CLUSTERED (host_id));

CREATE TABLE hoststate (
  agent_version VARCHAR(255) NOT NULL,
  available_mem BIGINT NOT NULL,
  current_state VARCHAR(255) NOT NULL,
  health_status VARCHAR(255),
  host_id BIGINT NOT NULL,
  time_in_state BIGINT NOT NULL,
  maintenance_state VARCHAR(512),
  PRIMARY KEY CLUSTERED (host_id));

CREATE TABLE servicecomponentdesiredstate (component_name VARCHAR(255) NOT NULL, cluster_id BIGINT NOT NULL, desired_stack_version VARCHAR(255) NOT NULL, desired_state VARCHAR(255) NOT NULL, service_name VARCHAR(255) NOT NULL, PRIMARY KEY CLUSTERED (component_name, cluster_id, service_name));
CREATE TABLE servicedesiredstate (cluster_id BIGINT NOT NULL, desired_host_role_mapping INTEGER NOT NULL, desired_stack_version VARCHAR(255) NOT NULL, desired_state VARCHAR(255) NOT NULL, service_name VARCHAR(255) NOT NULL, maintenance_state VARCHAR(32) NOT NULL, security_state VARCHAR(32) NOT NULL DEFAULT 'UNSECURED', PRIMARY KEY CLUSTERED (cluster_id, service_name));
CREATE TABLE users (user_id INTEGER, principal_id BIGINT NOT NULL, ldap_user INTEGER NOT NULL DEFAULT 0, user_name VARCHAR(255) NOT NULL, create_time DATETIME DEFAULT GETDATE(), user_password VARCHAR(255), active INTEGER NOT NULL DEFAULT 1, PRIMARY KEY CLUSTERED (user_id), UNIQUE (ldap_user, user_name));
CREATE TABLE groups (group_id INTEGER, principal_id BIGINT NOT NULL, group_name VARCHAR(255) NOT NULL, ldap_group INTEGER NOT NULL DEFAULT 0, PRIMARY KEY (group_id));
CREATE TABLE members (member_id INTEGER, group_id INTEGER NOT NULL, user_id INTEGER NOT NULL, PRIMARY KEY (member_id));
CREATE TABLE execution_command (command VARBINARY(8000), task_id BIGINT NOT NULL, PRIMARY KEY CLUSTERED (task_id));
CREATE TABLE host_role_command (task_id BIGINT NOT NULL, attempt_count SMALLINT NOT NULL, retry_allowed SMALLINT DEFAULT 0 NOT NULL, event VARCHAR(MAX) NOT NULL, exitcode INTEGER NOT NULL, host_name VARCHAR(255) NOT NULL, last_attempt_time BIGINT NOT NULL, request_id BIGINT NOT NULL, role VARCHAR(255), stage_id BIGINT NOT NULL, start_time BIGINT NOT NULL, end_time BIGINT, status VARCHAR(255), std_error VARBINARY(max), std_out VARBINARY(max), output_log VARCHAR(255) NULL, error_log VARCHAR(255) NULL, structured_out VARBINARY(max), role_command VARCHAR(255), command_detail VARCHAR(255), custom_command_name VARCHAR(255), PRIMARY KEY CLUSTERED (task_id));
CREATE TABLE role_success_criteria (role VARCHAR(255) NOT NULL, request_id BIGINT NOT NULL, stage_id BIGINT NOT NULL, success_factor FLOAT NOT NULL, PRIMARY KEY CLUSTERED (role, request_id, stage_id));
CREATE TABLE stage (stage_id BIGINT NOT NULL, request_id BIGINT NOT NULL, cluster_id BIGINT NOT NULL, skippable SMALLINT DEFAULT 0 NOT NULL, log_info VARCHAR(255) NOT NULL, request_context VARCHAR(255), cluster_host_info VARBINARY(8000) NOT NULL, command_params VARBINARY(8000), host_params VARBINARY(8000), PRIMARY KEY CLUSTERED (stage_id, request_id));
CREATE TABLE request (request_id BIGINT NOT NULL, cluster_id BIGINT, command_name VARCHAR(255), create_time BIGINT NOT NULL, end_time BIGINT NOT NULL, exclusive_execution BIT NOT NULL DEFAULT 0, inputs VARBINARY(8000), request_context VARCHAR(255), request_type VARCHAR(255), request_schedule_id BIGINT, start_time BIGINT NOT NULL, status VARCHAR(255), PRIMARY KEY CLUSTERED (request_id));
CREATE TABLE requestresourcefilter (filter_id BIGINT NOT NULL, request_id BIGINT NOT NULL, service_name VARCHAR(255), component_name VARCHAR(255), hosts VARBINARY(8000), PRIMARY KEY CLUSTERED (filter_id));
CREATE TABLE requestoperationlevel (operation_level_id BIGINT NOT NULL, request_id BIGINT NOT NULL, level_name VARCHAR(255), cluster_name VARCHAR(255), service_name VARCHAR(255), host_component_name VARCHAR(255), host_name VARCHAR(255), PRIMARY KEY CLUSTERED (operation_level_id));

CREATE TABLE ClusterHostMapping (
  cluster_id BIGINT NOT NULL,
  host_id BIGINT NOT NULL,
  PRIMARY KEY CLUSTERED (cluster_id, host_id));

CREATE TABLE key_value_store ([key] VARCHAR(255), [value] VARCHAR(MAX), PRIMARY KEY CLUSTERED ([key]));
CREATE TABLE hostconfigmapping (cluster_id BIGINT NOT NULL, host_name VARCHAR(255) NOT NULL, type_name VARCHAR(255) NOT NULL, version_tag VARCHAR(255) NOT NULL, service_name VARCHAR(255), create_timestamp BIGINT NOT NULL, selected INTEGER NOT NULL DEFAULT 0, user_name VARCHAR(255) NOT NULL DEFAULT '_db', PRIMARY KEY CLUSTERED (cluster_id, host_name, type_name, create_timestamp));
CREATE TABLE metainfo ([metainfo_key] VARCHAR(255), [metainfo_value] VARCHAR(255), PRIMARY KEY CLUSTERED ([metainfo_key]));
CREATE TABLE ambari_sequences (sequence_name VARCHAR(255) PRIMARY KEY, [sequence_value] BIGINT NOT NULL);
CREATE TABLE configgroup (group_id BIGINT, cluster_id BIGINT NOT NULL, group_name VARCHAR(255) NOT NULL, tag VARCHAR(1024) NOT NULL, description VARCHAR(1024), create_timestamp BIGINT NOT NULL, service_name VARCHAR(255), PRIMARY KEY(group_id));
CREATE TABLE confgroupclusterconfigmapping (config_group_id BIGINT NOT NULL, cluster_id BIGINT NOT NULL, config_type VARCHAR(255) NOT NULL, version_tag VARCHAR(255) NOT NULL, user_name VARCHAR(255) DEFAULT '_db', create_timestamp BIGINT NOT NULL, PRIMARY KEY(config_group_id, cluster_id, config_type));
CREATE TABLE configgrouphostmapping (config_group_id BIGINT NOT NULL, host_name VARCHAR(255) NOT NULL, PRIMARY KEY(config_group_id, host_name));
CREATE TABLE requestschedule (schedule_id bigint, cluster_id bigint NOT NULL, description varchar(255), status varchar(255), batch_separation_seconds smallint, batch_toleration_limit smallint, create_user varchar(255), create_timestamp bigint, update_user varchar(255), update_timestamp bigint, minutes varchar(10), hours varchar(10), days_of_month varchar(10), month varchar(10), day_of_week varchar(10), yearToSchedule varchar(10), startTime varchar(50), endTime varchar(50), last_execution_status varchar(255), PRIMARY KEY(schedule_id));
CREATE TABLE requestschedulebatchrequest (schedule_id bigint, batch_id bigint, request_id bigint, request_type varchar(255), request_uri varchar(1024), request_body VARBINARY(8000), request_status varchar(255), return_code smallint, return_message text, PRIMARY KEY(schedule_id, batch_id));
CREATE TABLE blueprint (blueprint_name VARCHAR(255) NOT NULL, stack_name VARCHAR(255) NOT NULL, stack_version VARCHAR(255) NOT NULL, PRIMARY KEY(blueprint_name));
CREATE TABLE hostgroup (blueprint_name VARCHAR(255) NOT NULL, name VARCHAR(255) NOT NULL, cardinality VARCHAR(255) NOT NULL, PRIMARY KEY(blueprint_name, name));
CREATE TABLE hostgroup_component (blueprint_name VARCHAR(255) NOT NULL, hostgroup_name VARCHAR(255) NOT NULL, name VARCHAR(255) NOT NULL, PRIMARY KEY(blueprint_name, hostgroup_name, name));
CREATE TABLE blueprint_configuration (blueprint_name varchar(255) NOT NULL, type_name varchar(255) NOT NULL, config_data text NOT NULL, config_attributes VARCHAR(8000), PRIMARY KEY(blueprint_name, type_name));
CREATE TABLE hostgroup_configuration (blueprint_name VARCHAR(255) NOT NULL, hostgroup_name VARCHAR(255) NOT NULL, type_name VARCHAR(255) NOT NULL, config_data TEXT NOT NULL, config_attributes TEXT, PRIMARY KEY(blueprint_name, hostgroup_name, type_name));
CREATE TABLE viewmain (view_name VARCHAR(255) NOT NULL, label VARCHAR(255), description VARCHAR(2048), version VARCHAR(255), resource_type_id INTEGER NOT NULL, icon VARCHAR(255), icon64 VARCHAR(255), archive VARCHAR(255), mask VARCHAR(255), system_view BIT NOT NULL DEFAULT 0, PRIMARY KEY(view_name));
CREATE TABLE viewinstancedata (view_instance_id BIGINT, view_name VARCHAR(255) NOT NULL, view_instance_name VARCHAR(255) NOT NULL, name VARCHAR(255) NOT NULL, user_name VARCHAR(255) NOT NULL, value VARCHAR(2000) NOT NULL, PRIMARY KEY(view_instance_id, name, user_name));
CREATE TABLE viewinstance (view_instance_id BIGINT, resource_id BIGINT NOT NULL, view_name VARCHAR(255) NOT NULL, name VARCHAR(255) NOT NULL, label VARCHAR(255), description VARCHAR(2048), visible CHAR(1), icon VARCHAR(255), icon64 VARCHAR(255), xml_driven CHAR(1), cluster_handle VARCHAR(255), PRIMARY KEY(view_instance_id));
CREATE TABLE viewinstanceproperty (view_name VARCHAR(255) NOT NULL, view_instance_name VARCHAR(255) NOT NULL, name VARCHAR(255) NOT NULL, value VARCHAR(2000) NOT NULL, PRIMARY KEY(view_name, view_instance_name, name));
CREATE TABLE viewparameter (view_name VARCHAR(255) NOT NULL, name VARCHAR(255) NOT NULL, description VARCHAR(2048), label VARCHAR(255), placeholder VARCHAR(255), default_value VARCHAR(2000), cluster_config VARCHAR(255), required CHAR(1), masked CHAR(1), PRIMARY KEY(view_name, name));
CREATE TABLE viewresource (view_name VARCHAR(255) NOT NULL, name VARCHAR(255) NOT NULL, plural_name VARCHAR(255), id_property VARCHAR(255), subResource_names VARCHAR(255), provider VARCHAR(255), service VARCHAR(255), resource VARCHAR(255), PRIMARY KEY(view_name, name));
CREATE TABLE viewentity (id BIGINT NOT NULL, view_name VARCHAR(255) NOT NULL, view_instance_name VARCHAR(255) NOT NULL, class_name VARCHAR(255) NOT NULL, id_property VARCHAR(255), PRIMARY KEY(id));
CREATE TABLE adminresourcetype (resource_type_id INTEGER NOT NULL, resource_type_name VARCHAR(255) NOT NULL, PRIMARY KEY(resource_type_id));
CREATE TABLE adminresource (resource_id BIGINT NOT NULL, resource_type_id INTEGER NOT NULL, PRIMARY KEY(resource_id));
CREATE TABLE adminprincipaltype (principal_type_id INTEGER NOT NULL, principal_type_name VARCHAR(255) NOT NULL, PRIMARY KEY(principal_type_id));
CREATE TABLE adminprincipal (principal_id BIGINT NOT NULL, principal_type_id INTEGER NOT NULL, PRIMARY KEY(principal_id));
CREATE TABLE adminpermission (permission_id BIGINT NOT NULL, permission_name VARCHAR(255) NOT NULL, resource_type_id INTEGER NOT NULL, PRIMARY KEY(permission_id));
CREATE TABLE adminprivilege (privilege_id BIGINT, permission_id BIGINT NOT NULL, resource_id BIGINT NOT NULL, principal_id BIGINT NOT NULL, PRIMARY KEY(privilege_id));
CREATE TABLE host_version (id BIGINT NOT NULL, repo_version_id BIGINT NOT NULL, host_name VARCHAR(255) NOT NULL, state VARCHAR(32) NOT NULL, PRIMARY KEY (id));
CREATE TABLE repo_version (repo_version_id BIGINT NOT NULL, stack VARCHAR(255) NOT NULL, version VARCHAR(255) NOT NULL, display_name VARCHAR(128) NOT NULL, upgrade_package VARCHAR(255) NOT NULL, repositories VARCHAR(MAX) NOT NULL, PRIMARY KEY(repo_version_id));
CREATE TABLE artifact (artifact_name VARCHAR(255) NOT NULL, artifact_data TEXT NOT NULL, foreign_keys VARCHAR(255) NOT NULL, PRIMARY KEY (artifact_name, foreign_keys));

-- altering tables by creating unique constraints----------
--------altering tables to add constraints----------
ALTER TABLE users ADD CONSTRAINT UNQ_users_0 UNIQUE (user_name, ldap_user);
ALTER TABLE groups ADD CONSTRAINT UNQ_groups_0 UNIQUE (group_name, ldap_group);
ALTER TABLE members ADD CONSTRAINT UNQ_members_0 UNIQUE (group_id, user_id);
ALTER TABLE clusterconfig ADD CONSTRAINT UQ_config_type_tag UNIQUE (cluster_id, type_name, version_tag);
ALTER TABLE clusterconfig ADD CONSTRAINT UQ_config_type_version UNIQUE (cluster_id, type_name, version);
ALTER TABLE hosts ADD CONSTRAINT UQ_hosts_host_name UNIQUE (host_name);
ALTER TABLE viewinstance ADD CONSTRAINT UQ_viewinstance_name UNIQUE (view_name, name);
ALTER TABLE viewinstance ADD CONSTRAINT UQ_viewinstance_name_id UNIQUE (view_instance_id, view_name, name);
ALTER TABLE serviceconfig ADD CONSTRAINT UQ_scv_service_version UNIQUE (cluster_id, service_name, version);
ALTER TABLE adminpermission ADD CONSTRAINT UQ_perm_name_resource_type_id UNIQUE (permission_name, resource_type_id);
ALTER TABLE repo_version ADD CONSTRAINT UQ_repo_version_display_name UNIQUE (display_name);
ALTER TABLE repo_version ADD CONSTRAINT UQ_repo_version_stack_version UNIQUE (stack, version);

-- altering tables by creating foreign keys----------
ALTER TABLE members ADD CONSTRAINT FK_members_group_id FOREIGN KEY (group_id) REFERENCES groups (group_id);
ALTER TABLE members ADD CONSTRAINT FK_members_user_id FOREIGN KEY (user_id) REFERENCES users (user_id);
ALTER TABLE clusterconfig ADD CONSTRAINT FK_clusterconfig_cluster_id FOREIGN KEY (cluster_id) REFERENCES clusters (cluster_id);
ALTER TABLE clusterservices ADD CONSTRAINT FK_clusterservices_cluster_id FOREIGN KEY (cluster_id) REFERENCES clusters (cluster_id);
ALTER TABLE clusterconfigmapping ADD CONSTRAINT clusterconfigmappingcluster_id FOREIGN KEY (cluster_id) REFERENCES clusters (cluster_id);
ALTER TABLE clusterstate ADD CONSTRAINT FK_clusterstate_cluster_id FOREIGN KEY (cluster_id) REFERENCES clusters (cluster_id);
ALTER TABLE cluster_version ADD CONSTRAINT FK_cluster_version_cluster_id FOREIGN KEY (cluster_id) REFERENCES clusters (cluster_id);
ALTER TABLE cluster_version ADD CONSTRAINT FK_cluster_version_repovers_id FOREIGN KEY (repo_version_id) REFERENCES repo_version (repo_version_id);
ALTER TABLE hostcomponentdesiredstate ADD CONSTRAINT hstcmponentdesiredstatehstid FOREIGN KEY (host_id) REFERENCES hosts (host_id);
ALTER TABLE hostcomponentdesiredstate ADD CONSTRAINT hstcmpnntdesiredstatecmpnntnme FOREIGN KEY (component_name, cluster_id, service_name) REFERENCES servicecomponentdesiredstate (component_name, cluster_id, service_name);
ALTER TABLE hostcomponentstate ADD CONSTRAINT hstcomponentstatecomponentname FOREIGN KEY (component_name, cluster_id, service_name) REFERENCES servicecomponentdesiredstate (component_name, cluster_id, service_name);
ALTER TABLE hostcomponentstate ADD CONSTRAINT FK_hostcomponentstate_host_id FOREIGN KEY (host_id) REFERENCES hosts (host_id);
ALTER TABLE hoststate ADD CONSTRAINT FK_hoststate_host_id FOREIGN KEY (host_id) REFERENCES hosts (host_id);
ALTER TABLE host_version ADD CONSTRAINT FK_host_version_host_name FOREIGN KEY (host_name) REFERENCES hosts (host_name);
--ALTER TABLE host_version ADD CONSTRAINT FK_host_version_host_id FOREIGN KEY (host_id) REFERENCES hosts (host_id);
ALTER TABLE host_version ADD CONSTRAINT FK_host_version_repovers_id FOREIGN KEY (repo_version_id) REFERENCES repo_version (repo_version_id);
ALTER TABLE servicecomponentdesiredstate ADD CONSTRAINT srvccmponentdesiredstatesrvcnm FOREIGN KEY (service_name, cluster_id) REFERENCES clusterservices (service_name, cluster_id);
ALTER TABLE servicedesiredstate ADD CONSTRAINT servicedesiredstateservicename FOREIGN KEY (service_name, cluster_id) REFERENCES clusterservices (service_name, cluster_id);
ALTER TABLE execution_command ADD CONSTRAINT FK_execution_command_task_id FOREIGN KEY (task_id) REFERENCES host_role_command (task_id);
ALTER TABLE host_role_command ADD CONSTRAINT FK_host_role_command_stage_id FOREIGN KEY (stage_id, request_id) REFERENCES stage (stage_id, request_id);
ALTER TABLE host_role_command ADD CONSTRAINT FK_host_role_command_host_name FOREIGN KEY (host_name) REFERENCES hosts (host_name);
--ALTER TABLE host_role_command ADD CONSTRAINT FK_host_role_command_host_id FOREIGN KEY (host_id) REFERENCES hosts (host_id);
ALTER TABLE role_success_criteria ADD CONSTRAINT role_success_criteria_stage_id FOREIGN KEY (stage_id, request_id) REFERENCES stage (stage_id, request_id);
ALTER TABLE stage ADD CONSTRAINT FK_stage_request_id FOREIGN KEY (request_id) REFERENCES request (request_id);
ALTER TABLE request ADD CONSTRAINT FK_request_schedule_id FOREIGN KEY (request_schedule_id) REFERENCES requestschedule (schedule_id);
ALTER TABLE ClusterHostMapping ADD CONSTRAINT FK_clusterhostmapping_cluster_id FOREIGN KEY (cluster_id) REFERENCES clusters (cluster_id);
ALTER TABLE ClusterHostMapping ADD CONSTRAINT FK_clusterhostmapping_host_id FOREIGN KEY (host_id) REFERENCES hosts (host_id);
ALTER TABLE hostconfigmapping ADD CONSTRAINT FK_hostconfmapping_cluster_id FOREIGN KEY (cluster_id) REFERENCES clusters (cluster_id);
ALTER TABLE hostconfigmapping ADD CONSTRAINT FK_hostconfmapping_host_name FOREIGN KEY (host_name) REFERENCES hosts (host_name);
--ALTER TABLE hostconfigmapping ADD CONSTRAINT FK_hostconfmapping_host_id FOREIGN KEY (host_id) REFERENCES hosts (host_id);
ALTER TABLE configgroup ADD CONSTRAINT FK_configgroup_cluster_id FOREIGN KEY (cluster_id) REFERENCES clusters (cluster_id);
ALTER TABLE confgroupclusterconfigmapping ADD CONSTRAINT FK_confg FOREIGN KEY (cluster_id, config_type, version_tag) REFERENCES clusterconfig (cluster_id, type_name, version_tag);
ALTER TABLE confgroupclusterconfigmapping ADD CONSTRAINT FK_cgccm_gid FOREIGN KEY (config_group_id) REFERENCES configgroup (group_id);
ALTER TABLE configgrouphostmapping ADD CONSTRAINT FK_cghm_cgid FOREIGN KEY (config_group_id) REFERENCES configgroup (group_id);
ALTER TABLE configgrouphostmapping ADD CONSTRAINT FK_cghm_hname FOREIGN KEY (host_name) REFERENCES hosts (host_name);
--ALTER TABLE configgrouphostmapping ADD CONSTRAINT FK_cghm_host_id FOREIGN KEY (host_id) REFERENCES hosts (host_id);
ALTER TABLE requestschedulebatchrequest ADD CONSTRAINT FK_rsbatchrequest_schedule_id FOREIGN KEY (schedule_id) REFERENCES requestschedule (schedule_id);
ALTER TABLE hostgroup ADD CONSTRAINT FK_hg_blueprint_name FOREIGN KEY (blueprint_name) REFERENCES blueprint(blueprint_name);
ALTER TABLE hostgroup_component ADD CONSTRAINT FK_hgc_blueprint_name FOREIGN KEY (blueprint_name, hostgroup_name) REFERENCES hostgroup (blueprint_name, name);
ALTER TABLE blueprint_configuration ADD CONSTRAINT FK_cfg_blueprint_name FOREIGN KEY (blueprint_name) REFERENCES blueprint(blueprint_name);
ALTER TABLE hostgroup_configuration ADD CONSTRAINT FK_hg_cfg_bp_hg_name FOREIGN KEY (blueprint_name, hostgroup_name) REFERENCES hostgroup (blueprint_name, name);
ALTER TABLE requestresourcefilter ADD CONSTRAINT FK_reqresfilter_req_id FOREIGN KEY (request_id) REFERENCES request (request_id);
ALTER TABLE requestoperationlevel ADD CONSTRAINT FK_req_op_level_req_id FOREIGN KEY (request_id) REFERENCES request (request_id);
ALTER TABLE viewparameter ADD CONSTRAINT FK_viewparam_view_name FOREIGN KEY (view_name) REFERENCES viewmain(view_name);
ALTER TABLE viewresource ADD CONSTRAINT FK_viewres_view_name FOREIGN KEY (view_name) REFERENCES viewmain(view_name);
ALTER TABLE viewinstance ADD CONSTRAINT FK_viewinst_view_name FOREIGN KEY (view_name) REFERENCES viewmain(view_name);
ALTER TABLE viewinstanceproperty ADD CONSTRAINT FK_viewinstprop_view_name FOREIGN KEY (view_name, view_instance_name) REFERENCES viewinstance(view_name, name);
ALTER TABLE viewinstancedata ADD CONSTRAINT FK_viewinstdata_view_name FOREIGN KEY (view_instance_id, view_name, view_instance_name) REFERENCES viewinstance(view_instance_id, view_name, name);
ALTER TABLE viewentity ADD CONSTRAINT FK_viewentity_view_name FOREIGN KEY (view_name, view_instance_name) REFERENCES viewinstance(view_name, name);
ALTER TABLE adminresource ADD CONSTRAINT FK_resource_resource_type_id FOREIGN KEY (resource_type_id) REFERENCES adminresourcetype(resource_type_id);
ALTER TABLE adminprincipal ADD CONSTRAINT FK_principal_principal_type_id FOREIGN KEY (principal_type_id) REFERENCES adminprincipaltype(principal_type_id);
ALTER TABLE adminpermission ADD CONSTRAINT FK_permission_resource_type_id FOREIGN KEY (resource_type_id) REFERENCES adminresourcetype(resource_type_id);
ALTER TABLE adminprivilege ADD CONSTRAINT FK_privilege_permission_id FOREIGN KEY (permission_id) REFERENCES adminpermission(permission_id);
ALTER TABLE adminprivilege ADD CONSTRAINT FK_privilege_resource_id FOREIGN KEY (resource_id) REFERENCES adminresource(resource_id);
ALTER TABLE viewmain ADD CONSTRAINT FK_view_resource_type_id FOREIGN KEY (resource_type_id) REFERENCES adminresourcetype(resource_type_id);
ALTER TABLE viewinstance ADD CONSTRAINT FK_viewinstance_resource_id FOREIGN KEY (resource_id) REFERENCES adminresource(resource_id);
ALTER TABLE adminprivilege ADD CONSTRAINT FK_privilege_principal_id FOREIGN KEY (principal_id) REFERENCES adminprincipal(principal_id);
ALTER TABLE users ADD CONSTRAINT FK_users_principal_id FOREIGN KEY (principal_id) REFERENCES adminprincipal(principal_id);
ALTER TABLE groups ADD CONSTRAINT FK_groups_principal_id FOREIGN KEY (principal_id) REFERENCES adminprincipal(principal_id);
ALTER TABLE serviceconfigmapping ADD CONSTRAINT FK_scvm_scv FOREIGN KEY (service_config_id) REFERENCES serviceconfig(service_config_id);
ALTER TABLE serviceconfigmapping ADD CONSTRAINT FK_scvm_config FOREIGN KEY (config_id) REFERENCES clusterconfig(config_id);
ALTER TABLE serviceconfighosts ADD CONSTRAINT  FK_scvhosts_scv FOREIGN KEY (service_config_id) REFERENCES serviceconfig(service_config_id);
ALTER TABLE clusters ADD CONSTRAINT FK_clusters_resource_id FOREIGN KEY (resource_id) REFERENCES adminresource(resource_id);

-- Kerberos
CREATE TABLE kerberos_principal (
  principal_name VARCHAR(255) NOT NULL,
  is_service SMALLINT NOT NULL DEFAULT 1,
  cached_keytab_path VARCHAR(255),
  PRIMARY KEY(principal_name)
);

CREATE TABLE kerberos_principal_host (
  principal_name VARCHAR(255) NOT NULL,
  host_name VARCHAR(255) NOT NULL,
  --host_id BIGINT NOT NULL,
  PRIMARY KEY(principal_name, host_name)
  --PRIMARY KEY(principal_name, host_id)
);

ALTER TABLE kerberos_principal_host
ADD CONSTRAINT FK_krb_pr_host_hostname
FOREIGN KEY (host_name) REFERENCES hosts (host_name) ON DELETE CASCADE;
--ALTER TABLE kerberos_principal_host ADD CONSTRAINT FK_krb_pr_host_id FOREIGN KEY (host_id) REFERENCES hosts (host_id) ON DELETE CASCADE;

ALTER TABLE kerberos_principal_host
ADD CONSTRAINT FK_krb_pr_host_principalname
FOREIGN KEY (principal_name) REFERENCES kerberos_principal (principal_name) ON DELETE CASCADE;
-- Kerberos (end)

-- Alerting Framework
CREATE TABLE alert_definition (
  definition_id BIGINT NOT NULL,
  cluster_id BIGINT NOT NULL,
  definition_name VARCHAR(255) NOT NULL,
  service_name VARCHAR(255) NOT NULL,
  component_name VARCHAR(255),
  scope VARCHAR(255) DEFAULT 'ANY' NOT NULL,
  label VARCHAR(255),
  description TEXT,
  enabled SMALLINT DEFAULT 1 NOT NULL,
  schedule_interval INTEGER NOT NULL,
  source_type VARCHAR(255) NOT NULL,
  alert_source TEXT NOT NULL,
  hash VARCHAR(64) NOT NULL,
  ignore_host SMALLINT DEFAULT 0 NOT NULL,
  PRIMARY KEY (definition_id),
  FOREIGN KEY (cluster_id) REFERENCES clusters(cluster_id),
  CONSTRAINT uni_alert_def_name UNIQUE(cluster_id,definition_name)
);

CREATE TABLE alert_history (
  alert_id BIGINT NOT NULL,
  cluster_id BIGINT NOT NULL,
  alert_definition_id BIGINT NOT NULL,
  service_name VARCHAR(255) NOT NULL,
  component_name VARCHAR(255),
  host_name VARCHAR(255),
  alert_instance VARCHAR(255),
  alert_timestamp BIGINT NOT NULL,
  alert_label VARCHAR(1024),
  alert_state VARCHAR(255) NOT NULL,
  alert_text TEXT,
  PRIMARY KEY (alert_id),
  FOREIGN KEY (alert_definition_id) REFERENCES alert_definition(definition_id),
  FOREIGN KEY (cluster_id) REFERENCES clusters(cluster_id)
);

CREATE TABLE alert_current (
  alert_id BIGINT NOT NULL,
  definition_id BIGINT NOT NULL,
  history_id BIGINT NOT NULL UNIQUE,
  maintenance_state VARCHAR(255) NOT NULL,
  original_timestamp BIGINT NOT NULL,
  latest_timestamp BIGINT NOT NULL,
  latest_text TEXT,
  PRIMARY KEY (alert_id),
  FOREIGN KEY (definition_id) REFERENCES alert_definition(definition_id),
  FOREIGN KEY (history_id) REFERENCES alert_history(alert_id)
);

CREATE TABLE alert_group (
  group_id BIGINT NOT NULL,
  cluster_id BIGINT NOT NULL,
  group_name VARCHAR(255) NOT NULL,
  is_default SMALLINT NOT NULL DEFAULT 0,
  service_name VARCHAR(255),
  PRIMARY KEY (group_id),
  CONSTRAINT uni_alert_group_name UNIQUE(cluster_id,group_name)
);

CREATE TABLE alert_target (
  target_id BIGINT NOT NULL,
  target_name VARCHAR(255) NOT NULL UNIQUE,
  notification_type VARCHAR(64) NOT NULL,
  properties TEXT,
  description VARCHAR(1024),
  is_global SMALLINT NOT NULL DEFAULT 0,
  PRIMARY KEY (target_id)
);

CREATE TABLE alert_target_states (
  target_id BIGINT NOT NULL,
  alert_state VARCHAR(255) NOT NULL,
  FOREIGN KEY (target_id) REFERENCES alert_target(target_id)
);

CREATE TABLE alert_group_target (
  group_id BIGINT NOT NULL,
  target_id BIGINT NOT NULL,
  PRIMARY KEY (group_id, target_id),
  FOREIGN KEY (group_id) REFERENCES alert_group(group_id),
  FOREIGN KEY (target_id) REFERENCES alert_target(target_id)
);

CREATE TABLE alert_grouping (
  definition_id BIGINT NOT NULL,
  group_id BIGINT NOT NULL,
  PRIMARY KEY (group_id, definition_id),
  FOREIGN KEY (definition_id) REFERENCES alert_definition(definition_id),
  FOREIGN KEY (group_id) REFERENCES alert_group(group_id)
);

CREATE TABLE alert_notice (
  notification_id BIGINT NOT NULL,
  target_id BIGINT NOT NULL,
  history_id BIGINT NOT NULL,
  notify_state VARCHAR(255) NOT NULL,
  uuid VARCHAR(64) NOT NULL UNIQUE,
  PRIMARY KEY (notification_id),
  FOREIGN KEY (target_id) REFERENCES alert_target(target_id),
  FOREIGN KEY (history_id) REFERENCES alert_history(alert_id)
);

CREATE INDEX idx_alert_history_def_id on alert_history(alert_definition_id);
CREATE INDEX idx_alert_history_service on alert_history(service_name);
CREATE INDEX idx_alert_history_host on alert_history(host_name);
CREATE INDEX idx_alert_history_time on alert_history(alert_timestamp);
CREATE INDEX idx_alert_history_state on alert_history(alert_state);
CREATE INDEX idx_alert_group_name on alert_group(group_name);
CREATE INDEX idx_alert_notice_state on alert_notice(notify_state);

-- upgrade tables
CREATE TABLE upgrade (
  upgrade_id BIGINT NOT NULL,
  cluster_id BIGINT NOT NULL,
  request_id BIGINT NOT NULL,
  from_version VARCHAR(255) DEFAULT '' NOT NULL,
  to_version VARCHAR(255) DEFAULT '' NOT NULL,
  direction VARCHAR(255) DEFAULT 'UPGRADE' NOT NULL,
  PRIMARY KEY (upgrade_id),
  FOREIGN KEY (cluster_id) REFERENCES clusters(cluster_id),
  FOREIGN KEY (request_id) REFERENCES request(request_id)
);

CREATE TABLE upgrade_group (
  upgrade_group_id BIGINT NOT NULL,
  upgrade_id BIGINT NOT NULL,
  group_name VARCHAR(255) DEFAULT '' NOT NULL,
  group_title VARCHAR(1024) DEFAULT '' NOT NULL,
  PRIMARY KEY (upgrade_group_id),
  FOREIGN KEY (upgrade_id) REFERENCES upgrade(upgrade_id)
);

CREATE TABLE upgrade_item (
  upgrade_item_id BIGINT NOT NULL,
  upgrade_group_id BIGINT NOT NULL,
  stage_id BIGINT NOT NULL,
  state VARCHAR(255) DEFAULT 'NONE' NOT NULL,
  hosts TEXT,
  tasks TEXT,
  item_text VARCHAR(1024),
  PRIMARY KEY (upgrade_item_id),
  FOREIGN KEY (upgrade_group_id) REFERENCES upgrade_group(upgrade_group_id)
);

CREATE TABLE stack(
  stack_id BIGINT NOT NULL,
  stack_name VARCHAR(255) NOT NULL,
  stack_version VARCHAR(255) NOT NULL,
  PRIMARY KEY (stack_id),
  CONSTRAINT unq_stack UNIQUE(stack_name,stack_version)
);

---------inserting some data-----------
BEGIN TRANSACTION
  INSERT INTO ambari_sequences (sequence_name, [sequence_value])
  SELECT 'cluster_id_seq', 1
  UNION ALL
  SELECT 'host_id_seq', 0
  UNION ALL
  SELECT 'host_role_command_id_seq', 1
  UNION ALL
  SELECT 'user_id_seq', 2
  UNION ALL
  SELECT 'group_id_seq', 1
  UNION ALL
  SELECT 'member_id_seq', 1
  UNION ALL
  SELECT 'configgroup_id_seq', 1
  UNION ALL
  SELECT 'requestschedule_id_seq', 1
  UNION ALL
  SELECT 'resourcefilter_id_seq', 1
  UNION ALL
  SELECT 'viewentity_id_seq', 0
  UNION ALL
  SELECT 'operation_level_id_seq', 1
  UNION ALL
  SELECT 'cluster_version_id_seq', 0
  UNION ALL
  SELECT 'view_instance_id_seq', 1
  UNION ALL
  SELECT 'resource_type_id_seq', 4
  UNION ALL
  SELECT 'resource_id_seq', 2
  UNION ALL
  SELECT 'principal_type_id_seq', 3
  UNION ALL
  SELECT 'principal_id_seq', 2
  UNION ALL
  SELECT 'permission_id_seq', 5
  UNION ALL
  SELECT 'privilege_id_seq', 1
  UNION ALL
  SELECT 'config_id_seq', 1
  UNION ALL
  SELECT 'service_config_id_seq', 1
  UNION ALL
  SELECT 'alert_definition_id_seq', 0
  UNION ALL
  SELECT 'alert_group_id_seq', 0
  UNION ALL
  SELECT 'alert_target_id_seq', 0
  UNION ALL
  SELECT 'alert_history_id_seq', 0
  UNION ALL
  SELECT 'alert_notice_id_seq', 0
  UNION ALL
  SELECT 'alert_current_id_seq', 0
  UNION ALL
  SELECT 'upgrade_id_seq', 0
  UNION ALL
  SELECT 'upgrade_item_id_seq', 0
  UNION ALL
  SELECT 'upgrade_group_id_seq', 0
  UNION ALL
  SELECT 'host_version_id_seq', 0
  UNION ALL
  SELECT 'repo_version_id_seq', 0
  UNION ALL
  SELECT 'stack_id_seq', 0;

  insert into adminresourcetype (resource_type_id, resource_type_name)
    select 1, 'AMBARI'
    union all
    select 2, 'CLUSTER'
    union all
    select 3, 'VIEW';

  insert into adminresource (resource_id, resource_type_id)
    select 1, 1;

  insert into adminprincipaltype (principal_type_id, principal_type_name)
    select 1, 'USER'
    union all
    select 2, 'GROUP';

  insert into adminprincipal (principal_id, principal_type_id)
    select 1, 1;

  insert into users(user_id, principal_id, user_name, user_password)
    select 1, 1, 'admin','538916f8943ec225d97a9a86a2c6ec0818c1cd400e09e03b660fdaaec4af29ddbb6f2b1033b81b00';

  insert into adminpermission(permission_id, permission_name, resource_type_id)
    select 1, 'AMBARI.ADMIN', 1
    union all
    select 2, 'CLUSTER.READ', 2
    union all
    select 3, 'CLUSTER.OPERATE', 2
    union all
    select 4, 'VIEW.USE', 3;

  insert into adminprivilege (privilege_id, permission_id, resource_id, principal_id)
    select 1, 1, 1, 1;

  insert into metainfo(metainfo_key, metainfo_value)
    select 'version','${ambariVersion}';
COMMIT TRANSACTION

-- Quartz tables

CREATE TABLE qrtz_job_details
  (
    SCHED_NAME VARCHAR(120) NOT NULL,
    JOB_NAME  VARCHAR(200) NOT NULL,
    JOB_GROUP VARCHAR(200) NOT NULL,
    DESCRIPTION VARCHAR(250) NULL,
    JOB_CLASS_NAME   VARCHAR(250) NOT NULL,
    IS_DURABLE BIT NOT NULL,
    IS_NONCONCURRENT BIT NOT NULL,
    IS_UPDATE_DATA BIT NOT NULL,
    REQUESTS_RECOVERY BIT NOT NULL,
    JOB_DATA VARBINARY(MAX) NULL,
    PRIMARY KEY CLUSTERED (SCHED_NAME,JOB_NAME,JOB_GROUP)
);

CREATE TABLE qrtz_triggers
  (
    SCHED_NAME VARCHAR(120) NOT NULL,
    TRIGGER_NAME VARCHAR(200) NOT NULL,
    TRIGGER_GROUP VARCHAR(200) NOT NULL,
    JOB_NAME  VARCHAR(200) NOT NULL,
    JOB_GROUP VARCHAR(200) NOT NULL,
    DESCRIPTION VARCHAR(250) NULL,
    NEXT_FIRE_TIME BIGINT NULL,
    PREV_FIRE_TIME BIGINT NULL,
    PRIORITY INTEGER NULL,
    TRIGGER_STATE VARCHAR(16) NOT NULL,
    TRIGGER_TYPE VARCHAR(8) NOT NULL,
    START_TIME BIGINT NOT NULL,
    END_TIME BIGINT NULL,
    CALENDAR_NAME VARCHAR(200) NULL,
    MISFIRE_INSTR SMALLINT NULL,
    JOB_DATA VARBINARY(MAX) NULL,
    PRIMARY KEY CLUSTERED (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP),
    FOREIGN KEY (SCHED_NAME,JOB_NAME,JOB_GROUP)
	REFERENCES QRTZ_JOB_DETAILS(SCHED_NAME,JOB_NAME,JOB_GROUP)
);

CREATE TABLE qrtz_simple_triggers
  (
    SCHED_NAME VARCHAR(120) NOT NULL,
    TRIGGER_NAME VARCHAR(200) NOT NULL,
    TRIGGER_GROUP VARCHAR(200) NOT NULL,
    REPEAT_COUNT BIGINT NOT NULL,
    REPEAT_INTERVAL BIGINT NOT NULL,
    TIMES_TRIGGERED BIGINT NOT NULL,
    PRIMARY KEY CLUSTERED (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP),
    FOREIGN KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
	REFERENCES QRTZ_TRIGGERS(SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
);

CREATE TABLE qrtz_cron_triggers
  (
    SCHED_NAME VARCHAR(120) NOT NULL,
    TRIGGER_NAME VARCHAR(200) NOT NULL,
    TRIGGER_GROUP VARCHAR(200) NOT NULL,
    CRON_EXPRESSION VARCHAR(120) NOT NULL,
    TIME_ZONE_ID VARCHAR(80),
    PRIMARY KEY CLUSTERED (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP),
    FOREIGN KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
	REFERENCES QRTZ_TRIGGERS(SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
);

CREATE TABLE qrtz_simprop_triggers
  (
    SCHED_NAME VARCHAR(120) NOT NULL,
    TRIGGER_NAME VARCHAR(200) NOT NULL,
    TRIGGER_GROUP VARCHAR(200) NOT NULL,
    STR_PROP_1 VARCHAR(512) NULL,
    STR_PROP_2 VARCHAR(512) NULL,
    STR_PROP_3 VARCHAR(512) NULL,
    INT_PROP_1 INT NULL,
    INT_PROP_2 INT NULL,
    LONG_PROP_1 BIGINT NULL,
    LONG_PROP_2 BIGINT NULL,
    DEC_PROP_1 NUMERIC(13,4) NULL,
    DEC_PROP_2 NUMERIC(13,4) NULL,
    BOOL_PROP_1 BIT NULL,
    BOOL_PROP_2 BIT NULL,
    PRIMARY KEY CLUSTERED (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP),
    FOREIGN KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
    REFERENCES QRTZ_TRIGGERS(SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
);

CREATE TABLE qrtz_blob_triggers
  (
    SCHED_NAME VARCHAR(120) NOT NULL,
    TRIGGER_NAME VARCHAR(200) NOT NULL,
    TRIGGER_GROUP VARCHAR(200) NOT NULL,
    BLOB_DATA VARBINARY(MAX) NULL,
    PRIMARY KEY CLUSTERED (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP),
    FOREIGN KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
        REFERENCES QRTZ_TRIGGERS(SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
);

CREATE TABLE qrtz_calendars
  (
    SCHED_NAME VARCHAR(120) NOT NULL,
    CALENDAR_NAME  VARCHAR(200) NOT NULL,
    CALENDAR VARBINARY(MAX) NOT NULL,
    PRIMARY KEY CLUSTERED (SCHED_NAME,CALENDAR_NAME)
);


CREATE TABLE qrtz_paused_trigger_grps
  (
    SCHED_NAME VARCHAR(120) NOT NULL,
    TRIGGER_GROUP  VARCHAR(200) NOT NULL,
    PRIMARY KEY CLUSTERED (SCHED_NAME,TRIGGER_GROUP)
);

CREATE TABLE qrtz_fired_triggers
  (
    SCHED_NAME VARCHAR(120) NOT NULL,
    ENTRY_ID VARCHAR(95) NOT NULL,
    TRIGGER_NAME VARCHAR(200) NOT NULL,
    TRIGGER_GROUP VARCHAR(200) NOT NULL,
    INSTANCE_NAME VARCHAR(200) NOT NULL,
    FIRED_TIME BIGINT NOT NULL,
    SCHED_TIME BIGINT NOT NULL,
    PRIORITY INTEGER NOT NULL,
    STATE VARCHAR(16) NOT NULL,
    JOB_NAME VARCHAR(200) NULL,
    JOB_GROUP VARCHAR(200) NULL,
    IS_NONCONCURRENT BIT NULL,
    REQUESTS_RECOVERY BIT NULL,
    PRIMARY KEY CLUSTERED (SCHED_NAME,ENTRY_ID)
);

CREATE TABLE qrtz_scheduler_state
  (
    SCHED_NAME VARCHAR(120) NOT NULL,
    INSTANCE_NAME VARCHAR(200) NOT NULL,
    LAST_CHECKIN_TIME BIGINT NOT NULL,
    CHECKIN_INTERVAL BIGINT NOT NULL,
    PRIMARY KEY CLUSTERED (SCHED_NAME,INSTANCE_NAME)
);

CREATE TABLE qrtz_locks
  (
    SCHED_NAME VARCHAR(120) NOT NULL,
    LOCK_NAME  VARCHAR(40) NOT NULL,
    PRIMARY KEY CLUSTERED (SCHED_NAME,LOCK_NAME)
);

create index idx_qrtz_j_req_recovery on qrtz_job_details(SCHED_NAME,REQUESTS_RECOVERY);
create index idx_qrtz_j_grp on qrtz_job_details(SCHED_NAME,JOB_GROUP);

create index idx_qrtz_t_j on qrtz_triggers(SCHED_NAME,JOB_NAME,JOB_GROUP);
create index idx_qrtz_t_jg on qrtz_triggers(SCHED_NAME,JOB_GROUP);
create index idx_qrtz_t_c on qrtz_triggers(SCHED_NAME,CALENDAR_NAME);
create index idx_qrtz_t_g on qrtz_triggers(SCHED_NAME,TRIGGER_GROUP);
create index idx_qrtz_t_state on qrtz_triggers(SCHED_NAME,TRIGGER_STATE);
create index idx_qrtz_t_n_state on qrtz_triggers(SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP,TRIGGER_STATE);
create index idx_qrtz_t_n_g_state on qrtz_triggers(SCHED_NAME,TRIGGER_GROUP,TRIGGER_STATE);
create index idx_qrtz_t_next_fire_time on qrtz_triggers(SCHED_NAME,NEXT_FIRE_TIME);
create index idx_qrtz_t_nft_st on qrtz_triggers(SCHED_NAME,TRIGGER_STATE,NEXT_FIRE_TIME);
create index idx_qrtz_t_nft_misfire on qrtz_triggers(SCHED_NAME,MISFIRE_INSTR,NEXT_FIRE_TIME);
create index idx_qrtz_t_nft_st_misfire on qrtz_triggers(SCHED_NAME,MISFIRE_INSTR,NEXT_FIRE_TIME,TRIGGER_STATE);
create index idx_qrtz_t_nft_st_misfire_grp on qrtz_triggers(SCHED_NAME,MISFIRE_INSTR,NEXT_FIRE_TIME,TRIGGER_GROUP,TRIGGER_STATE);

create index idx_qrtz_ft_trig_inst_name on qrtz_fired_triggers(SCHED_NAME,INSTANCE_NAME);
create index idx_qrtz_ft_inst_job_req_rcvry on qrtz_fired_triggers(SCHED_NAME,INSTANCE_NAME,REQUESTS_RECOVERY);
create index idx_qrtz_ft_j_g on qrtz_fired_triggers(SCHED_NAME,JOB_NAME,JOB_GROUP);
create index idx_qrtz_ft_jg on qrtz_fired_triggers(SCHED_NAME,JOB_GROUP);
create index idx_qrtz_ft_t_g on qrtz_fired_triggers(SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP);
create index idx_qrtz_ft_tg on qrtz_fired_triggers(SCHED_NAME,TRIGGER_GROUP);

-- ambari log4j DDL

CREATE TABLE workflow (
  workflowId       varchar(255) PRIMARY KEY CLUSTERED,
  workflowName     varchar(255),
  parentWorkflowId varchar(255),
  workflowContext  TEXT, userName varchar(255),
  startTime        BIGINT, lastUpdateTime BIGINT,
  numJobsTotal     INTEGER, numJobsCompleted INTEGER,
  inputBytes       BIGINT, outputBytes BIGINT,
  duration         BIGINT,
  FOREIGN KEY (parentWorkflowId) REFERENCES workflow (workflowId)
);

CREATE TABLE job (
  jobId        varchar(255) NOT NULL,
  workflowId   varchar(255) NOT NULL,
  jobName      varchar(255), workflowEntityName varchar(255),
  userName     varchar(255), queue varchar(255), acls varchar(2000), confPath varchar(260),
  submitTime   BIGINT, launchTime BIGINT, finishTime BIGINT,
  maps         INTEGER, reduces INTEGER, status varchar(255), priority varchar(255),
  finishedMaps INTEGER, finishedReduces INTEGER,
  failedMaps   INTEGER, failedReduces INTEGER,
  mapsRuntime  BIGINT, reducesRuntime BIGINT,
  mapCounters  TEXT, reduceCounters TEXT, jobCounters TEXT,
  inputBytes   BIGINT, outputBytes BIGINT,
  PRIMARY KEY CLUSTERED (jobId),
  FOREIGN KEY (workflowId) REFERENCES workflow (workflowId)
);

CREATE TABLE task (
  taskId        varchar(255) NOT NULL,
  jobId         varchar(255) NOT NULL,
  taskType      varchar(255), splits varchar(2000),
  startTime     BIGINT, finishTime BIGINT, status TEXT, error TEXT, counters TEXT,
  failedAttempt TEXT,
  PRIMARY KEY CLUSTERED (taskId),
  FOREIGN KEY (jobId) REFERENCES job (jobId)
);

CREATE TABLE taskAttempt (
  taskAttemptId varchar(255) NOT NULL,
  taskId        varchar(255) NOT NULL,
  jobId         varchar(255) NOT NULL,
  taskType      varchar(255), taskTracker varchar(255),
  startTime     BIGINT, finishTime BIGINT,
  mapFinishTime BIGINT, shuffleFinishTime BIGINT, sortFinishTime BIGINT,
  locality      TEXT, avataar TEXT,
  status        TEXT, error TEXT, counters TEXT,
  inputBytes    BIGINT, outputBytes BIGINT,
  PRIMARY KEY CLUSTERED (taskAttemptId),
  FOREIGN KEY (jobId) REFERENCES job (jobId),
  FOREIGN KEY (taskId) REFERENCES task (taskId)
);

CREATE TABLE hdfsEvent (
  timestamp   BIGINT,
  userName    varchar(255),
  clientIP    varchar(255),
  operation   varchar(255),
  srcPath     varchar(260),
  dstPath     varchar(260),
  permissions TEXT
);

CREATE TABLE mapreduceEvent (
  timestamp   BIGINT,
  userName    varchar(255),
  clientIP    varchar(255),
  operation   varchar(255),
  target      varchar(255),
  result      TEXT,
  description TEXT,
  permissions TEXT
);

CREATE TABLE clusterEvent (
  timestamp BIGINT,
  service   varchar(255), status TEXT,
  error     TEXT, data TEXT,
  host      TEXT, rack TEXT
);

GO

IF OBJECT_ID ('trigger_workflow_delete','TR') IS NOT NULL
    DROP TRIGGER trigger_workflow_delete;
GO

CREATE TRIGGER trigger_workflow_delete
ON workflow
INSTEAD OF DELETE
AS
BEGIN
    declare @cteTmp table
	(
	    rowid int identity,
		workflowId varchar(255)
	);

    declare @cteTmpRev table
	(
	    rowid int identity,
		workflowId varchar(255)
	);

	--the trigger does not get called recursively, so we need to store the child node ids in a temp table
    with cte as
	(
        select wr.workflowId workflowId
        from workflow wr inner join deleted d ON wr.workflowId = d.workflowId

        union all

        select w.workflowId
        from cte
        inner join workflow w on cte.workflowId = w.parentWorkflowId
    )
	insert into @cteTmp
	select workflowId from cte;

	--order by is invalid in subqueries and common table expression queries, do whatever we can
	-- watch out for scalability issues due to data duplication
	insert into @cteTmpRev
	select workflowId from @cteTmp
	order by rowid desc;

    --delete from the referred tables
    delete from job
    from job j inner join @cteTmpRev r on j.workflowId = r.workflowId;

    --finally delete from the master table
    delete from workflow
    from workflow w inner join @cteTmpRev r on w.workflowId = r.workflowId
END

GO

IF OBJECT_ID ('trigger_job_delete','TR') IS NOT NULL
    DROP TRIGGER trigger_job_delete;
GO

CREATE TRIGGER trigger_job_delete
ON job
INSTEAD OF DELETE
AS
BEGIN
    --delete from referred tables
    delete from task
    from task t inner join deleted d on t.jobId = d.jobId

    delete from job
    from job j inner join deleted d on j.jobId = d.jobId
END

GO

IF OBJECT_ID ('trigger_task_delete','TR') IS NOT NULL
    DROP TRIGGER trigger_task_delete;
GO

CREATE TRIGGER trigger_task_delete
ON task
INSTEAD OF DELETE
AS
BEGIN
    --delete from referred tables
    delete from taskAttempt
    from taskAttempt ta inner join task t on ta.taskId = t.taskId
        inner join deleted d on t.jobId = d.jobId

    delete from task
    from task t inner join deleted d on t.taskId = d.taskId
END

GO
