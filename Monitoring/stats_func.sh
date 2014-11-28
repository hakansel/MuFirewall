#!/usr/local/bin/php -f
<?php
/*
	$Id$
	part of pfSense (https://www.pfsense.org)
	
	Copyright (C) 2007 Scott Ullrich <sullrich@gmail.com>
	All rights reserved.
	
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:
	
	1. Redistributions of source code must retain the above copyright notice,
	   this list of conditions and the following disclaimer.
	
	2. Redistributions in binary form must reproduce the above copyright
	   notice, this list of conditions and the following disclaimer in the
	   documentation and/or other materials provided with the distribution.
	
	THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
	INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
	AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
	AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
	OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
	POSSIBILITY OF SUCH DAMAGE.
*/

##|+PRIV
##|*IDENT=page-diagnostics-cpuutilization
##|*NAME=Diagnostics: CPU Utilization page
##|*DESCR=Allow access to the 'Diagnostics: CPU Utilization' page.
##|*MATCH=stats.php*
##|-PRIV

/*require_once("/home/monitoring/guiconfig.inc");*/
require_once("/home/monitoring/functions.inc.php");

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
$blacklist_version = `/bin/cat /home/FirewallUpdater/Blacklist/blacklist.version`;
$blacklist_version = chop($blacklist_version, "\n");
$logger_version = `/bin/cat /home/FirewallUpdater/Logger/logger.version`;
$logger_version = chop($logger_version, "\n");
$monitoring_version = `/bin/cat /home/FirewallUpdater/Monitoring/monitoring.version`;
$monitoring_version = chop($monitoring_version, "\n");
$config_update = `/bin/ls -l -D %Y%m%d-%H%M%S /cf/conf/config.xml | awk '{ print $6 }'`;
$config_update = chop($config_update, "\n");

$stats = array('ip' => $ip, 'monitorTime' => $monitor_time, 'cpuCount' => $cpu_count, 'totalDisk' => $total_disk, 'usedDisk' => $used_disk, 'availDisk' => $avail_disk, 'cpuUsage' => $cpu, 'memUsage' => $mem, 'update' => $update, 'diskUsage' => $disk, 'upTime' => $uptime, 'blacklistVersion' => $blacklist_version, 'loggerVersion' => $logger_version, 'monitoringVersion' => $monitoring_version, 'lastConfigUpdate' => $config_update);
echo json_encode($stats);
/*
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
*/
exit;

?>
