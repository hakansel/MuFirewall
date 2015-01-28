#!/usr/local/bin/php -f
<?php

require_once("/usr/local/www/includes/functions.inc.php");

$tarih = `/bin/date "+%Y-%m-%d"`;
$today = date_create($tarih);

$diskUsage = disk_usage();
$oldestLogDate = `/bin/ls -l -D %Y-%m-%d /home/trafficlog/*.tar.gz | head -1 | awk '{ print $6 }'`;
$oldestLogDate = date_create($oldestLogDate);

$upToMonth = date_diff($today, $oldestLogDate);
$upToMonth = $upToMonth->format("%m"); 

$oldestAuthDhcpLogDate = `/bin/ls -l -D %Y-%m-%d /home/trafficlog/*.txt | head -1 | awk '{ print $6 }'`;
$oldestAuthDhcpLogDate = date_create($oldestAuthDhcpLogDate);

$upToMonthAuthDhcp = date_diff($today, $oldestAuthDhcpLogDate);
$upToMonthAuthDhcp = $upToMonthAuthDhcp->format("%m"); 

# last log reach one month constraint or disk usage over %90
if (($diskUsage > 90) || ($upToMonth >= 1) || ($upToMonthAuthDhcp >= 1)) {
        $resRm = `/bin/rm /home/trafficlog/*.tar.gz`;
		$resRmAuth = `/bin/rm /home/trafficlog/*.txt`;
        if (($resRm == 0) || ($resRmAuth == 0)) {
                `logger -s "Traffic logs are cleaned."`;
        } else {
			`logger -s "Traffic logs did not cleaned."`;
		}
}

exit;
?>