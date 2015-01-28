#!/usr/local/bin/php -f
<?php

require_once("/usr/local/www/includes/functions.inc.php");

$tcpdump_log_file = "/home/trafficlog/tcpdumplog_date";
$auth_log_file = "/home/trafficlog/authlog_date";
$dhcp_log_file = "/home/trafficlog/dhcplog_date";

$ip = `/sbin/ifconfig re1 | /usr/bin/grep 'inet ' | /usr/bin/awk '{print $2}'`;
$ip = chop($ip, "\n");
$monitor_time = `/bin/date "+%Y%m%d%H%M%S"`;
$monitor_time = chop($monitor_time, "\n");
$cpu = cpu_usage();
$cpu_count = get_cpu_count(false);
$mem = mem_usage();
$update = mu_update_date_time();
$total_disk = `/bin/df -h | /usr/bin/grep -w '/' | /usr/bin/awk '{print $2}'`;
$total_disk = chop($total_disk, "\n");
$used_disk = `/bin/df -h | /usr/bin/grep -w '/' | /usr/bin/awk '{print $3}'`;
$used_disk = chop($used_disk, "\n");
$avail_disk = `/bin/df -h | /usr/bin/grep -w '/' | /usr/bin/awk '{print $4}'`;
$avail_disk = chop($avail_disk, "\n");
$disk = disk_usage();
$uptime = get_uptime();
$blacklist_version = `/bin/ls -l -D %Y%m%d-%H%M%S /sbin/blacklist_update.sh | awk '{ print $6 }'`;
$blacklist_version = chop($blacklist_version, "\n");
$blacklist_func_version = `/bin/ls -l -D %Y%m%d-%H%M%S /home/blocked/blocked_func.sh | awk '{ print $6 }'`;
$blacklist_func_version = chop($blacklist_func_version, "\n");
$logger_version = `/bin/ls -l -D %Y%m%d-%H%M%S /sbin/dhcplistcronsmb.sh | awk '{ print $6 }'`;
$logger_version = chop($logger_version, "\n");
$logger_func_version = `/bin/ls -l -D %Y%m%d-%H%M%S /home/trafficlog/killactivetcpdump.sh | awk '{ print $6 }'`;
$logger_func_version = chop($logger_func_version, "\n");
$monitoring_version = `/bin/ls -l -D %Y%m%d-%H%M%S /sbin/monitorservice.sh | awk '{ print $6 }'`;
$monitoring_version = chop($monitoring_version, "\n");
$monitoring_func_version = `/bin/ls -l -D %Y%m%d-%H%M%S /home/monitoring/stats_func.sh | awk '{ print $6 }'`;
$monitoring_func_version = chop($monitoring_func_version, "\n");
$config_update = `/bin/ls -l -D %Y%m%d-%H%M%S /cf/conf/config.xml | awk '{ print $6 }'`;
$config_update = chop($config_update, "\n");
if(file_exists($tcpdump_log_file))
{
	$tcpdump_log_date = file_get_contents($tcpdump_log_file);
	$tcpdump_log_date = chop($tcpdump_log_date, "\n");
}
else
{
	$tcpdump_log_date = "No version for tcpdump log.";
}

if(file_exists($dhcp_log_file))
{
	$dhcp_log_date = file_get_contents($dhcp_log_file);
	$dhcp_log_date = chop($dhcp_log_date, "\n");
}
else
{
	$dhcp_log_date = "No version for dhcp log.";
}
if(file_exists($auth_log_file))
{
	$auth_log_date = file_get_contents($auth_log_file);
	$auth_log_date = chop($auth_log_date, "\n");
}
else
{
	$auth_log_date = "No version for auth log.";
}

$stats = array('tcpdumpLogVer' => $tcpdump_log_date, 'dhcpLogVer' => $dhcp_log_date, 'authLogVer' => $auth_log_date, 'ip' => $ip, 'monitorTime' => $monitor_time, 'cpuCount' => $cpu_count, 'totalDisk' => $total_disk, 'usedDisk' => $used_disk, 'availDisk' => $avail_disk, 'cpuUsage' => $cpu, 'memUsage' => $mem, 'update' => $update, 'diskUsage' => $disk, 'upTime' => $uptime, 'blacklistVersion' => $blacklist_version, 'loggerVersion' => $logger_version, 'monitoringVersion' => $monitoring_version, 'lastConfigUpdate' => $config_update, 'loggerFuncVersion' => $logger_func_version, 'blacklistFuncVersion' => $blacklist_func_version, 'monitoringFuncVersion' => $monitoring_func_version);
echo json_encode($stats);

function mu_update_date_time() {
    $datetime = date("Ymd-His");
    return $datetime;
}

// you can use it, if you change json with xml format.
function xml_encode($mixed, $domElement=null, $DOMDocument=null) {
    if (is_null($DOMDocument)) {
        $DOMDocument =new DOMDocument;
        $DOMDocument->formatOutput = true;
        xml_encode($mixed, $DOMDocument, $DOMDocument);
        echo $DOMDocument->saveXML();
    }
    else {
        if (is_array($mixed)) {
            foreach ($mixed as $index => $mixedElement) {
                if (is_int($index)) {
                    if ($index === 0) {
                        $node = $domElement;
                    }
                    else {
                        $node = $DOMDocument->createElement($domElement->tagName);
                        $domElement->parentNode->appendChild($node);
                    }
                }
                else {
                    $plural = $DOMDocument->createElement($index);
                    $domElement->appendChild($plural);
                    $node = $plural;
                    if (!(rtrim($index, 's') === $index)) {
                        $singular = $DOMDocument->createElement(rtrim($index, 's'));
                        $plural->appendChild($singular);
                        $node = $singular;
                    }
                }
 
                xml_encode($mixedElement, $node, $DOMDocument);
            }
        }
        else {
            $domElement->appendChild($DOMDocument->createTextNode($mixed));
        }
    }
}

exit;

?>
