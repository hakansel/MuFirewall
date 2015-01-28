#!/usr/local/bin/php -f
<?php

require_once("/usr/local/www/includes/functions.inc.php");

$tarih = `/bin/date "+%Y-%m-%d"`;
$today = date_create($tarih);

$diskUsage = disk_usage();
$oldestLogDate = `/bin/ls -l -D %Y-%m-%d /cf/conf/backup/config-* | head -1 | awk '{ print $6 }'`;
$oldestLogDate = date_create($oldestLogDate);

$upToDate = date_diff($today, $oldestLogDate);
$upToDate = $upToDate->format("%d"); 

# last log reach one month constraint or disk usage over %90
if (($diskUsage > 90) || ($upToDate >= 1)) {
        $resRm = `/bin/rm /cf/conf/backup/config-*`;
        if ($resRm == 0) {
                `logger -s "Config backup are cleaned."`;
        } else {
			`logger -s "Config backup did not cleaned."`;
		}
		
}

exit;
?>