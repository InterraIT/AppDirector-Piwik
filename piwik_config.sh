#!/bin/bash

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
set -e

# FUNTION TO CHECK ERROR
function check_error()
{
   if [ ! "$?" = "0" ]; then
      error_exit "$1";
   fi
}

# FUNCTION TO DISPLAY ERROR AND EXIT
function error_exit()
{
   echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
   exit 1
}

# PARAMETERS
PIWIK_USER_NAME="$piwik_username"
PIWIK_PASSWORD="$piwik_password"
PIWIK_EMAIL="$email"
PIWIK_HOST="$piwik_host"
PIWIK_DATABASE="$piwik_database"
TABLES_PREFIX="$tables_prefix"
MYSQL_USERNAME="$MySQL_username"
MYSQL_PASSWORD="$MySQL_password"
DOCUMENT_ROOT="$document_root"
PIWIK_IP="$piwik_selfip"
SITE_NAME="$site_name"
CURENT_TIME=`date +"%Y-%m-%d %T"`

# CREATE PIWIK DATABASE
mysqladmin -u $MYSQL_USERNAME -p$MYSQL_PASSWORD create $PIWIK_DATABASE
check_error "ERROR:WHILE CREATING PIWIK DATABASE"

# CREATE sql file To import the data into piwik databse
LastTimeChecked=`date +%s`
cat <<EOF>$DOCUMENT_ROOT/piwik/$PIWIK_DATABASE.sql
SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

CREATE TABLE IF NOT EXISTS \`${TABLES_PREFIX}access\` (
  \`login\` varchar(100) NOT NULL,
  \`idsite\` int(10) unsigned NOT NULL,
  \`access\` varchar(10) default NULL,
  PRIMARY KEY  (\`login\`,\`idsite\`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS \`${TABLES_PREFIX}goal\` (
  \`idsite\` int(11) NOT NULL,
  \`idgoal\` int(11) NOT NULL,
  \`name\` varchar(50) NOT NULL,
  \`match_attribute\` varchar(20) NOT NULL,
  \`pattern\` varchar(255) NOT NULL,
  \`pattern_type\` varchar(10) NOT NULL,
  \`case_sensitive\` tinyint(4) NOT NULL,
  \`allow_multiple\` tinyint(4) NOT NULL,
  \`revenue\` float NOT NULL,
  \`deleted\` tinyint(4) NOT NULL default '0',
  PRIMARY KEY  (\`idsite\`,\`idgoal\`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS \`${TABLES_PREFIX}logger_api_call\` (
  \`idlogger_api_call\` int(10) unsigned NOT NULL auto_increment,
  \`class_name\` varchar(255) default NULL,
  \`method_name\` varchar(255) default NULL,
  \`parameter_names_default_values\` text,
  \`parameter_values\` text,
  \`execution_time\` float default NULL,
  \`caller_ip\` varbinary(16) NOT NULL,
  \`timestamp\` timestamp NULL default NULL,
  \`returned_value\` text,
  PRIMARY KEY  (\`idlogger_api_call\`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS \`${TABLES_PREFIX}logger_error\` (
  \`idlogger_error\` int(10) unsigned NOT NULL auto_increment,
  \`timestamp\` timestamp NULL default NULL,
  \`message\` text,
  \`errno\` int(10) unsigned default NULL,
  \`errline\` int(10) unsigned default NULL,
  \`errfile\` varchar(255) default NULL,
  \`backtrace\` text,
  PRIMARY KEY  (\`idlogger_error\`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS \`${TABLES_PREFIX}logger_exception\` (
  \`idlogger_exception\` int(10) unsigned NOT NULL auto_increment,
  \`timestamp\` timestamp NULL default NULL,
  \`message\` text,
  \`errno\` int(10) unsigned default NULL,
  \`errline\` int(10) unsigned default NULL,
  \`errfile\` varchar(255) default NULL,
  \`backtrace\` text,
  PRIMARY KEY  (\`idlogger_exception\`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS \`${TABLES_PREFIX}logger_message\` (
  \`idlogger_message\` int(10) unsigned NOT NULL auto_increment,
  \`timestamp\` timestamp NULL default NULL,
  \`message\` text,
  PRIMARY KEY  (\`idlogger_message\`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS \`${TABLES_PREFIX}log_action\` (
  \`idaction\` int(10) unsigned NOT NULL auto_increment,
  \`name\` text,
  \`hash\` int(10) unsigned NOT NULL,
  \`type\` tinyint(3) unsigned default NULL,
  PRIMARY KEY  (\`idaction\`),
  KEY \`index_type_hash\` (\`type\`,\`hash\`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS \`${TABLES_PREFIX}log_conversion\` (
  \`idvisit\` int(10) unsigned NOT NULL,
  \`idsite\` int(10) unsigned NOT NULL,
  \`idvisitor\` binary(8) NOT NULL,
  \`server_time\` datetime NOT NULL,
  \`idaction_url\` int(11) default NULL,
  \`idlink_va\` int(11) default NULL,
  \`referer_visit_server_date\` date default NULL,
  \`referer_type\` int(10) unsigned default NULL,
  \`referer_name\` varchar(70) default NULL,
  \`referer_keyword\` varchar(255) default NULL,
  \`visitor_returning\` tinyint(1) NOT NULL,
  \`visitor_count_visits\` smallint(5) unsigned NOT NULL,
  \`visitor_days_since_first\` smallint(5) unsigned NOT NULL,
  \`visitor_days_since_order\` smallint(5) unsigned NOT NULL,
  \`location_country\` char(3) NOT NULL,
  \`location_continent\` char(3) NOT NULL,
  \`url\` text NOT NULL,
  \`idgoal\` int(10) NOT NULL,
  \`buster\` int(10) unsigned NOT NULL,
  \`idorder\` varchar(100) default NULL,
  \`items\` smallint(5) unsigned default NULL,
  \`revenue\` float default NULL,
  \`revenue_subtotal\` float default NULL,
  \`revenue_tax\` float default NULL,
  \`revenue_shipping\` float default NULL,
  \`revenue_discount\` float default NULL,
  \`custom_var_k1\` varchar(200) default NULL,
  \`custom_var_v1\` varchar(200) default NULL,
  \`custom_var_k2\` varchar(200) default NULL,
  \`custom_var_v2\` varchar(200) default NULL,
  \`custom_var_k3\` varchar(200) default NULL,
  \`custom_var_v3\` varchar(200) default NULL,
  \`custom_var_k4\` varchar(200) default NULL,
  \`custom_var_v4\` varchar(200) default NULL,
  \`custom_var_k5\` varchar(200) default NULL,
  \`custom_var_v5\` varchar(200) default NULL,
  PRIMARY KEY  (\`idvisit\`,\`idgoal\`,\`buster\`),
  UNIQUE KEY \`unique_idsite_idorder\` (\`idsite\`,\`idorder\`),
  KEY \`index_idsite_datetime\` (\`idsite\`,\`server_time\`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS \`${TABLES_PREFIX}log_conversion_item\` (
  \`idsite\` int(10) unsigned NOT NULL,
  \`idvisitor\` binary(8) NOT NULL,
  \`server_time\` datetime NOT NULL,
  \`idvisit\` int(10) unsigned NOT NULL,
  \`idorder\` varchar(100) NOT NULL,
  \`idaction_sku\` int(10) unsigned NOT NULL,
  \`idaction_name\` int(10) unsigned NOT NULL,
  \`idaction_category\` int(10) unsigned NOT NULL,
  \`idaction_category2\` int(10) unsigned NOT NULL,
  \`idaction_category3\` int(10) unsigned NOT NULL,
  \`idaction_category4\` int(10) unsigned NOT NULL,
  \`idaction_category5\` int(10) unsigned NOT NULL,
  \`price\` float NOT NULL,
  \`quantity\` int(10) unsigned NOT NULL,
  \`deleted\` tinyint(1) unsigned NOT NULL,
  PRIMARY KEY  (\`idvisit\`,\`idorder\`,\`idaction_sku\`),
  KEY \`index_idsite_servertime\` (\`idsite\`,\`server_time\`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS \`${TABLES_PREFIX}log_link_visit_action\` (
  \`idlink_va\` int(11) NOT NULL auto_increment,
  \`idsite\` int(10) unsigned NOT NULL,
  \`idvisitor\` binary(8) NOT NULL,
  \`server_time\` datetime NOT NULL,
  \`idvisit\` int(10) unsigned NOT NULL,
  \`idaction_url\` int(10) unsigned NOT NULL,
  \`idaction_url_ref\` int(10) unsigned NOT NULL,
  \`idaction_name\` int(10) unsigned default NULL,
  \`idaction_name_ref\` int(10) unsigned NOT NULL,
  \`time_spent_ref_action\` int(10) unsigned NOT NULL,
  \`custom_var_k1\` varchar(200) default NULL,
  \`custom_var_v1\` varchar(200) default NULL,
  \`custom_var_k2\` varchar(200) default NULL,
  \`custom_var_v2\` varchar(200) default NULL,
  \`custom_var_k3\` varchar(200) default NULL,
  \`custom_var_v3\` varchar(200) default NULL,
  \`custom_var_k4\` varchar(200) default NULL,
  \`custom_var_v4\` varchar(200) default NULL,
  \`custom_var_k5\` varchar(200) default NULL,
  \`custom_var_v5\` varchar(200) default NULL,
  PRIMARY KEY  (\`idlink_va\`),
  KEY \`index_idvisit\` (\`idvisit\`),
  KEY \`index_idsite_servertime\` (\`idsite\`,\`server_time\`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS \`${TABLES_PREFIX}log_profiling\` (
  \`query\` text NOT NULL,
  \`count\` int(10) unsigned default NULL,
  \`sum_time_ms\` float default NULL,
  UNIQUE KEY \`query\` (\`query\`(100))
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS \`${TABLES_PREFIX}log_visit\` (
  \`idvisit\` int(10) unsigned NOT NULL auto_increment,
  \`idsite\` int(10) unsigned NOT NULL,
  \`idvisitor\` binary(8) NOT NULL,
  \`visitor_localtime\` time NOT NULL,
  \`visitor_returning\` tinyint(1) NOT NULL,
  \`visitor_count_visits\` smallint(5) unsigned NOT NULL,
  \`visitor_days_since_last\` smallint(5) unsigned NOT NULL,
  \`visitor_days_since_order\` smallint(5) unsigned NOT NULL,
  \`visitor_days_since_first\` smallint(5) unsigned NOT NULL,
  \`visit_first_action_time\` datetime NOT NULL,
  \`visit_last_action_time\` datetime NOT NULL,
  \`visit_exit_idaction_url\` int(11) unsigned NOT NULL,
  \`visit_exit_idaction_name\` int(11) unsigned NOT NULL,
  \`visit_entry_idaction_url\` int(11) unsigned NOT NULL,
  \`visit_entry_idaction_name\` int(11) unsigned NOT NULL,
  \`visit_total_actions\` smallint(5) unsigned NOT NULL,
  \`visit_total_time\` smallint(5) unsigned NOT NULL,
  \`visit_goal_converted\` tinyint(1) NOT NULL,
  \`visit_goal_buyer\` tinyint(1) NOT NULL,
  \`referer_type\` tinyint(1) unsigned default NULL,
  \`referer_name\` varchar(70) default NULL,
  \`referer_url\` text NOT NULL,
  \`referer_keyword\` varchar(255) default NULL,
  \`config_id\` binary(8) NOT NULL,
  \`config_os\` char(3) NOT NULL,
  \`config_browser_name\` varchar(10) NOT NULL,
  \`config_browser_version\` varchar(20) NOT NULL,
  \`config_resolution\` varchar(9) NOT NULL,
  \`config_pdf\` tinyint(1) NOT NULL,
  \`config_flash\` tinyint(1) NOT NULL,
  \`config_java\` tinyint(1) NOT NULL,
  \`config_director\` tinyint(1) NOT NULL,
  \`config_quicktime\` tinyint(1) NOT NULL,
  \`config_realplayer\` tinyint(1) NOT NULL,
  \`config_windowsmedia\` tinyint(1) NOT NULL,
  \`config_gears\` tinyint(1) NOT NULL,
  \`config_silverlight\` tinyint(1) NOT NULL,
  \`config_cookie\` tinyint(1) NOT NULL,
  \`location_ip\` varbinary(16) NOT NULL,
  \`location_browser_lang\` varchar(20) NOT NULL,
  \`location_country\` char(3) NOT NULL,
  \`location_continent\` char(3) NOT NULL,
  \`custom_var_k1\` varchar(200) default NULL,
  \`custom_var_v1\` varchar(200) default NULL,
  \`custom_var_k2\` varchar(200) default NULL,
  \`custom_var_v2\` varchar(200) default NULL,
  \`custom_var_k3\` varchar(200) default NULL,
  \`custom_var_v3\` varchar(200) default NULL,
  \`custom_var_k4\` varchar(200) default NULL,
  \`custom_var_v4\` varchar(200) default NULL,
  \`custom_var_k5\` varchar(200) default NULL,
  \`custom_var_v5\` varchar(200) default NULL,
  \`location_provider\` varchar(100) default NULL,
  PRIMARY KEY  (\`idvisit\`),
  KEY \`index_idsite_config_datetime\` (\`idsite\`,\`config_id\`,\`visit_last_action_time\`),
  KEY \`index_idsite_datetime\` (\`idsite\`,\`visit_last_action_time\`),
  KEY \`index_idsite_idvisitor\` (\`idsite\`,\`idvisitor\`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS \`${TABLES_PREFIX}option\` (
  \`option_name\` varchar(255) NOT NULL,
  \`option_value\` longtext NOT NULL,
  \`autoload\` tinyint(4) NOT NULL default '1',
  PRIMARY KEY  (\`option_name\`),
  KEY \`autoload\` (\`autoload\`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
INSERT INTO \`${TABLES_PREFIX}option\` (\`option_name\`, \`option_value\`, \`autoload\`) VALUES
('version_core', '1.8.2', 1),
('SitesManager_DefaultTimezone', 'UTC+5.5', 0),
('version_CorePluginsAdmin', '1.8.2', 1),
('version_CoreAdminHome', '1.8.2', 1),
('version_CoreHome', '1.8.2', 1),
('version_Proxy', '1.8.2', 1),
('version_API', '1.8.2', 1),
('version_Widgetize', '1.8.2', 1),
('version_LanguagesManager', '1.8.2', 1),
('version_Actions', '1.8.2', 1),
('version_Dashboard', '1.8.2', 1),
('version_MultiSites', '1.8.2', 1),
('version_Referers', '1.8.2', 1),
('version_UserSettings', '1.8.2', 1),
('version_Goals', '1.8.2', 1),
('version_SEO', '1.8.2', 1),
('version_UserCountry', '1.8.2', 1),
('version_VisitsSummary', '1.8.2', 1),
('version_VisitFrequency', '1.8.2', 1),
('version_VisitTime', '1.8.2', 1),
('version_VisitorInterest', '1.8.2', 1),
('version_ExampleAPI', '0.1', 1),
('version_ExamplePlugin', '0.1', 1),
('version_ExampleRssWidget', '0.1', 1),
('version_ExampleFeedburner', '0.1', 1),
('version_Provider', '1.8.2', 1),
('version_Feedback', '1.8.2', 1),
('version_Login', '1.8.2', 1),
('version_UsersManager', '1.8.2', 1),
('version_SitesManager', '1.8.2', 1),
('version_Installation', '1.8.2', 1),
('version_CoreUpdater', '1.8.2', 1),
('version_PDFReports', '1.8.2', 1),
('version_UserCountryMap', '1.8.2', 1),
('version_Live', '1.8.2', 1),
('version_CustomVariables', '1.8.2', 1),
('version_PrivacyManager', '1.8.2', 1),
('version_ImageGraph', '1.8.2', 1),
('version_DoNotTrack', '1.8.2', 1),
('piwikUrl', 'http://${PIWIK_IP}/piwik/', 1),
('UpdateCheck_LastTimeChecked', '${LastTimeChecked}', 1),
('UpdateCheck_LatestVersion', '1.8.2', 0),
('delete_logs_enable', '0', 0),
('delete_logs_schedule_lowest_interval', '7', 0),
('delete_logs_older_than', '180', 0),
('delete_logs_max_rows_per_query', '100000', 0),
('delete_reports_enable', '0', 0),
('delete_reports_older_than', '12', 0),
('delete_reports_keep_basic_metrics', '1', 0),
('delete_reports_keep_day_reports', '0', 0),
('delete_reports_keep_week_reports', '0', 0),
('delete_reports_keep_month_reports', '1', 0),
('delete_reports_keep_year_reports', '1', 0),
('delete_reports_keep_range_reports', '0', 0),
('delete_reports_keep_segment_reports', '0', 0);

CREATE TABLE IF NOT EXISTS \`${TABLES_PREFIX}pdf\` (
  \`idreport\` int(11) NOT NULL auto_increment,
  \`idsite\` int(11) NOT NULL,
  \`login\` varchar(100) NOT NULL,
  \`description\` varchar(255) NOT NULL,
  \`period\` varchar(10) default NULL,
  \`format\` varchar(10) default NULL,
  \`display_format\` tinyint(1) NOT NULL,
  \`email_me\` tinyint(4) default NULL,
  \`additional_emails\` text,
  \`reports\` text NOT NULL,
  \`ts_created\` timestamp NULL default NULL,
  \`ts_last_sent\` timestamp NULL default NULL,
  \`deleted\` tinyint(4) NOT NULL default '0',
  PRIMARY KEY  (\`idreport\`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS \`${TABLES_PREFIX}session\` (
  \`id\` char(32) NOT NULL,
  \`modified\` int(11) default NULL,
  \`lifetime\` int(11) default NULL,
  \`data\` text,
  PRIMARY KEY  (\`id\`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS \`${TABLES_PREFIX}site\` (
  \`idsite\` int(10) unsigned NOT NULL auto_increment,
  \`name\` varchar(90) NOT NULL,
  \`main_url\` varchar(255) NOT NULL,
  \`ts_created\` timestamp NULL default NULL,
  \`ecommerce\` tinyint(4) default '0',
  \`timezone\` varchar(50) NOT NULL,
  \`currency\` char(3) NOT NULL,
  \`excluded_ips\` text NOT NULL,
  \`excluded_parameters\` varchar(255) NOT NULL,
  \`group\` varchar(250) NOT NULL,
  \`feedburnerName\` varchar(100) default NULL,
  PRIMARY KEY  (\`idsite\`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;
INSERT INTO \`${TABLES_PREFIX}site\` (\`idsite\`, \`name\`, \`main_url\`, \`ts_created\`, \`ecommerce\`, \`timezone\`, \`currency\`, \`excluded_ips\`, \`excluded_parameters\`, \`group\`, \`feedburnerName\`) VALUES
(1, '${SITE_NAME}', 'http://www.${SITE_NAME}', '${CURENT_TIME}', 1, 'UTC+5.5', 'USD', '', '', '', NULL);

CREATE TABLE IF NOT EXISTS \`${TABLES_PREFIX}site_url\` (
  \`idsite\` int(10) unsigned NOT NULL,
  \`url\` varchar(255) NOT NULL,
  PRIMARY KEY  (\`idsite\`,\`url\`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS \`${TABLES_PREFIX}user\` (
  \`login\` varchar(100) NOT NULL,
  \`password\` char(32) NOT NULL,
  \`alias\` varchar(45) NOT NULL,
  \`email\` varchar(100) NOT NULL,
  \`token_auth\` char(32) NOT NULL,
  \`date_registered\` timestamp NULL default NULL,
  PRIMARY KEY  (\`login\`),
  UNIQUE KEY \`uniq_keytoken\` (\`token_auth\`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
INSERT INTO \`${TABLES_PREFIX}user\` (\`login\`, \`password\`, \`alias\`, \`email\`, \`token_auth\`, \`date_registered\`) VALUES
('anonymous', '', 'anonymous', 'anonymous@example.org', 'anonymous', '${CURENT_TIME}');

CREATE TABLE IF NOT EXISTS \`${TABLES_PREFIX}user_dashboard\` (
  \`login\` varchar(100) NOT NULL,
  \`iddashboard\` int(11) NOT NULL,
  \`name\` varchar(100) default NULL,
  \`layout\` text NOT NULL,
  PRIMARY KEY  (\`login\`,\`iddashboard\`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS \`${TABLES_PREFIX}user_language\` (
  \`login\` varchar(100) NOT NULL,
  \`language\` varchar(10) NOT NULL,
  PRIMARY KEY  (\`login\`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

EOF
check_error "ERROR:WHILE CREATING SQL FILE FOR PIWIK DATABASE"

echo "IMPORTING SAMPLE DATA INTO PIWIK DATABSE"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -h localhost $PIWIK_DATABASE < "$DOCUMENT_ROOT/piwik/$PIWIK_DATABASE.sql"
check_error "ERROR:WHILE IMPORTING DATA INTO PIWIK DATABASE"

echo "CREATE AND EDIT THE CONFIGURATION FILE"
cat <<EOF>~/getmd5.php
<?php
echo md5($PIWIK_PASSWORD);
?>
EOF
chmod 777 ~/getmd5.php
ENCRYPTED_PASSWORD=`php ~/getmd5.php`

cat <<EOF>"$DOCUMENT_ROOT/piwik/config/config.ini.php"
; <?php exit; ?> DO NOT REMOVE THIS LINE
; file automatically generated or modified by Piwik; you can manually override the default values in global.ini.php by redefining them in this file.
[superuser]
login = "$PIWIK_USER_NAME"
password = "$ENCRYPTED_PASSWORD"
email = "$PIWIK_EMAIL"
salt = "be71b271c341c6337217a9454173a138"

[database]
host = "$PIWIK_HOST"
username = "$MYSQL_USERNAME"
password = "$MYSQL_PASSWORD"
dbname = "$PIWIK_DATABASE"
tables_prefix = "$TABLES_PREFIX"
charset = "utf8"

[PluginsInstalled]
PluginsInstalled[] = "Actions"
PluginsInstalled[] = "AnonymizeIP"
PluginsInstalled[] = "API"
PluginsInstalled[] = "CoreAdminHome"
PluginsInstalled[] = "CoreHome"
PluginsInstalled[] = "CorePluginsAdmin"
PluginsInstalled[] = "CoreUpdater"
PluginsInstalled[] = "CustomVariables"
PluginsInstalled[] = "Dashboard"
PluginsInstalled[] = "DBStats"
PluginsInstalled[] = "DoNotTrack"
PluginsInstalled[] = "ExampleAPI"
PluginsInstalled[] = "ExampleFeedburner"
PluginsInstalled[] = "ExamplePlugin"
PluginsInstalled[] = "ExampleRssWidget"
PluginsInstalled[] = "ExampleUI"
PluginsInstalled[] = "Feedback"
PluginsInstalled[] = "Goals"
PluginsInstalled[] = "ImageGraph"
PluginsInstalled[] = "Installation"
PluginsInstalled[] = "LanguagesManager"
PluginsInstalled[] = "Live"
PluginsInstalled[] = "Login"
PluginsInstalled[] = "MultiSites"
PluginsInstalled[] = "PDFReports"
PluginsInstalled[] = "PrivacyManager"
PluginsInstalled[] = "Provider"
PluginsInstalled[] = "Proxy"
PluginsInstalled[] = "Referers"
PluginsInstalled[] = "SecurityInfo"
PluginsInstalled[] = "SEO"
PluginsInstalled[] = "SitesManager"
PluginsInstalled[] = "UserCountry"
PluginsInstalled[] = "UserCountryMap"
PluginsInstalled[] = "UserSettings"
PluginsInstalled[] = "UsersManager"
PluginsInstalled[] = "VisitFrequency"
PluginsInstalled[] = "VisitorGenerator"
PluginsInstalled[] = "VisitorInterest"
PluginsInstalled[] = "VisitsSummary"
PluginsInstalled[] = "VisitTime"
PluginsInstalled[] = "Widgetize"

EOF